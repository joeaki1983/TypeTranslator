import Foundation
import Carbon
import ServiceManagement
import CoreServices

// MARK: - API Interface Selection
enum APIInterface: String, CaseIterable, Identifiable {
    case openai = "OpenAI"
    case groq = "Groq"
    case sambanova = "SambaNova"
    case gemini = "Gemini"
    case azure = "Azure"
    case ollama = "Ollama"
    case claude = "Claude"
    case custom = "Custom"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .openai:
            return "OpenAI"
        case .groq:
            return "Groq"
        case .sambanova:
            return "SambaNova"
        case .gemini:
            return "Google Gemini"
        case .azure:
            return "Azure OpenAI"
        case .ollama:
            return "Ollama (本地)"
        case .claude:
            return "Claude (Anthropic)"
        case .custom:
            return "自定义接口"
        }
    }
}

// MARK: - LLM Provider Models (保留用于兼容性)
enum LLMProvider: String, CaseIterable, Identifiable {
    case openai = "OpenAI"
    case claude = "Claude"
    case deepseek = "Deepseek"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    var baseURL: String {
        switch self {
        case .openai:
            return "https://api.openai.com/v1"
        case .claude:
            return "https://api.anthropic.com/v1"
        case .deepseek:
            return "https://api.deepseek.com/v1"
        case .custom:
            return ""
        }
    }
    
    var models: [String] {
        switch self {
        case .openai:
            return ["gpt-4o", "gpt-4o-mini", "gpt-4", "gpt-3.5-turbo"]
        case .claude:
            return ["claude-3-5-sonnet-20241022", "claude-3-haiku-20240307", "claude-3-opus-20240229"]
        case .deepseek:
            return ["deepseek-reasoner", "deepseek-chat"]
        case .custom:
            return []
        }
    }
}

// MARK: - Translation Request/Response Models
struct TranslationRequest: Codable {
    let model: String
    let messages: [Message]
    let temperature: Double
    let maxTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct Message: Codable {
    let role: String
    let content: String
}

struct TranslationResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

// MARK: - Settings Model
class AppSettings: ObservableObject {
    // 当前选择的接口
    @Published var selectedInterface: APIInterface {
        didSet {
            UserDefaults.standard.set(selectedInterface.rawValue, forKey: "selectedInterface")
        }
    }
    
    // OpenAI接口配置
    @Published var openaiApiKey: String {
        didSet {
            UserDefaults.standard.set(openaiApiKey, forKey: "openaiApiKey")
        }
    }
    
    @Published var openaiModel: String {
        didSet {
            UserDefaults.standard.set(openaiModel, forKey: "openaiModel")
        }
    }
    
    @Published var openaiBaseURL: String {
        didSet {
            UserDefaults.standard.set(openaiBaseURL, forKey: "openaiBaseURL")
        }
    }
    
    // Groq接口配置
    @Published var groqApiKey: String {
        didSet {
            UserDefaults.standard.set(groqApiKey, forKey: "groqApiKey")
        }
    }
    
    @Published var groqModel: String {
        didSet {
            UserDefaults.standard.set(groqModel, forKey: "groqModel")
        }
    }
    
    // SambaNova接口配置
    @Published var sambanovaApiKey: String {
        didSet {
            UserDefaults.standard.set(sambanovaApiKey, forKey: "sambanovaApiKey")
        }
    }

    @Published var sambanovaModel: String {
        didSet {
            UserDefaults.standard.set(sambanovaModel, forKey: "sambanovaModel")
        }
    }

    // Gemini接口配置
    @Published var geminiApiKey: String {
        didSet {
            UserDefaults.standard.set(geminiApiKey, forKey: "geminiApiKey")
        }
    }

    @Published var geminiModel: String {
        didSet {
            UserDefaults.standard.set(geminiModel, forKey: "geminiModel")
        }
    }

