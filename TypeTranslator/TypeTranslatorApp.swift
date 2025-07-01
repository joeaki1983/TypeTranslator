import SwiftUI

@main
struct TypeTranslatorApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var accessibilityManager = AccessibilityManager()
    @StateObject private var translationService = TranslationService()
    @StateObject private var hotKeyManager: HotKeyManager
    
    init() {
        let settings = AppSettings()
        let translationService = TranslationService()
        let accessibilityManager = AccessibilityManager()
        
        // Create HotKeyManager with translation callback
        let hotKeyManager = HotKeyManager(onTranslationRequested: {
            NSLog("🔥 Translation requested via hotkey callback!")
            // This will be handled by the notification system
        })
        
        self._settings = StateObject(wrappedValue: settings)
        self._translationService = StateObject(wrappedValue: translationService)
        self._accessibilityManager = StateObject(wrappedValue: accessibilityManager)
        self._hotKeyManager = StateObject(wrappedValue: hotKeyManager)
        
        // Setup translation service callback
        translationService.configure(with: settings)
        
        // Setup hotkey manager
        hotKeyManager.configure(with: settings)
        
        NSLog("✅ TypeTranslatorApp initialized")
    }
    
    var body: some Scene {
        MenuBarExtra("TypeTranslator", systemImage: "globe") {
            ContentView()
                .environmentObject(settings)
                .environmentObject(hotKeyManager)
                .environmentObject(accessibilityManager)
                .environmentObject(translationService)
        }
        .menuBarExtraStyle(.window)
    }
} 