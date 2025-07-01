import Foundation
import ApplicationServices
import AppKit

class AccessibilityManager: ObservableObject {
    @Published var hasAccessibilityPermission = false
    
    init() {
        let _ = checkAccessibilityPermission()
        
        // Listen for translation requests
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTranslationRequest),
            name: .translationRequested,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func checkAccessibilityPermission() -> Bool {
        let trusted = AXIsProcessTrustedWithOptions([
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary)
        
        DispatchQueue.main.async {
            self.hasAccessibilityPermission = trusted
        }
        
        return trusted
    }
    
    func requestAccessibilityPermission() {
        print("Requesting accessibility permission...")
        
        // Force show the system preferences dialog
        let options = [
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary
        
        let trusted = AXIsProcessTrustedWithOptions(options)
        print("Current accessibility status: \(trusted)")
        
        // Open System Preferences directly to Security & Privacy
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
        
        // Start periodic checking
        startPeriodicPermissionCheck()
    }
    
    private func startPeriodicPermissionCheck() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let newStatus = self.checkAccessibilityPermission()
            if newStatus {
                timer.invalidate()
                print("Accessibility permission granted!")
            }
        }
    }
    
    @objc private func handleTranslationRequest() {
        NSLog("🔔 AccessibilityManager: Received translation request notification")
        
        guard hasAccessibilityPermission else {
            NSLog("❌ AccessibilityManager: No accessibility permission")
            return
        }
        
        NSLog("✅ AccessibilityManager: Has accessibility permission, proceeding...")
        getSelectedTextAndTranslate()
    }
    
    private func getSelectedTextAndTranslate() {
        NSLog("🔍 AccessibilityManager: Getting focused element...")
        
        // Get the focused text field
        guard let focusedElement = getFocusedElement() else {
            NSLog("❌ AccessibilityManager: No focused element found, trying clipboard fallback...")
            handleClipboardFallback()
            return
        }
        
        NSLog("✅ AccessibilityManager: Found focused element")
        
        // Get selected text or all text if nothing is selected
        let text = getTextFromElement(focusedElement)
        
        guard !text.isEmpty else {
            NSLog("❌ AccessibilityManager: No text to translate")
            return
        }
        
        NSLog("📝 AccessibilityManager: Text to translate: '\(text)'")
        
        // Request translation
        NSLog("📤 AccessibilityManager: Posting translateText notification")
        NotificationCenter.default.post(
            name: .translateText,
            object: nil,
            userInfo: ["text": text, "element": focusedElement]
        )
    }
    
    private func handleClipboardFallback() {
        NSLog("🔄 AccessibilityManager: Using clipboard fallback method...")
        
        // Save current clipboard content
        let pasteboard = NSPasteboard.general
        let originalClipboard = pasteboard.string(forType: .string)
        
        // Simulate Cmd+A to select all text
        NSLog("📋 AccessibilityManager: Selecting all text with Cmd+A...")
        let selectAllEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0x00, keyDown: true) // 'a' key
        selectAllEvent?.flags = .maskCommand
        selectAllEvent?.post(tap: .cghidEventTap)
        
