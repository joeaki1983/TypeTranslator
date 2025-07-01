import Foundation
import ApplicationServices
import AppKit

class TranslationService: ObservableObject {
    @Published var status: TranslationStatus = .idle
    @Published var testResult: String = ""
    @Published var isTestingAPI = false
    @Published var isLoading = false
    @Published var lastError: String?
    var settings: AppSettings!
    var accessibilityManager: AccessibilityManager!
    
    private let session = URLSession.shared
    
    init() {
        // Listen for translation requests
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTranslateRequest),
            name: .translateText,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func configure(with settings: AppSettings) {
        self.settings = settings
    }
    
    @objc private func handleTranslateRequest(_ notification: Notification) {
        NSLog("📨 TranslationService: Received translate request notification")
        
        guard let userInfo = notification.userInfo,
              let text = userInfo["text"] as? String else {
            NSLog("❌ TranslationService: Invalid notification data")
            return
        }
        
        NSLog("📝 TranslationService: Text to translate: '\(text)'")
        
        // Check if this is a clipboard method
        let isClipboardMethod = userInfo["method"] as? String == "clipboard"
        let originalClipboard = userInfo["originalClipboard"] as? String ?? ""
        
        if isClipboardMethod {
            NSLog("📋 TranslationService: Using clipboard method")
            
            NSLog("🔄 TranslationService: Starting translation...")
            translateText(text) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let translatedText):
                        NSLog("✅ TranslationService: Translation successful")
                        NSLog("📝 TranslationService: Translated text: '\(translatedText)'")
                        
                        // Put translated text in clipboard
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(translatedText, forType: NSPasteboard.PasteboardType.string)
                        
                        // Simulate Cmd+A to select all text
                        self?.simulateKeyPress(keyCode: 0, modifiers: [.command]) // A key
                        
                        // Wait a bit then paste
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            // Simulate Cmd+V to paste
                            self?.simulateKeyPress(keyCode: 9, modifiers: [.command]) // V key
                            
                            // Restore original clipboard after a delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if !originalClipboard.isEmpty {
                                    pasteboard.clearContents()
                                    pasteboard.setString(originalClipboard, forType: NSPasteboard.PasteboardType.string)
                                }
                            }
                        }
                        
                    case .failure(let error):
                        NSLog("❌ TranslationService: Translation failed: \(error.localizedDescription)")
                        self?.lastError = error.localizedDescription
                    }
                }
            }
        } else {
            // Original accessibility method
            guard let element = userInfo["element"] else {
                NSLog("❌ TranslationService: Invalid element in notification")
                return
            }
            
            let axElement = element as! AXUIElement
            
            NSLog("🔄 TranslationService: Starting translation...")
            translateText(text) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let translatedText):
                        NSLog("✅ TranslationService: Translation successful")
                        NSLog("📝 TranslationService: Translated text: '\(translatedText)'")
                        self?.replaceTextInElement(axElement, with: translatedText)
                        
                    case .failure(let error):
                        NSLog("❌ TranslationService: Translation failed: \(error.localizedDescription)")
                        self?.lastError = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func simulateKeyPress(keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true)
        let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false)
        
        var cgModifiers: CGEventFlags = []
        if modifiers.contains(.command) {
            cgModifiers.insert(.maskCommand)
        }
        if modifiers.contains(.shift) {
            cgModifiers.insert(.maskShift)
        }
        if modifiers.contains(.option) {
            cgModifiers.insert(.maskAlternate)
        }
        if modifiers.contains(.control) {
            cgModifiers.insert(.maskControl)
        }
        
        keyDownEvent?.flags = cgModifiers
        keyUpEvent?.flags = cgModifiers
        
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
    }
    
    private func replaceTextInElement(_ element: AXUIElement, with newText: String) {
        // Set the new text value
        let newValue = newText as CFString
        let result = AXUIElementSetAttributeValue(element, kAXValueAttribute as CFString, newValue)
        
        if result == .success {
            NSLog("✅ TranslationService: Text replaced successfully")
        } else {
            NSLog("❌ TranslationService: Failed to replace text: \(result)")
        }
    }
    
    private func getCurrentInterface() -> APIInterface {
        guard let settings = settings else { return .openai }
        return settings.selectedInterface
    }
    
    private func getModelName() -> String {
        guard let settings = settings else { return "gpt-3.5-turbo" }
        return settings.getCurrentModel()
    }
    
    private func getAPIURL() -> URL {
        guard let settings = settings else {
            return URL(string: "https://api.openai.com/v1/chat/completions")!
        }

        let baseURL = settings.getCurrentBaseURL()
        let cleanBaseURL = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL

        // 对于特殊API，使用不同的URL结构
        switch settings.selectedInterface {
        case .gemini:
            let model = settings.getCurrentModel()
            let apiKey = settings.getCurrentApiKey()

            // URL编码API Key以处理特殊字符
            guard let encodedApiKey = apiKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                NSLog("❌ TranslationService: Failed to encode Gemini API key")
                return URL(string: "https://api.openai.com/v1/chat/completions")!
            }

            let fullURL = "\(cleanBaseURL)/models/\(model):generateContent?key=\(encodedApiKey)"

            NSLog("🌐 TranslationService: Using Gemini API URL: \(fullURL)")

            guard let url = URL(string: fullURL) else {
                NSLog("❌ TranslationService: Invalid Gemini URL, falling back to OpenAI")
                return URL(string: "https://api.openai.com/v1/chat/completions")!
            }
            return url

        case .azure:
            let deploymentName = settings.azureDeploymentName
            let apiVersion = settings.azureApiVersion
            let fullURL = "\(cleanBaseURL)/openai/deployments/\(deploymentName)/chat/completions?api-version=\(apiVersion)"

            NSLog("🌐 TranslationService: Using Azure API URL: \(fullURL)")

            guard let url = URL(string: fullURL) else {
                NSLog("❌ TranslationService: Invalid Azure URL, falling back to OpenAI")
                return URL(string: "https://api.openai.com/v1/chat/completions")!
            }
            return url

        case .claude:
            let fullURL = "\(cleanBaseURL)/messages"

            NSLog("🌐 TranslationService: Using Claude API URL: \(fullURL)")

            guard let url = URL(string: fullURL) else {
                NSLog("❌ TranslationService: Invalid Claude URL, falling back to OpenAI")
                return URL(string: "https://api.openai.com/v1/chat/completions")!
            }
            return url

        case .ollama:
            let fullURL = "\(cleanBaseURL)/api/generate"

            NSLog("🌐 TranslationService: Using Ollama API URL: \(fullURL)")

            guard let url = URL(string: fullURL) else {
                NSLog("❌ TranslationService: Invalid Ollama URL, falling back to OpenAI")
                return URL(string: "https://api.openai.com/v1/chat/completions")!
            }
            return url

        default:
            break
        }

        // 对于其他API，使用OpenAI兼容的格式
        let fullURL: String
        if cleanBaseURL.contains("/chat/completions") {
            // 用户已经提供了完整路径，直接使用
            fullURL = cleanBaseURL
        } else if cleanBaseURL.hasSuffix("/v1") {
            // 用户提供了到v1的路径，只需添加/chat/completions
            fullURL = "\(cleanBaseURL)/chat/completions"
        } else {
            // 用户只提供了基础URL，需要添加完整路径
            fullURL = "\(cleanBaseURL)/v1/chat/completions"
        }

        NSLog("🌐 TranslationService: Using API URL: \(fullURL)")

        guard let url = URL(string: fullURL) else {
            NSLog("❌ TranslationService: Invalid URL, falling back to OpenAI")
            return URL(string: "https://api.openai.com/v1/chat/completions")!
        }
        return url
    }
    
    func translateText(_ text: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let settings = settings else {
            completion(.failure(NSError(domain: "TranslationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Settings not available"])))
            return
        }
        
        guard !settings.getCurrentApiKey().isEmpty else {
            completion(.failure(NSError(domain: "TranslationService", code: 2, userInfo: [NSLocalizedDescriptionKey: "API key not configured"])))
            return
        }
        
        // 使用用户自定义的 prompt，并替换 {text} 占位符
        let prompt = settings.customPrompt.replacingOccurrences(of: "{text}", with: text)

        let apiURL = getAPIURL()
        NSLog("🌐 TranslationService: Using API URL: \(apiURL.absoluteString)")
        NSLog("🔑 TranslationService: Using provider: \(settings.selectedInterface.displayName)")
        NSLog("🤖 TranslationService: Using model: \(getModelName())")

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any]

        switch settings.selectedInterface {
        case .gemini:
            // Gemini API格式
            requestBody = [
                "contents": [
                    [
                        "parts": [
                            [
                                "text": prompt
                            ]
                        ]
                    ]
                ],
                "generationConfig": [
                    "temperature": settings.temperature
                ]
            ]
            // Gemini API不需要Authorization header，API key在URL中
            NSLog("🔍 Gemini request body: \(requestBody)")

        case .claude:
            // Claude API格式
            requestBody = [
                "model": getModelName(),
                "max_tokens": 4096,
                "messages": [
                    [
                        "role": "user",
                        "content": prompt
                    ]
                ],
                "temperature": settings.temperature
            ]
            request.setValue(settings.getCurrentApiKey(), forHTTPHeaderField: "x-api-key")
            request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
            NSLog("🔍 Claude request body: \(requestBody)")

        case .azure:
            // Azure OpenAI格式（与OpenAI兼容）
            requestBody = [
                "messages": [
                    [
                        "role": "user",
                        "content": prompt
                    ]
                ],
                "temperature": settings.temperature,
                "max_tokens": 4096
            ]
            request.setValue(settings.getCurrentApiKey(), forHTTPHeaderField: "api-key")
            NSLog("🔍 Azure request body: \(requestBody)")

        case .ollama:
            // Ollama API格式
            requestBody = [
                "model": getModelName(),
                "prompt": prompt,
                "stream": false,
                "options": [
                    "temperature": settings.temperature
                ]
            ]
            // Ollama通常不需要API Key
            NSLog("🔍 Ollama request body: \(requestBody)")

        default:
            // OpenAI兼容格式 (OpenAI, Groq, SambaNova, Custom)
            requestBody = [
                "model": getModelName(),
                "messages": [
                    [
                        "role": "user",
                        "content": prompt
                    ]
                ],
                "temperature": settings.temperature
            ]
            request.setValue("Bearer \(settings.getCurrentApiKey())", forHTTPHeaderField: "Authorization")
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        makeAPIRequest(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    var content: String?

                    switch settings.selectedInterface {
                    case .gemini:
                        // 解析Gemini API响应格式
                        if let candidates = json?["candidates"] as? [[String: Any]],
                           let firstCandidate = candidates.first,
                           let contentObj = firstCandidate["content"] as? [String: Any],
                           let parts = contentObj["parts"] as? [[String: Any]],
                           let firstPart = parts.first,
                           let text = firstPart["text"] as? String {
                            content = text
                        } else {
                            // 检查是否有错误信息
                            if let error = json?["error"] as? [String: Any],
                               let message = error["message"] as? String {
                                NSLog("❌ Gemini API Error: \(message)")
                                completion(.failure(NSError(domain: "TranslationService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Gemini API Error: \(message)"])))
                                return
                            } else {
                                NSLog("❌ Gemini API: Unexpected response format")
                                NSLog("Response JSON: \(json ?? [:])")
                            }
                        }

                    case .claude:
                        // 解析Claude API响应格式
                        if let contentArray = json?["content"] as? [[String: Any]],
                           let firstContent = contentArray.first,
                           let text = firstContent["text"] as? String {
                            content = text
                        } else {
                            NSLog("❌ Claude API: Unexpected response format")
                            NSLog("Response JSON: \(json ?? [:])")
                        }

                    case .ollama:
                        // 解析Ollama API响应格式
                        if let response = json?["response"] as? String {
                            content = response
                        } else {
                            NSLog("❌ Ollama API: Unexpected response format")
                            NSLog("Response JSON: \(json ?? [:])")
                        }

                    default:
                        // 解析OpenAI兼容格式 (OpenAI, Groq, SambaNova, Azure, Custom)
                        if let choices = json?["choices"] as? [[String: Any]],
                           let firstChoice = choices.first,
                           let message = firstChoice["message"] as? [String: Any],
                           let text = message["content"] as? String {
                            content = text
                        } else {
                            NSLog("❌ OpenAI-compatible API: Unexpected response format")
                            NSLog("Response JSON: \(json ?? [:])")
                        }
                    }

                    if let content = content {
                        // Clean the response to remove thinking process and prompts
                        let cleanedContent = self.cleanTranslationResponse(content)
                        completion(.success(cleanedContent))
                    } else {
                        completion(.failure(NSError(domain: "TranslationService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func cleanTranslationResponse(_ response: String) -> String {
        NSLog("🧹 TranslationService: Original response: \(response.prefix(300))...")
        
        var cleaned = response
        
        // Step 1: Remove <think>...</think> blocks (including multiline content)
        let thinkPattern = "<think>[\\s\\S]*?</think>"
        cleaned = cleaned.replacingOccurrences(of: thinkPattern, with: "", options: [.regularExpression, .caseInsensitive])
        NSLog("🧹 TranslationService: After removing <think> tags: \(cleaned.prefix(200))...")
        
        // Step 2: Remove the prompt section (from "Translate the following" to "Chinese text to translate:")
        let promptPattern = "Translate the following Chinese text to English\\.[\\s\\S]*?Chinese text to translate:"
        cleaned = cleaned.replacingOccurrences(of: promptPattern, with: "", options: [.regularExpression, .caseInsensitive])
        NSLog("🧹 TranslationService: After removing prompt: \(cleaned.prefix(200))...")
        
        // Step 3: Clean up any remaining instruction lines
        let lines = cleaned.components(separatedBy: .newlines)
        let filteredLines = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Keep empty lines for formatting
            if trimmed.isEmpty {
                return true
            }
            
            // Filter out obvious instruction lines
            let instructionKeywords = [
                "IMPORTANT REQUIREMENTS:",
                "Maintain the exact",
                "Preserve all whitespace",
                "Keep the same number",
                "Do not add any",
                "Only return the"
            ]
            
            for keyword in instructionKeywords {
                if trimmed.contains(keyword) {
                    return false
                }
            }
            
            return true
        }
        
        cleaned = filteredLines.joined(separator: "\n")
        
        // Step 4: Final cleanup - trim whitespace but preserve structure
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        NSLog("🧹 TranslationService: Final cleaned result: \(cleaned)")
        
        return cleaned
    }
    
    private func makeAPIRequest(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        NSLog("🚀 TranslationService: Making API request to: \(request.url?.absoluteString ?? "unknown")")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("❌ TranslationService: Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                NSLog("📡 TranslationService: HTTP Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    let statusError = NSError(
                        domain: "TranslationService", 
                        code: httpResponse.statusCode, 
                        userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"]
                    )
                    completion(.failure(statusError))
                    return
                }
            }
            
            guard let data = data else {
                NSLog("❌ TranslationService: No data received")
                completion(.failure(NSError(domain: "TranslationService", code: 4, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            NSLog("✅ TranslationService: Received \(data.count) bytes of data")
            completion(.success(data))
        }.resume()
    }
    
    func testAPI() {
        guard let settings = settings else {
            testResult = "❌ 设置不可用"
            return
        }
        
        guard !settings.getCurrentApiKey().isEmpty else {
            testResult = "❌ API密钥为空"
            return
        }
        
        isTestingAPI = true
        testResult = "🔄 测试中..."
        
        let testText = "Hello, this is a test."
        translateText(testText) { [weak self] result in
            DispatchQueue.main.async {
                self?.isTestingAPI = false
                switch result {
                case .success(let translatedText):
                    self?.testResult = "✅ API测试成功\n翻译结果: \(translatedText)"
                case .failure(let error):
                    self?.testResult = "❌ API测试失败\n错误: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Translation Errors
enum TranslationError: LocalizedError {
    case noAPIKey
    case invalidURL
    case noData
    case noTranslation
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "API key is required"
        case .invalidURL:
            return "Invalid API URL"
        case .noData:
            return "No data received from API"
        case .noTranslation:
            return "No translation received"
        case .apiError(let message):
            return "API Error: \(message)"
        }
    }
} 