    // Azure OpenAI接口配置
    @Published var azureApiKey: String {
        didSet {
            UserDefaults.standard.set(azureApiKey, forKey: "azureApiKey")
        }
    }

    @Published var azureEndpoint: String {
        didSet {
            UserDefaults.standard.set(azureEndpoint, forKey: "azureEndpoint")
        }
    }

    @Published var azureDeploymentName: String {
        didSet {
            UserDefaults.standard.set(azureDeploymentName, forKey: "azureDeploymentName")
        }
    }

    @Published var azureApiVersion: String {
        didSet {
            UserDefaults.standard.set(azureApiVersion, forKey: "azureApiVersion")
        }
    }

    // Ollama接口配置
    @Published var ollamaBaseURL: String {
        didSet {
            UserDefaults.standard.set(ollamaBaseURL, forKey: "ollamaBaseURL")
        }
    }

    @Published var ollamaModel: String {
        didSet {
            UserDefaults.standard.set(ollamaModel, forKey: "ollamaModel")
        }
    }

    // Claude接口配置
    @Published var claudeApiKey: String {
        didSet {
            UserDefaults.standard.set(claudeApiKey, forKey: "claudeApiKey")
        }
    }

    @Published var claudeModel: String {
        didSet {
            UserDefaults.standard.set(claudeModel, forKey: "claudeModel")
        }
    }
    
    // 自定义接口配置
    @Published var customApiKey: String {
        didSet {
            UserDefaults.standard.set(customApiKey, forKey: "customApiKey")
        }
    }
    
    @Published var customBaseURL: String {
        didSet {
            UserDefaults.standard.set(customBaseURL, forKey: "customBaseURL")
        }
    }
    
    @Published var customModel: String {
        didSet {
            UserDefaults.standard.set(customModel, forKey: "customModel")
        }
    }
    
    // 保留用于兼容性
    @Published var selectedProvider: LLMProvider {
        didSet {
            UserDefaults.standard.set(selectedProvider.rawValue, forKey: "selectedProvider")
        }
    }
    
