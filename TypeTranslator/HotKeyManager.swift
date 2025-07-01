import Foundation
import Carbon
import SwiftUI

class HotKeyManager: ObservableObject {
    @Published var isListening = false
    @Published var isRecordingHotKey = false
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var recordingEventMonitor: Any?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x5454524C), id: 1) // "TTRL"
    
    var settings: AppSettings?
    
    private let onTranslationRequested: () -> Void
    
    init(onTranslationRequested: @escaping () -> Void = {}) {
        self.onTranslationRequested = onTranslationRequested
        
        // 监听快捷键更新通知
        NotificationCenter.default.addObserver(
            forName: Notification.Name("UpdateHotKey"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.setupHotKey()
        }
    }
    
    func configure(with settings: AppSettings) {
        self.settings = settings
        setupHotKey()
    }
    
    deinit {
        unregisterHotKey()
    }
    
    func setupHotKey() {
        unregisterHotKey()
        
        guard let settings = settings, settings.isEnabled else { 
            NSLog("🔑 HotKeyManager: setupHotKey skipped - settings disabled or nil")
            return 
        }
        
        NSLog("🔑 HotKeyManager: Setting up hotkey with code=\(settings.hotKeyCode), modifiers=\(settings.hotKeyModifiers)")
        
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                    eventKind: OSType(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(),
                          { (nextHandler, theEvent, userData) -> OSStatus in
            let manager = Unmanaged<HotKeyManager>.fromOpaque(userData!).takeUnretainedValue()
            manager.handleHotKeyPressed()
            return noErr
        }, 1, &eventSpec, Unmanaged.passUnretained(self).toOpaque(), &eventHandler)
        
        let status = RegisterEventHotKey(UInt32(settings.hotKeyCode),
                                       settings.hotKeyModifiers,
                                       hotKeyID,
                                       GetApplicationEventTarget(),
                                       0,
                                       &hotKeyRef)
        
        if status == noErr {
            isListening = true
            NSLog("🔑 HotKeyManager: Hot key registered successfully")
        } else {
            isListening = false
            let errorMessage = getHotKeyErrorMessage(status)
            NSLog("🔑 HotKeyManager: Failed to register hot key: \(status) - \(errorMessage)")
            
            // 如果快捷键冲突，尝试使用默认快捷键
            if status == -9868 { // hotKeyExistsErr
                NSLog("🔑 HotKeyManager: Hot key conflict detected, trying default hotkey")
                tryRegisterDefaultHotKey()
            }
        }
    }
    
    private func unregisterHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
        
        isListening = false
    }
    
    private func handleHotKeyPressed() {
        NSLog("🔑 HotKeyManager: Hot key pressed!")
        NSLog("🚀 HotKeyManager: Calling onTranslationRequested callback")
        onTranslationRequested()
        
        NSLog("📨 HotKeyManager: Posting translationRequested notification")
        // Notify other components that translation was requested  
        NotificationCenter.default.post(name: .translationRequested, object: nil)
    }
    
    private func getHotKeyErrorMessage(_ status: OSStatus) -> String {
        switch status {
        case -9868:
            return "Hot key already in use by another application"
        case -9850:
            return "Invalid hot key combination"
        case -50:
            return "Parameter error"
        default:
            return "Unknown error (\(status))"
        }
    }
    
    private func tryRegisterDefaultHotKey() {
        guard let settings = settings else { return }
        
        // 尝试默认快捷键 Cmd+Shift+T
        let defaultKeyCode: UInt16 = 17 // T
        let defaultModifiers: UInt32 = UInt32(cmdKey | shiftKey)
        
        NSLog("🔑 HotKeyManager: Attempting to register default hotkey Cmd+Shift+T")
        
        let status = RegisterEventHotKey(UInt32(defaultKeyCode),
                                       defaultModifiers,
                                       hotKeyID,
                                       GetApplicationEventTarget(),
                                       0,
                                       &hotKeyRef)
        
        if status == noErr {
            // 更新设置为默认值
            settings.hotKeyCode = defaultKeyCode
            settings.hotKeyModifiers = defaultModifiers
            isListening = true
            NSLog("🔑 HotKeyManager: Successfully registered default hotkey Cmd+Shift+T")
        } else {
            NSLog("🔑 HotKeyManager: Failed to register default hotkey: \(status)")
        }
    }
    
    func updateHotKey(keyCode: UInt16, modifiers: UInt32) {
        guard let settings = settings else { return }
        settings.hotKeyCode = keyCode
        settings.hotKeyModifiers = modifiers
        setupHotKey()
    }
    
    func testHotKeyAvailability(keyCode: UInt16, modifiers: UInt32) -> (available: Bool, error: String?) {
        // 临时注册热键测试是否可用
        var testHotKeyRef: EventHotKeyRef?
        let testHotKeyID = EventHotKeyID(signature: OSType(0x54455354), id: 999) // "TEST"
        
        let status = RegisterEventHotKey(UInt32(keyCode),
                                       modifiers,
                                       testHotKeyID,
                                       GetApplicationEventTarget(),
                                       0,
                                       &testHotKeyRef)
        
        if status == noErr {
            // 成功注册，立即注销
            if let testRef = testHotKeyRef {
                UnregisterEventHotKey(testRef)
            }
            return (true, nil)
        } else {
            return (false, getHotKeyErrorMessage(status))
        }
    }
    
    func toggleEnabled() {
        guard let settings = settings else { return }
        settings.isEnabled.toggle()
        if settings.isEnabled {
            setupHotKey()
        } else {
            unregisterHotKey()
        }
    }
    
    func startRecordingHotKey() {
        stopRecordingHotKey()
        isRecordingHotKey = true
        print("Starting hotkey recording...")
        
        // 检查辅助功能权限
        let trusted = AXIsProcessTrusted()
        print("Accessibility permission status: \(trusted)")
        
        if !trusted {
            print("需要辅助功能权限才能录制快捷键")
            DispatchQueue.main.async {
                self.isRecordingHotKey = false
            }
            return
        }
        
        // 使用NSEvent监听全局键盘事件
        recordingEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            print("Global key event detected: keyCode=\(event.keyCode), modifiers=\(event.modifierFlags)")
            DispatchQueue.main.async {
                self?.handleNSEventRecording(event)
            }
        }
        
        // 同时监听本地事件（应用内）
        let localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            print("Local key event detected: keyCode=\(event.keyCode), modifiers=\(event.modifierFlags)")
            DispatchQueue.main.async {
                self?.handleNSEventRecording(event)
            }
            return nil // 不阻止事件传播
        }
        
        if recordingEventMonitor != nil {
            print("Global NSEvent monitor installed successfully")
        } else {
            print("Failed to install global NSEvent monitor")
        }
        
        if localMonitor != nil {
            print("Local NSEvent monitor installed successfully")
        }
        
        if recordingEventMonitor == nil && localMonitor == nil {
            isRecordingHotKey = false
        }
    }
    
    func stopRecordingHotKey() {
        if let monitor = recordingEventMonitor {
            NSEvent.removeMonitor(monitor)
            recordingEventMonitor = nil
        }
        isRecordingHotKey = false
        print("Stopped hotkey recording")
    }
    
    private func handleNSEventRecording(_ event: NSEvent) {
        guard isRecordingHotKey else { return }
        
        let keyCode = UInt16(event.keyCode)
        let modifiers = event.modifierFlags
        
        print("NSEvent recording - keyCode: \(keyCode), modifiers: \(modifiers.rawValue)")
        
        // 过滤修饰键本身
        let modifierKeyCodes: Set<UInt16> = [54, 55, 56, 57, 58, 59, 60, 61, 62, 63]
        if modifierKeyCodes.contains(keyCode) {
            print("Modifier key pressed, ignoring")
            return
        }
        
        // 转换NSEvent修饰键到Carbon格式
        var carbonModifiers: UInt32 = 0
        if modifiers.contains(.command) {
            carbonModifiers |= UInt32(cmdKey)
            print("Command key detected")
        }
        if modifiers.contains(.shift) {
            carbonModifiers |= UInt32(shiftKey)
            print("Shift key detected")
        }
        if modifiers.contains(.option) {
            carbonModifiers |= UInt32(optionKey)
            print("Option key detected")
        }
        if modifiers.contains(.control) {
            carbonModifiers |= UInt32(controlKey)
            print("Control key detected")
        }
        
        // 需要至少一个修饰键
        if carbonModifiers == 0 {
            print("No modifiers detected in NSEvent, ignoring")
            return
        }
        
        let hotkeyString = "\(HotKeyManager.modifiersToString(carbonModifiers))\(HotKeyManager.keyCodeToString(keyCode))"
        print("Valid NSEvent hotkey detected: \(hotkeyString)")
        
        updateHotKey(keyCode: keyCode, modifiers: carbonModifiers)
        stopRecordingHotKey()
    }
    

}

