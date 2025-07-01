import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var hotKeyManager: HotKeyManager
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    @EnvironmentObject var translationService: TranslationService

    
    var body: some View {
        VStack(spacing: 16) {
            headerSection
            
            statusSection
            
            quickActionsSection
            
            Divider()
            
            settingsButton
        }
        .padding()
        .frame(width: 280)
        .onAppear {
            let _ = accessibilityManager.checkAccessibilityPermission()
            hotKeyManager.configure(with: settings)
        }
    }
    
    private var headerSection: some View {
        HStack {
            Image(systemName: "globe")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text("Type Translator")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(statusColor)
            }
            
            Spacer()
        }
    }
    
    private var statusSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "keyboard")
                    Text("Hotkey: \(currentHotKeyString)")
                    Spacer()
                    Image(systemName: hotKeyManager.isListening ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(hotKeyManager.isListening ? .green : .red)
                }
                
                HStack {
                    Image(systemName: "accessibility")
                    Text("Accessibility")
                    Spacer()
                    Image(systemName: accessibilityManager.hasAccessibilityPermission ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(accessibilityManager.hasAccessibilityPermission ? .green : .red)
                }
                
                HStack {
                    Image(systemName: "brain")
                    Text("\(settings.selectedInterface.rawValue)")
                    Spacer()
                    Image(systemName: settings.getCurrentApiKey().isEmpty ? "xmark.circle.fill" : "checkmark.circle.fill")
                        .foregroundColor(settings.getCurrentApiKey().isEmpty ? .red : .green)
                }
            }
            .font(.system(size: 11))
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 8) {
            if !accessibilityManager.hasAccessibilityPermission {
                Button(action: {
                    accessibilityManager.requestAccessibilityPermission()
                }) {
                    HStack {
                        Image(systemName: "accessibility")
                        Text("Grant Accessibility Access")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            
            Button(action: {
                hotKeyManager.toggleEnabled()
            }) {
                HStack {
                    Image(systemName: settings.isEnabled ? "pause.fill" : "play.fill")
                    Text(settings.isEnabled ? "Disable" : "Enable")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var settingsButton: some View {
        VStack(spacing: 8) {
            Button("Open Settings...") {
                openSettingsWindow()
            }
            .buttonStyle(.link)
            
            Divider()
            
            Button("Quit TypeTranslator") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.link)
            .foregroundColor(.red)
        }
    }
    
    private func openSettingsWindow() {
        NSLog("🔧 Opening settings window...")
        
        // 首先尝试查找现有的设置窗口
        let existingSettingsWindow = NSApp.windows.first { window in
            if window.contentViewController is NSHostingController<SettingsView> {
                return true
            }
            return window.title.lowercased().contains("settings") || 
                   window.title.lowercased().contains("设置") ||
                   window.title.lowercased().contains("preferences")
        }
        
        if let existingWindow = existingSettingsWindow {
            NSLog("✅ Found existing settings window, bringing to front")
            existingWindow.makeKeyAndOrderFront(nil)
            existingWindow.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
            return
        }
        
        NSLog("🔧 Creating new settings window")
        
        // 创建新的设置窗口
        let settingsView = SettingsView(settings: settings)
            .environmentObject(hotKeyManager)
        
        let hostingController = NSHostingController(rootView: settingsView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 700),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.center()
        window.setFrameAutosaveName("SettingsWindow")
        window.contentViewController = hostingController
        window.title = "TypeTranslator Settings"
        window.isReleasedWhenClosed = false  // 重要：防止窗口释放导致应用退出
        
        // 设置窗口级别和行为
        window.level = .normal
        window.isMovableByWindowBackground = true
        
        NSLog("✅ Settings window created and configured")
        
        // 显示窗口并激活应用
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        
        NSLog("✅ Settings window displayed and activated")
    }
    
    private var statusText: String {
        switch translationService.status {
        case .idle:
            return hotKeyManager.isListening ? "Ready" : "Disabled"
        case .translating:
            return "Translating..."
        case .success:
            return "Translation complete"
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    private var statusColor: Color {
        switch translationService.status {
        case .idle:
            return hotKeyManager.isListening ? .green : .secondary
        case .translating:
            return .blue
        case .success:
            return .green
        case .error:
            return .red
        }
    }
    
    private var currentHotKeyString: String {
        let modifiers = HotKeyManager.modifiersToString(settings.hotKeyModifiers)
        let key = HotKeyManager.keyCodeToString(settings.hotKeyCode)
        return "\(modifiers)\(key)"
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSettings())
        .environmentObject(HotKeyManager())
        .environmentObject(AccessibilityManager())
        .environmentObject(TranslationService())
} 