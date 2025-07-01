# TypeTranslator v1.0.0 - Multi-AI Interface Support

## 🎉 首个正式版本发布

TypeTranslator 是一款功能强大的 macOS AI 翻译工具，支持 8 种不同的 AI 接口，提供实时、准确的文本翻译服务。

## ✨ 主要功能

### 🚀 多接口支持
- **OpenAI**: GPT-4o, GPT-4o-mini, GPT-4, GPT-3.5-turbo
- **Google Gemini**: Gemini-1.5-flash, Gemini-1.5-pro, Gemini-1.0-pro
- **Claude (Anthropic)**: Claude-3.5-sonnet, Claude-3-haiku, Claude-3-opus
- **Azure OpenAI**: 企业级 OpenAI 服务
- **Ollama**: 本地模型支持（llama3.2, qwen2.5, gemma2, mistral）
- **Groq**: 高速推理服务（Llama-3.3-70b-versatile）
- **SambaNova**: 高性能计算平台
- **自定义接口**: 支持任何 OpenAI 兼容的 API

### ⚡ 实时翻译
- **全局快捷键**: 选中文本后快速翻译（默认 Cmd+Shift+T）
- **两种模式**: 
  - 剪贴板模式：翻译结果复制到剪贴板
  - 原地替换：直接替换选中的文本
- **智能识别**: 自动检测文本语言并翻译

### 🎛️ 灵活配置
- **温度调节**: 控制翻译的创造性（0.0-2.0）
- **模型选择**: 支持各接口的不同模型
- **API 测试**: 内置连接测试功能
- **快捷键自定义**: 可自定义全局快捷键

### 🔒 隐私安全
- **本地处理**: Ollama 支持完全离线翻译
- **安全存储**: API 密钥安全保存在系统钥匙串
- **无数据收集**: 不收集或存储用户翻译内容
- **开源透明**: MIT 许可证，代码完全开放

## 📦 安装说明

### 系统要求
- **操作系统**: macOS 14.0 或更高版本
- **架构支持**: Intel 和 Apple Silicon (Universal Binary)
- **权限**: 辅助功能权限（用于文本选择和替换）
- **网络**: 在线 API 需要网络连接

### 安装步骤
1. 下载 `TypeTranslator-v1.0.dmg`
2. 双击 DMG 文件挂载安装包
3. 将 `TypeTranslator.app` 拖拽到 `Applications` 文件夹
4. 首次运行时需要在系统偏好设置中授予辅助功能权限

### 首次设置
1. 启动 TypeTranslator
2. 点击菜单栏图标选择"设置"
3. 选择要使用的 AI 接口
4. 配置相应的 API 密钥和参数
5. 点击"测试 API"验证配置
6. 开始使用全局快捷键翻译！

## 🚀 使用方法

### 基本翻译
1. 在任意应用中选中要翻译的文本
2. 按下快捷键 `Cmd+Shift+T`
3. 等待翻译完成，文本将自动替换

### 快捷键说明
- **Cmd+Shift+T**: 翻译选中文本（原地替换）
- **Cmd+Shift+C**: 翻译选中文本（剪贴板模式）

## 🤖 推荐配置

### 日常使用
- **OpenAI GPT-4o-mini**: 性价比高，速度快
- **Google Gemini-1.5-flash**: 免费额度大，多语言支持好

### 专业用户
- **Claude-3.5-sonnet**: 理解能力强，翻译质量高
- **Azure OpenAI**: 企业级稳定性

### 隐私优先
- **Ollama + llama3.2**: 完全离线，隐私保护

### 高速需求
- **Groq**: 推理速度极快

## 🔧 技术特性

- **Universal Binary**: 原生支持 Intel 和 Apple Silicon
- **SwiftUI**: 现代化的用户界面
- **异步处理**: 不阻塞用户界面
- **错误恢复**: 完善的错误处理机制
- **调试支持**: 详细的日志记录

## 📊 文件信息

- **应用大小**: ~1.0MB
- **安装包大小**: ~539KB
- **支持架构**: Universal Binary (Intel + Apple Silicon)
- **最低系统**: macOS 14.0

## 🐛 已知问题

- 首次使用需要手动授予辅助功能权限
- 某些应用的文本选择可能需要特殊处理
- Ollama 需要单独安装和配置

## 🔮 未来计划

- 支持更多 AI 接口
- 添加翻译历史记录
- 支持批量文本翻译
- 添加自定义翻译提示词
- 支持更多语言对

## 🙏 致谢

感谢以下开源项目和服务：
- [OpenAI](https://openai.com) - GPT 模型
- [Anthropic](https://anthropic.com) - Claude 模型
- [Google](https://ai.google.dev) - Gemini 模型
- [Ollama](https://ollama.com) - 本地模型运行
- [Groq](https://groq.com) - 高速推理服务

## 📞 支持

- 🐛 [报告问题](https://github.com/joeaki1983/TypeTranslator/issues)
- 💡 [功能建议](https://github.com/joeaki1983/TypeTranslator/issues)
- 📖 [查看文档](https://github.com/joeaki1983/TypeTranslator)

---

**享受智能翻译的便利！** 🎊