// MARK: - Notification Names
extension Notification.Name {
    static let translationRequested = Notification.Name("translationRequested")
}

// MARK: - Key Code Utilities
extension HotKeyManager {
    static func keyCodeToString(_ keyCode: UInt16) -> String {
        switch keyCode {
        case 0: return "A"
        case 1: return "S"
        case 2: return "D"
        case 3: return "F"
        case 4: return "H"
        case 5: return "G"
        case 6: return "Z"
        case 7: return "X"
        case 8: return "C"
        case 9: return "V"
        case 11: return "B"
        case 12: return "Q"
        case 13: return "W"
        case 14: return "E"
        case 15: return "R"
        case 16: return "Y"
        case 17: return "T"
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 22: return "6"
        case 23: return "5"
        case 24: return "="
        case 25: return "9"
        case 26: return "7"
        case 27: return "-"
        case 28: return "8"
        case 29: return "0"
        case 30: return "]"
        case 31: return "O"
        case 32: return "U"
        case 33: return "["
        case 34: return "I"
        case 35: return "P"
        case 37: return "L"
        case 38: return "J"
        case 39: return "'"
        case 40: return "K"
        case 41: return ";"
        case 42: return "\\"
        case 43: return ","
        case 44: return "/"
        case 45: return "N"
        case 46: return "M"
        case 47: return "."
        case 50: return "`"
        case 36: return "Return"
        case 48: return "Tab"
        case 49: return "Space"
        case 51: return "Delete"
        case 53: return "Escape"
        default: return "Unknown"
        }
    }
    
    static func modifiersToString(_ modifiers: UInt32) -> String {
        var result: [String] = []
        
        if modifiers & UInt32(cmdKey) != 0 {
            result.append("⌘")
        }
        if modifiers & UInt32(shiftKey) != 0 {
            result.append("⇧")
        }
        if modifiers & UInt32(optionKey) != 0 {
            result.append("⌥")
        }
        if modifiers & UInt32(controlKey) != 0 {
            result.append("⌃")
        }
        
        return result.joined()
    }
} 