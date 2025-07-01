import SwiftUI
import Carbon

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @State private var showingHotKeyInput = false
    @State private var tempHotKey = ""
    @State private var isTestingAPI = false
    @State private var testResult = ""
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    interfaceSelectionView
                    interfaceConfigurationView
                    translationSettingsView
                    promptSettingsView
                    systemSettingsView
                    hotkeySettingsView
                    statusView
                    saveButtonsView
                }
                .padding()
            }
        }
        .frame(width: 600, height: 700)
        .background(Color(.controlBackgroundColor))
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "gear")
                .font(.title)
                .foregroundColor(.blue)
            
            Text("设置")
                .font(.title)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding()
        .background(Color(.windowBackgroundColor))
    }
    
    private var interfaceSelectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("接口选择")
                .font(.headline)
                .foregroundColor(.primary)
            
            Picker("选择API接口", selection: $settings.selectedInterface) {
                ForEach(APIInterface.allCases) { interface in
                    Text(interface.displayName).tag(interface)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separatorColor), lineWidth: 1)
        )
    }
    
    private var interfaceConfigurationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(settings.selectedInterface.displayName) 配置")
                .font(.headline)
                .foregroundColor(.primary)
            
            switch settings.selectedInterface {
            case .openai:
                openaiConfigView
            case .groq:
                groqConfigView
            case .sambanova:
                sambanovaConfigView
            case .gemini:
                geminiConfigView
            case .azure:
                azureConfigView
            case .ollama:
                ollamaConfigView
            case .claude:
                claudeConfigView
            case .custom:
                customConfigView
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separatorColor), lineWidth: 1)
        )
    }
    
    private var openaiConfigView: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("API Key")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("输入OpenAI API Key", text: $settings.openaiApiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Base URL")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("API基础URL", text: $settings.openaiBaseURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("模型")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("模型名称", text: $settings.openaiModel)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    private var groqConfigView: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("API Key")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("输入Groq API Key", text: $settings.groqApiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("模型")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("模型名称", text: $settings.groqModel)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Text("Base URL: https://api.groq.com/openai/v1")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var sambanovaConfigView: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("API Key")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("输入SambaNova API Key", text: $settings.sambanovaApiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("模型")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("模型名称", text: $settings.sambanovaModel)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Text("Base URL: https://api.sambanova.ai/v1")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var geminiConfigView: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("API Key")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("输入Google Gemini API Key", text: $settings.geminiApiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("模型")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("模型名称", text: $settings.geminiModel)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Text("Base URL: https://generativelanguage.googleapis.com/v1beta")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("常用模型: gemini-1.5-flash, gemini-1.5-pro, gemini-1.0-pro")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var azureConfigView: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("API Key")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("输入Azure OpenAI API Key", text: $settings.azureApiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Endpoint")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("https://your-resource.openai.azure.com", text: $settings.azureEndpoint)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("部署名称")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("部署名称 (Deployment Name)", text: $settings.azureDeploymentName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("API 版本")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("API版本", text: $settings.azureApiVersion)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Text("获取Azure OpenAI服务: https://portal.azure.com")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var ollamaConfigView: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Base URL")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("Ollama服务地址", text: $settings.ollamaBaseURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("模型")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("模型名称", text: $settings.ollamaModel)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Text("默认地址: http://localhost:11434")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("常用模型: llama3.2, qwen2.5, gemma2, mistral")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("安装Ollama: https://ollama.com")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private var claudeConfigView: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("API Key")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("输入Claude API Key", text: $settings.claudeApiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("模型")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("模型名称", text: $settings.claudeModel)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Text("Base URL: https://api.anthropic.com/v1")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("常用模型: claude-3-5-sonnet-20241022, claude-3-haiku-20240307")
                .font(.caption)
                .foregroundColor(.secondary)

            Text("获取API Key: https://console.anthropic.com")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var customConfigView: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("API Key")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("输入API Key", text: $settings.customApiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Base URL")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("API基础URL", text: $settings.customBaseURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("模型")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("模型名称", text: $settings.customModel)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    private var translationSettingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("翻译设置")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Text("温度值")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.1f", settings.temperature))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Slider(value: $settings.temperature, in: 0.0...1.0, step: 0.1)
                .accentColor(.blue)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separatorColor), lineWidth: 1)
        )
    }
    
    private var promptSettingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("翻译 Prompt 设置")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("恢复默认") {
                    resetToDefaultPrompt()
                }
                .buttonStyle(.bordered)
                .font(.caption)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("自定义翻译 Prompt")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("提示：使用 {text} 作为占位符，它将被替换为需要翻译的文本")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.bottom, 4)
                
                // 多行文本编辑器
                TextEditor(text: $settings.customPrompt)
                    .font(.system(.caption, design: .monospaced))
                    .frame(minHeight: 150, maxHeight: 300)
                    .padding(8)
                    .background(Color(.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(.separatorColor), lineWidth: 1)
                    )
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separatorColor), lineWidth: 1)
        )
    }
    
    private var systemSettingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("系统设置")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                Toggle("启用翻译功能", isOn: $settings.isEnabled)
                    .font(.caption)
                
                Toggle("开机自动启动", isOn: $settings.launchAtLogin)
                    .font(.caption)
                    .help("应用将在系统启动时自动运行")
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separatorColor), lineWidth: 1)
        )
    }
    
    private var hotkeySettingsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("快捷键设置")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("当前快捷键:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(getHotkeyString())
                        .font(.system(.caption, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.tertiarySystemFill))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Button("修改") {
                        showingHotKeyInput = true
                    }
                    .buttonStyle(.bordered)
                }
                
                // 快捷键状态指示
                hotKeyStatusView
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separatorColor), lineWidth: 1)
        )
        .sheet(isPresented: $showingHotKeyInput) {
            HotKeyInputView(settings: settings, isPresented: $showingHotKeyInput)
        }
    }
    
    private var statusView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("状态")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: settings.isCurrentInterfaceConfigured() ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(settings.isCurrentInterfaceConfigured() ? .green : .orange)
                
                Text(settings.isCurrentInterfaceConfigured() ? "当前接口配置完整" : "当前接口配置不完整")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if settings.isCurrentInterfaceConfigured() {
                    Button("测试API") {
                        testCurrentAPI()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isTestingAPI)
                }
            }
            
            if isTestingAPI {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("正在测试API连接...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !testResult.isEmpty {
                Text(testResult)
                    .font(.caption)
                    .foregroundColor(testResult.contains("✅") ? .green : .red)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(testResult.contains("✅") ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separatorColor), lineWidth: 1)
        )
    }
    
    private var saveButtonsView: some View {
        HStack(spacing: 12) {
            Button("应用") {
                applySettings()
            }
            .buttonStyle(.borderedProminent)

            Spacer()

            Button("退出") {
                exitSettings()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private func getHotkeyString() -> String {
        var components: [String] = []
        
        if settings.hotKeyModifiers & UInt32(cmdKey) != 0 {
            components.append("⌘")
        }
        if settings.hotKeyModifiers & UInt32(shiftKey) != 0 {
            components.append("⇧")
        }
        if settings.hotKeyModifiers & UInt32(optionKey) != 0 {
            components.append("⌥")
        }
        if settings.hotKeyModifiers & UInt32(controlKey) != 0 {
            components.append("⌃")
        }
        
        let keyChar = getKeyCharFromCode(settings.hotKeyCode)
        components.append(keyChar)
        
        return components.joined()
    }
    
    private func getKeyCharFromCode(_ keyCode: UInt16) -> String {
        switch keyCode {
        // 字母键
        case 0: return "A"
        case 11: return "B"
        case 8: return "C"
        case 2: return "D"
        case 14: return "E"
        case 3: return "F"
        case 5: return "G"
        case 4: return "H"
        case 34: return "I"
        case 38: return "J"
        case 40: return "K"
        case 37: return "L"
        case 46: return "M"
        case 45: return "N"
        case 31: return "O"
        case 35: return "P"
        case 12: return "Q"
        case 15: return "R"
        case 1: return "S"
        case 17: return "T"
        case 32: return "U"
        case 9: return "V"
        case 13: return "W"
        case 7: return "X"
        case 16: return "Y"
        case 6: return "Z"
        
        // 数字键
        case 29: return "0"
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 23: return "5"
        case 22: return "6"
        case 26: return "7"
        case 28: return "8"
        case 25: return "9"
        
        // 标点符号键
        case 44: return "/"
        case 43: return ","
        case 47: return "."
        case 39: return "'"
        case 41: return ";"
        case 27: return "-"
        case 24: return "="
        case 33: return "["
        case 30: return "]"
        case 42: return "\\"
        case 50: return "`"
        
        // 特殊键
        case 49: return "Space"
        case 36: return "Return"
        case 53: return "Esc"
        case 51: return "Delete"
        case 48: return "Tab"
        
        // F键
        case 122: return "F1"
        case 120: return "F2"
        case 99: return "F3"
        case 118: return "F4"
        case 96: return "F5"
        case 97: return "F6"
        case 98: return "F7"
        case 100: return "F8"
        case 101: return "F9"
        case 109: return "F10"
        case 103: return "F11"
        case 111: return "F12"
        
        // 方向键
        case 126: return "↑"
        case 125: return "↓"
        case 123: return "←"
        case 124: return "→"
        
        default: return "Key\(keyCode)"
        }
    }
    
    private var hotKeyStatusView: some View {
        HStack {
            let isAvailable = checkHotKeyAvailability()
            
            Image(systemName: isAvailable ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(isAvailable ? .green : .red)
                .font(.caption)
            
            Text(isAvailable ? "快捷键可用" : "快捷键冲突 - 可能被其他应用占用")
                .font(.caption2)
                .foregroundColor(isAvailable ? .secondary : .red)
            
            Spacer()
        }
    }
    
    private func checkHotKeyAvailability() -> Bool {
        // 检查是否是已知的冲突快捷键
        let conflictingKeys: [(UInt16, UInt32)] = [
            (44, UInt32(cmdKey)), // Cmd+/ (Help菜单)
            (27, UInt32(cmdKey)), // Cmd+- (Zoom Out) 
            (24, UInt32(cmdKey)), // Cmd+= (Zoom In)
            (47, UInt32(cmdKey)), // Cmd+. (Cancel)
        ]
        
        for (keyCode, modifiers) in conflictingKeys {
            if settings.hotKeyCode == keyCode && settings.hotKeyModifiers == modifiers {
                return false
            }
        }
        
        return true
    }
    

}

struct HotKeyInputView: View {
    @ObservedObject var settings: AppSettings
    @Binding var isPresented: Bool
    @State private var isListening = false
    @State private var newHotKey = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("设置快捷键")
                .font(.headline)
            
            if isListening {
                Text("请按下您想要设置的快捷键组合")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("正在监听...")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Text("当前快捷键: \(getCurrentHotkeyString())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Button(isListening ? "停止监听" : "开始设置") {
                    if isListening {
                        isListening = false
                    } else {
                        startListening()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("取消") {
                    isPresented = false
                }
                .buttonStyle(.bordered)
                
                if !isListening {
                    Button("恢复默认") {
                        resetToDefault()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .frame(width: 400, height: 200)
        .onAppear {
            setupKeyMonitor()
        }
    }
    
    private func getCurrentHotkeyString() -> String {
        var components: [String] = []
        
        if settings.hotKeyModifiers & UInt32(cmdKey) != 0 {
            components.append("⌘")
        }
        if settings.hotKeyModifiers & UInt32(shiftKey) != 0 {
            components.append("⇧")
        }
        if settings.hotKeyModifiers & UInt32(optionKey) != 0 {
            components.append("⌥")
        }
        if settings.hotKeyModifiers & UInt32(controlKey) != 0 {
            components.append("⌃")
        }
        
        let keyChar = getKeyCharFromCode(settings.hotKeyCode)
        components.append(keyChar)
        
        return components.joined()
    }
    
    private func getKeyCharFromCode(_ keyCode: UInt16) -> String {
        switch keyCode {
        case 17: return "T"
        case 0: return "A"
        case 11: return "B"
        case 8: return "C"
        case 2: return "D"
        case 14: return "E"
        case 3: return "F"
        case 5: return "G"
        case 4: return "H"
        case 34: return "I"
        case 38: return "J"
        case 40: return "K"
        case 37: return "L"
        case 46: return "M"
        case 45: return "N"
        case 31: return "O"
        case 35: return "P"
        case 12: return "Q"
        case 15: return "R"
        case 1: return "S"
        case 9: return "U"
        case 32: return "V"
        case 13: return "W"
        case 7: return "X"
        case 16: return "Y"
        case 6: return "Z"
        
        // 数字键
        case 29: return "0"
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 23: return "5"
        case 22: return "6"
        case 26: return "7"
        case 28: return "8"
        case 25: return "9"
        
        // 标点符号键
        case 44: return "/"
        case 43: return ","
        case 47: return "."
        case 39: return "'"
        case 41: return ";"
        case 27: return "-"
        case 24: return "="
        case 33: return "["
        case 30: return "]"
        case 42: return "\\"
        case 50: return "`"
        
        // 特殊键
        case 49: return "Space"
        case 36: return "Return"
        case 53: return "Esc"
        case 51: return "Delete"
        case 48: return "Tab"
        
        // F键
        case 122: return "F1"
        case 120: return "F2"
        case 99: return "F3"
        case 118: return "F4"
        case 96: return "F5"
        case 97: return "F6"
        case 98: return "F7"
        case 100: return "F8"
        case 101: return "F9"
        case 109: return "F10"
        case 103: return "F11"
        case 111: return "F12"
        
        // 方向键
        case 126: return "↑"
        case 125: return "↓"
        case 123: return "←"
        case 124: return "→"
        
        default: return "Key\(keyCode)"
    }
    }
    
    private func startListening() {
        isListening = true
    }
    
    private func setupKeyMonitor() {
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            if self.isListening {
                let keyCode = UInt16(event.keyCode)
                let modifierFlags = event.modifierFlags
                
                // 提取修饰键
                var modifiers: UInt32 = 0
                if modifierFlags.contains(.command) {
                    modifiers |= UInt32(cmdKey)
                }
                if modifierFlags.contains(.shift) {
                    modifiers |= UInt32(shiftKey)
                }
                if modifierFlags.contains(.option) {
                    modifiers |= UInt32(optionKey)
                }
                if modifierFlags.contains(.control) {
                    modifiers |= UInt32(controlKey)
                }
                
                // 忽略纯修饰键（没有其他键的情况）
                let modifierKeyCodes: Set<UInt16> = [54, 55, 56, 57, 58, 59, 60, 61, 62]
                if modifierKeyCodes.contains(keyCode) {
                    return nil
                }
                
                // 要求至少有一个修饰键
                if modifiers != 0 {
                    self.settings.hotKeyCode = keyCode
                    self.settings.hotKeyModifiers = modifiers
                    
                    // 保存到UserDefaults
                    UserDefaults.standard.set(Int(keyCode), forKey: "hotKeyCode")
                    UserDefaults.standard.set(Int(modifiers), forKey: "hotKeyModifiers")
                    
                    DispatchQueue.main.async {
                        self.isListening = false
                        self.isPresented = false
                    }
                    
                    NSLog("🔧 New hotkey set: code=\(keyCode), modifiers=\(modifiers)")
                    
                    // 更新快捷键管理器
                    NotificationCenter.default.post(name: Notification.Name("UpdateHotKey"), object: nil)
                }
                return nil // 阻止事件传播
            }
            return event
        }
    }
    
    private func resetToDefault() {
        settings.hotKeyCode = 17 // T key
        settings.hotKeyModifiers = UInt32(cmdKey | shiftKey) // Cmd+Shift
        
        UserDefaults.standard.set(17, forKey: "hotKeyCode")
        UserDefaults.standard.set(Int(UInt32(cmdKey | shiftKey)), forKey: "hotKeyModifiers")
        
        NSLog("🔧 Hotkey reset to default: Cmd+Shift+T")
    }
}

// MARK: - Settings Actions
extension SettingsView {
    private func resetToDefaultPrompt() {
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
        settings.customPrompt = defaultPrompt
    }
    
    private func applySettings() {
        // 应用设置，比如重新注册快捷键等
        NotificationCenter.default.post(name: Notification.Name("UpdateHotKey"), object: nil)
        NSLog("✅ Settings applied")
    }

    private func exitSettings() {
        // 关闭设置窗口
        NSLog("🔍 Attempting to close settings window...")

        // 方法1: 通过窗口标题查找
        if let window = NSApplication.shared.windows.first(where: { $0.title.contains("设置") || $0.title.contains("Settings") }) {
            NSLog("✅ Found settings window by title: \(window.title)")
            window.close()
            return
        }

        // 方法2: 通过内容视图类型查找
        for window in NSApplication.shared.windows {
            if window.contentView is NSHostingView<SettingsView> {
                NSLog("✅ Found settings window by content view")
                window.close()
                return
            }
        }

        // 方法3: 关闭当前活跃窗口（如果是设置窗口）
        if let keyWindow = NSApplication.shared.keyWindow {
            NSLog("✅ Closing key window: \(keyWindow.title)")
            keyWindow.close()
            return
        }

        // 方法4: 关闭主窗口
        if let mainWindow = NSApplication.shared.mainWindow {
            NSLog("✅ Closing main window: \(mainWindow.title)")
            mainWindow.close()
            return
        }

        NSLog("❌ Could not find settings window to close")
    }
}

// MARK: - API测试扩展
extension SettingsView {
    private func testCurrentAPI() {
        isTestingAPI = true
        testResult = "🔄 测试中..."
        
        // 检查配置是否完整
        guard !settings.getCurrentApiKey().isEmpty else {
            testResult = "❌ API密钥为空"
            isTestingAPI = false
            return
        }
        
        // 创建临时的TranslationService实例来测试
        let translationService = TranslationService()
        translationService.settings = settings
        
        // 使用测试文本
        let testText = "你好，这是一个测试。"
        
        translationService.translateText(testText) { result in
            DispatchQueue.main.async {
                self.isTestingAPI = false
                switch result {
                case .success(let translatedText):
                    self.testResult = "✅ API测试成功\n翻译结果: \(translatedText)"
                case .failure(let error):
                    self.testResult = "❌ API测试失败\n错误: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    SettingsView(settings: AppSettings())
} 