    @Published var selectedModel: String {
        didSet {
            UserDefaults.standard.set(selectedModel, forKey: "selectedModel")
        }
    }
    
    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "apiKey")
        }
    }
    
    @Published var hotKeyCode: UInt16 {
        didSet {
            UserDefaults.standard.set(hotKeyCode, forKey: "hotKeyCode")
        }
    }
    
    @Published var hotKeyModifiers: UInt32 {
        didSet {
            UserDefaults.standard.set(hotKeyModifiers, forKey: "hotKeyModifiers")
        }
    }
    
    @Published var temperature: Double {
        didSet {
            UserDefaults.standard.set(temperature, forKey: "temperature")
        }
    }
    
    // 自定义 Prompt
    @Published var customPrompt: String {
        didSet {
            UserDefaults.standard.set(customPrompt, forKey: "customPrompt")
        }
    }
    
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "isEnabled")
        }
    }
    
    // 开机启动设置
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            setLaunchAtLogin(enabled: launchAtLogin)
        }
    }
    
    // 翻译设置
    @Published var targetLanguage: String {
        didSet {
            UserDefaults.standard.set(targetLanguage, forKey: "targetLanguage")
        }
    }
    
    @Published var autoDetect: Bool {
        didSet {
            UserDefaults.standard.set(autoDetect, forKey: "autoDetect")
        }
    }
    
    init() {
        // 初始化新的接口配置
        self.selectedInterface = APIInterface(rawValue: UserDefaults.standard.string(forKey: "selectedInterface") ?? "") ?? .openai
        
        // OpenAI配置
        self.openaiApiKey = UserDefaults.standard.string(forKey: "openaiApiKey") ?? ""
        self.openaiModel = UserDefaults.standard.string(forKey: "openaiModel") ?? "gpt-4o-mini"
        self.openaiBaseURL = UserDefaults.standard.string(forKey: "openaiBaseURL") ?? "https://api.openai.com/v1"
        
        // Groq配置
        self.groqApiKey = UserDefaults.standard.string(forKey: "groqApiKey") ?? ""
        self.groqModel = UserDefaults.standard.string(forKey: "groqModel") ?? "llama-3.3-70b-versatile"
        
        // SambaNova配置
        self.sambanovaApiKey = UserDefaults.standard.string(forKey: "sambanovaApiKey") ?? ""
        self.sambanovaModel = UserDefaults.standard.string(forKey: "sambanovaModel") ?? "Meta-Llama-3.1-70B-Instruct"

        // Gemini配置
        self.geminiApiKey = UserDefaults.standard.string(forKey: "geminiApiKey") ?? ""
        self.geminiModel = UserDefaults.standard.string(forKey: "geminiModel") ?? "gemini-1.5-flash"

        // Azure配置
        self.azureApiKey = UserDefaults.standard.string(forKey: "azureApiKey") ?? ""
        self.azureEndpoint = UserDefaults.standard.string(forKey: "azureEndpoint") ?? ""
        self.azureDeploymentName = UserDefaults.standard.string(forKey: "azureDeploymentName") ?? ""
        self.azureApiVersion = UserDefaults.standard.string(forKey: "azureApiVersion") ?? "2024-02-15-preview"

        // Ollama配置
        self.ollamaBaseURL = UserDefaults.standard.string(forKey: "ollamaBaseURL") ?? "http://localhost:11434"
        self.ollamaModel = UserDefaults.standard.string(forKey: "ollamaModel") ?? "llama3.2"

        // Claude配置
        self.claudeApiKey = UserDefaults.standard.string(forKey: "claudeApiKey") ?? ""
        self.claudeModel = UserDefaults.standard.string(forKey: "claudeModel") ?? "claude-3-5-sonnet-20241022"
        
        // 自定义配置
        self.customApiKey = UserDefaults.standard.string(forKey: "customApiKey") ?? ""
        self.customBaseURL = UserDefaults.standard.string(forKey: "customBaseURL") ?? ""
        self.customModel = UserDefaults.standard.string(forKey: "customModel") ?? ""
        
        // 保留兼容性字段
        self.selectedProvider = LLMProvider(rawValue: UserDefaults.standard.string(forKey: "selectedProvider") ?? "") ?? .openai
        self.selectedModel = UserDefaults.standard.string(forKey: "selectedModel") ?? ""
        self.apiKey = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        
        // 读取快捷键设置
        self.hotKeyCode = UserDefaults.standard.object(forKey: "hotKeyCode") as? UInt16 ?? 11
        self.hotKeyModifiers = UserDefaults.standard.object(forKey: "hotKeyModifiers") as? UInt32 ?? 1572864
        
        // 读取温度设置
        self.temperature = UserDefaults.standard.double(forKey: "temperature") == 0 ? 0.3 : UserDefaults.standard.double(forKey: "temperature")
        
        // 读取自定义 Prompt 设置
        let defaultPrompt = """
Translate the following Chinese text to English.

IMPORTANT REQUIREMENTS:
1. Maintain the exact original formatting, paragraph structure, and line breaks
2. Preserve all whitespace, indentation, and spacing
3. Keep the same number of lines and paragraphs
4. Do not add any explanations, notes, or reasoning process
5. Only return the English translation exactly as formatted in the original

Chinese text to translate:
{text}
"""
        self.customPrompt = UserDefaults.standard.string(forKey: "customPrompt") ?? defaultPrompt
        
        // 读取翻译设置
        self.targetLanguage = UserDefaults.standard.string(forKey: "targetLanguage") ?? "英语"
        self.autoDetect = UserDefaults.standard.bool(forKey: "autoDetect")
        
        // 读取isEnabled设置，默认为true
        if UserDefaults.standard.object(forKey: "isEnabled") == nil {
            self.isEnabled = true
        } else {
            self.isEnabled = UserDefaults.standard.bool(forKey: "isEnabled")
        }
        
        // 读取launchAtLogin设置，默认为false
        if UserDefaults.standard.object(forKey: "launchAtLogin") == nil {
            self.launchAtLogin = false
        } else {
            self.launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
        }
        
        // 记录日志
        NSLog("🔧 Loaded saved hotkey: code=\(self.hotKeyCode), modifiers=\(self.hotKeyModifiers)")
        NSLog("🔧 Loaded saved isEnabled: \(self.isEnabled)")
        NSLog("🔧 Loaded saved launchAtLogin: \(self.launchAtLogin)")
        
        // Update model if provider changed
        if selectedModel.isEmpty || !selectedProvider.models.contains(selectedModel) {
            selectedModel = selectedProvider.models.first ?? ""
        }
        
        NSLog("🔧 AppSettings initialized - isEnabled: \(isEnabled), hotKeyCode: \(hotKeyCode), hotKeyModifiers: \(hotKeyModifiers)")
    }
    
    // MARK: - 便利方法
    /// 获取当前选择接口的API Key
    func getCurrentApiKey() -> String {
        switch selectedInterface {
        case .openai:
            return openaiApiKey
        case .groq:
            return groqApiKey
        case .sambanova:
            return sambanovaApiKey
        case .gemini:
            return geminiApiKey
        case .azure:
            return azureApiKey
        case .ollama:
            return "" // Ollama通常不需要API Key
        case .claude:
            return claudeApiKey
        case .custom:
            return customApiKey
        }
    }
    
    /// 获取当前选择接口的Base URL
    func getCurrentBaseURL() -> String {
        switch selectedInterface {
        case .openai:
            return openaiBaseURL
        case .groq:
            return "https://api.groq.com/openai/v1"
        case .sambanova:
            return "https://api.sambanova.ai/v1"
        case .gemini:
            return "https://generativelanguage.googleapis.com/v1beta"
        case .azure:
            return azureEndpoint
        case .ollama:
            return ollamaBaseURL
        case .claude:
            return "https://api.anthropic.com/v1"
        case .custom:
            return customBaseURL
        }
    }
    
    /// 获取当前选择接口的模型
    func getCurrentModel() -> String {
        switch selectedInterface {
        case .openai:
            return openaiModel
        case .groq:
            return groqModel
        case .sambanova:
            return sambanovaModel
        case .gemini:
            return geminiModel
        case .azure:
            return azureDeploymentName
        case .ollama:
            return ollamaModel
        case .claude:
            return claudeModel
        case .custom:
            return customModel
        }
    }
    
    /// 检查当前选择的接口是否已配置
    func isCurrentInterfaceConfigured() -> Bool {
        switch selectedInterface {
        case .openai:
            return !openaiApiKey.isEmpty
        case .groq:
            return !groqApiKey.isEmpty
        case .sambanova:
            return !sambanovaApiKey.isEmpty
        case .gemini:
            return !geminiApiKey.isEmpty
        case .azure:
            return !azureApiKey.isEmpty && !azureEndpoint.isEmpty && !azureDeploymentName.isEmpty
        case .ollama:
            return !ollamaBaseURL.isEmpty && !ollamaModel.isEmpty
        case .claude:
            return !claudeApiKey.isEmpty
        case .custom:
            return !customApiKey.isEmpty && !customBaseURL.isEmpty
        }
    }
    
    // MARK: - 开机启动管理
    private func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            // 使用现代的Service Management API
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                    NSLog("✅ Launch at login enabled using SMAppService")
                } else {
                    try SMAppService.mainApp.unregister()
                    NSLog("✅ Launch at login disabled using SMAppService")
                }
            } catch {
                NSLog("❌ Failed to set launch at login: \(error)")
            }
        } else {
            // 对于较老的macOS版本，记录但不执行
            NSLog("⚠️ Launch at login requires macOS 13.0 or later")
        }
    }
}

// MARK: - Translation Status
enum TranslationStatus {
    case idle
    case translating
    case success
    case error(String)
} 