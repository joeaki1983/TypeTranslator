# TypeTranslator

<div align="center">

![TypeTranslator Logo](https://img.shields.io/badge/TypeTranslator-AI%20Translation-blue?style=for-the-badge)
![macOS](https://img.shields.io/badge/macOS-14.0+-000000?style=for-the-badge&logo=apple&logoColor=F0F0F0)
![Swift](https://img.shields.io/badge/swift-5.0-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

macOS 输入框翻译软件，可以在任何输入框内，一键将中文翻译成英文


[下载最新版本](../../releases) • [使用指南](#使用方法) • [API 配置](#支持的-ai-接口)

</div>

## ✨ 功能特点

### 🚀 多接口支持
- **8 种 AI 接口**: OpenAI、Groq、SambaNova、Google Gemini、Azure OpenAI、Ollama、Claude、自定义接口
- **智能切换**: 一键切换不同的 AI 服务
- **本地支持**: Ollama 支持完全离线翻译

### ⚡ 实时翻译
- **全局快捷键**: 选中文本后快速翻译
- **两种模式**: 剪贴板替换 + 原地替换
- **智能识别**: 自动检测文本语言

### 🎛️ 灵活配置
- **温度调节**: 控制翻译的创造性
- **模型选择**: 支持各接口的不同模型
- **API 测试**: 内置连接测试功能

### 🔒 隐私安全
- **本地处理**: 支持 Ollama 本地模型
- **安全存储**: API 密钥安全保存
- **无数据收集**: 不收集用户翻译内容

## 🖥️ 系统要求

- **操作系统**: macOS 14.0 或更高版本
- **架构支持**: Intel 和 Apple Silicon (Universal Binary)
- **网络**: 在线 API 需要网络连接
- **权限**: 辅助功能权限（用于文本选择和替换）

## 📦 安装说明

### 方法一：DMG 安装包（推荐）
1. 从 [Releases](../../releases) 页面下载最新的 `TypeTranslator-v1.0.dmg`
2. 双击 DMG 文件挂载安装包
3. 将 `TypeTranslator.app` 拖拽到 `Applications` 文件夹
4. 首次运行时需要在系统偏好设置中授予辅助功能权限

### 方法二：源码编译
```bash
git clone https://github.com/yourusername/TypeTranslator.git
cd TypeTranslator
open TypeTranslator.xcodeproj
# 在 Xcode 中编译运行
```

## 🚀 使用方法

### 1. 首次设置
1. 启动 TypeTranslator
2. 点击菜单栏图标选择"设置"
3. 选择要使用的 AI 接口
4. 配置相应的 API 密钥和参数
5. 点击"测试 API"验证配置

### 2. 开始翻译
1. 在任意应用中选中要翻译的文本
2. 按下快捷键 `Cmd+Shift+T`（默认）
3. 等待翻译完成，文本将自动替换

### 3. 快捷键说明
- **Cmd+Shift+T**: 翻译选中文本（原地替换）
- **Cmd+Shift+C**: 翻译选中文本（剪贴板模式）

## 🤖 支持的 AI 接口

### 1. OpenAI
- **模型**: GPT-4o, GPT-4o-mini, GPT-4, GPT-3.5-turbo
- **获取**: [OpenAI Platform](https://platform.openai.com)
- **特点**: 高质量翻译，响应快速

### 2. Google Gemini
- **模型**: Gemini-1.5-flash, Gemini-1.5-pro
- **获取**: [Google AI Studio](https://makersuite.google.com)
- **特点**: 多语言支持优秀

### 3. Claude (Anthropic)
- **模型**: Claude-3.5-sonnet, Claude-3-haiku
- **获取**: [Anthropic Console](https://console.anthropic.com)
- **特点**: 理解能力强，翻译自然

### 4. Azure OpenAI
- **配置**: 需要 Azure 订阅和部署
- **获取**: [Azure Portal](https://portal.azure.com)
- **特点**: 企业级服务，稳定可靠

### 5. Ollama (本地)
- **安装**: [Ollama.com](https://ollama.com)
- **模型**: llama3.2, qwen2.5, gemma2, mistral
- **特点**: 完全离线，隐私保护

### 6. Groq
- **模型**: Llama-3.3-70b-versatile 等
- **获取**: [Groq Console](https://console.groq.com)
- **特点**: 推理速度极快

### 7. SambaNova
- **获取**: [SambaNova Cloud](https://cloud.sambanova.ai)
- **特点**: 高性能计算平台

### 8. 自定义接口
- **格式**: 兼容 OpenAI API 格式
- **用途**: 支持私有部署的模型服务

## 🛠️ 开发说明

### 技术栈
- **语言**: Swift 5.0
- **框架**: SwiftUI, AppKit
- **架构**: MVVM
- **最低版本**: macOS 14.0

### 项目结构
```
TypeTranslator/
├── TypeTranslator/
│   ├── Models.swift              # 数据模型和配置
│   ├── TranslationService.swift  # 翻译服务核心
│   ├── SettingsView.swift        # 设置界面
│   ├── ContentView.swift         # 主界面
│   ├── HotKeyManager.swift       # 快捷键管理
│   └── AccessibilityManager.swift # 辅助功能管理
├── build_app.sh                  # 构建脚本
└── README.md                     # 项目说明
```

### 构建项目
```bash
# 克隆项目
git clone https://github.com/yourusername/TypeTranslator.git
cd TypeTranslator

# 使用 Xcode 打开
open TypeTranslator.xcodeproj

# 或使用构建脚本
./build_app.sh
```

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🤝 贡献

欢迎贡献代码！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与项目开发。

## 📞 支持

- 🐛 [报告问题](../../issues)
- 💡 [功能建议](../../issues)
- 📧 [联系作者](mailto:your-email@example.com)

## 🙏 致谢

感谢以下开源项目和服务：
- [OpenAI](https://openai.com) - GPT 模型
- [Anthropic](https://anthropic.com) - Claude 模型
- [Google](https://ai.google.dev) - Gemini 模型
- [Ollama](https://ollama.com) - 本地模型运行
- [Groq](https://groq.com) - 高速推理服务

---

<div align="center">
Made with ❤️ for the macOS community
</div>