        let selectAllEventUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x00, keyDown: false)
        selectAllEventUp?.flags = .maskCommand
        selectAllEventUp?.post(tap: .cghidEventTap)
        
        // Wait a bit for selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Simulate Cmd+C to copy selected text
            NSLog("📋 AccessibilityManager: Copying selected text with Cmd+C...")
            let copyEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0x08, keyDown: true) // 'c' key
            copyEvent?.flags = .maskCommand
            copyEvent?.post(tap: .cghidEventTap)
            
            let copyEventUp = CGEvent(keyboardEventSource: nil, virtualKey: 0x08, keyDown: false)
            copyEventUp?.flags = .maskCommand
            copyEventUp?.post(tap: .cghidEventTap)
            
            // Wait for copy to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // Get copied text
                guard let copiedText = pasteboard.string(forType: .string), !copiedText.isEmpty else {
                    NSLog("❌ AccessibilityManager: No text copied from clipboard")
                    // Restore original clipboard
                    if let original = originalClipboard {
                        pasteboard.clearContents()
                        pasteboard.setString(original, forType: .string)
                    }
                    return
                }
                
                NSLog("📝 AccessibilityManager: Copied text: '\(copiedText)'")
                
                // Request translation with clipboard method
                NSLog("📤 AccessibilityManager: Posting translateText notification for clipboard method")
                NotificationCenter.default.post(
                    name: .translateText,
                    object: nil,
                    userInfo: [
                        "text": copiedText, 
                        "method": "clipboard",
                        "originalClipboard": originalClipboard ?? ""
                    ]
                )
            }
        }
    }
    
    private func getFocusedElement() -> AXUIElement? {
        NSLog("🔍 AccessibilityManager: Starting getFocusedElement...")
        
        guard let app = NSWorkspace.shared.frontmostApplication else { 
            NSLog("❌ AccessibilityManager: No frontmost application")
            return nil 
        }
        
        NSLog("🔍 AccessibilityManager: Frontmost app: \(app.localizedName ?? "Unknown")")
        
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        
        // Method 1: Try to get focused element directly
        var focusedElement: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        if result == .success, let element = focusedElement {
            NSLog("✅ AccessibilityManager: Found focused element directly")
            let axElement = element as! AXUIElement
            if isTextInputElement(axElement) {
                return axElement
            } else {
                NSLog("🔍 AccessibilityManager: Focused element is not a text input, searching within it...")
                if let textElement = findTextInputInElement(axElement) {
                    return textElement
                }
            }
        } else {
            NSLog("❌ AccessibilityManager: Failed to get focused element directly: \(result)")
        }
        
        // Method 2: For Chrome and other web browsers, try to find text input using different approach
        if app.bundleIdentifier?.contains("chrome") == true || 
           app.bundleIdentifier?.contains("safari") == true ||
           app.bundleIdentifier?.contains("firefox") == true {
            NSLog("🔍 AccessibilityManager: Detected web browser, using browser-specific method...")
            return findTextInputInBrowser(appElement)
        }
        
        // Method 3: Try to find text input in frontmost window
        NSLog("🔍 AccessibilityManager: Trying to find text input in frontmost window...")
        var focusedWindow: CFTypeRef?
        let windowResult = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedWindow)
        
        if windowResult == .success, let window = focusedWindow {
            NSLog("✅ AccessibilityManager: Found focused window")
            let axWindow = window as! AXUIElement
            if let textElement = findTextInputInElement(axWindow) {
                return textElement
            }
        } else {
            NSLog("❌ AccessibilityManager: Failed to get focused window: \(windowResult)")
        }
        
        // Method 4: Search all windows for text input
        NSLog("🔍 AccessibilityManager: Searching all windows for text input...")
        var windows: CFTypeRef?
        let windowsResult = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windows)
        
        if windowsResult == .success, let windowArray = windows as? [AXUIElement] {
            NSLog("✅ AccessibilityManager: Found \(windowArray.count) windows")
            for window in windowArray {
                if let textElement = findTextInputInElement(window) {
                    return textElement
                }
            }
        } else {
            NSLog("❌ AccessibilityManager: Failed to get windows: \(windowsResult)")
        }
        
        NSLog("❌ AccessibilityManager: No text input element found")
        return nil
    }
    
    private func findTextInputInBrowser(_ appElement: AXUIElement) -> AXUIElement? {
        NSLog("🌐 AccessibilityManager: Searching for text input in browser...")
        
        // Try to find web content area first
        if let webArea = findElementWithRole(appElement, role: "AXWebArea") {
            NSLog("✅ AccessibilityManager: Found web area")
            if let textInput = findTextInputInElement(webArea) {
                return textInput
            }
        }
        
        // Try to find any text field in the entire app
        return findElementWithRoles(appElement, roles: [
            kAXTextFieldRole,
            kAXTextAreaRole,
            kAXComboBoxRole,
            "AXTextField",
            "AXTextArea"
        ])
    }
    
    private func findElementWithRole(_ element: AXUIElement, role: String) -> AXUIElement? {
        var elementRole: CFTypeRef?
        let roleResult = AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &elementRole)
        
        if roleResult == .success, let roleString = elementRole as? String, roleString == role {
            return element
        }
        
        // Search children
        var children: CFTypeRef?
        let childrenResult = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children)
        
        if childrenResult == .success, let childArray = children as? [AXUIElement] {
            for child in childArray {
                if let found = findElementWithRole(child, role: role) {
                    return found
                }
            }
        }
        
        return nil
    }
    
    private func findElementWithRoles(_ element: AXUIElement, roles: [String]) -> AXUIElement? {
        var elementRole: CFTypeRef?
        let roleResult = AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &elementRole)
        
        if roleResult == .success, let roleString = elementRole as? String {
            if roles.contains(roleString) && isTextInputElement(element) {
                NSLog("✅ AccessibilityManager: Found text input with role: \(roleString)")
                return element
            }
        }
        
        // Search children recursively
        var children: CFTypeRef?
        let childrenResult = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children)
        
        if childrenResult == .success, let childArray = children as? [AXUIElement] {
            for child in childArray {
                if let found = findElementWithRoles(child, roles: roles) {
                    return found
                }
            }
        }
        
        return nil
    }
    
    private func isTextInputElement(_ element: AXUIElement) -> Bool {
        // Check role
        var role: CFTypeRef?
        let roleResult = AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
        
        if roleResult == .success, let roleString = role as? String {
            NSLog("🔍 AccessibilityManager: Element role: \(roleString)")
            
            let textInputRoles = [
                kAXTextFieldRole,
                kAXTextAreaRole,
                kAXComboBoxRole,
                "AXWebArea",
                "AXTextField",
                "AXTextArea"
            ]
            
            if textInputRoles.contains(roleString) {
                return true
            }
        }
        
        // Check if element has text-related attributes
        var value: CFTypeRef?
        let valueResult = AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &value)
        
        var selectedText: CFTypeRef?
        let selectedResult = AXUIElementCopyAttributeValue(element, kAXSelectedTextAttribute as CFString, &selectedText)
        
        return valueResult == .success || selectedResult == .success
    }
    
    private func findTextInputInElement(_ element: AXUIElement) -> AXUIElement? {
        // Check if this element itself is a text input
        if isTextInputElement(element) {
            return element
        }
        
        // Get children and search recursively
        var children: CFTypeRef?
        let childrenResult = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children)
        
        if childrenResult == .success, let childArray = children as? [AXUIElement] {
            for child in childArray {
                if let textElement = findTextInputInElement(child) {
                    return textElement
                }
            }
        }
        
        return nil
    }
    
    private func getTextFromElement(_ element: AXUIElement) -> String {
        // Get current cursor position
        var insertionPoint: CFTypeRef?
        let _ = AXUIElementCopyAttributeValue(element, kAXInsertionPointLineNumberAttribute as CFString, &insertionPoint)
        
        // Get all text from the element
        var allText: CFTypeRef?
        let allResult = AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &allText)
        
        guard allResult == .success, let fullText = allText as? String, !fullText.isEmpty else {
            return ""
        }
        
        // Get cursor position
        var selectedRange: CFTypeRef?
        let rangeResult = AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &selectedRange)
        
        if rangeResult == .success, let range = selectedRange {
            let cfRange = range as! CFRange
            let cursorPosition = cfRange.location
            
            // If cursor is at the beginning, return all text
            if cursorPosition <= 0 {
                return fullText
            }
            
            // Get text from beginning to cursor position
            let endIndex = min(cursorPosition, fullText.count)
            let textBeforeCursor = String(fullText.prefix(endIndex))
            
            // Select the text before cursor
            var newRange = CFRange(location: 0, length: endIndex)
            let rangeValue = AXValueCreate(AXValueType(rawValue: kAXValueCFRangeType)!, &newRange)!
            AXUIElementSetAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, rangeValue)
            
            return textBeforeCursor
        }
        
        // Fallback: return all text
        return fullText
    }
    
    func replaceTextInElement(_ element: AXUIElement, with newText: String) {
        // First, select all text if nothing is selected
        let _ = AXUIElementSetAttributeValue(element, kAXSelectedTextAttribute as CFString, "" as CFString)
        
        // Set the new text
        let result = AXUIElementSetAttributeValue(element, kAXSelectedTextAttribute as CFString, newText as CFString)
        
        if result != .success {
            // Fallback: try to set the value directly
            let _ = AXUIElementSetAttributeValue(element, kAXValueAttribute as CFString, newText as CFString)
        }
        
        print("Text replacement result: \(result.rawValue)")
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let translateText = Notification.Name("translateText")
    static let textTranslated = Notification.Name("textTranslated")
}

// MARK: - AXError Extension
extension AXError {
    var description: String {
        switch self {
        case .success: return "Success"
        case .failure: return "Failure"
        case .illegalArgument: return "Illegal Argument"
        case .invalidUIElement: return "Invalid UI Element"
        case .invalidUIElementObserver: return "Invalid UI Element Observer"
        case .cannotComplete: return "Cannot Complete"
        case .attributeUnsupported: return "Attribute Unsupported"
        case .actionUnsupported: return "Action Unsupported"
        case .notificationUnsupported: return "Notification Unsupported"
        case .notImplemented: return "Not Implemented"
        case .notificationAlreadyRegistered: return "Notification Already Registered"
        case .notificationNotRegistered: return "Notification Not Registered"
        case .apiDisabled: return "API Disabled"
        case .noValue: return "No Value"
        case .parameterizedAttributeUnsupported: return "Parameterized Attribute Unsupported"
        case .notEnoughPrecision: return "Not Enough Precision"
        @unknown default: return "Unknown Error"
        }
    }
} 