# TypeTranslator 安装指南

## 🎉 打包完成

TypeTranslator 已成功打包为 macOS 应用程序！您现在有以下文件可供使用：

### 📦 生成的文件

1. **TypeTranslator.app** - 应用程序文件
   - 位置: `build/Export/TypeTranslator.app`
   - 这是可以直接运行的应用程序

2. **TypeTranslator-v1.0.dmg** - 安装包
   - 位置: `build/TypeTranslator-v1.0.dmg`
   - 这是用于分发的磁盘映像文件

## 🚀 安装方法

### 方法一：使用 DMG 安装包（推荐）

1. **挂载安装包**
   ```bash
   open build/TypeTranslator-v1.0.dmg
   ```
   或双击 `TypeTranslator-v1.0.dmg` 文件

2. **安装应用**
   - 将 `TypeTranslator.app` 拖拽到 `Applications` 文件夹
   - 等待复制完成

3. **启动应用**
   - 在 Launchpad 或 Applications 文件夹中找到 TypeTranslator
   - 双击启动

### 方法二：直接使用 .app 文件

1. **复制应用**
   ```bash
   cp -R build/Export/TypeTranslator.app /Applications/
   ```

2. **启动应用**
   ```bash
   open /Applications/TypeTranslator.app
   ```

## ⚙️ 首次运行配置

### 1. 授予辅助功能权限

首次运行时，系统会提示需要辅助功能权限：

1. 打开 **系统偏好设置** > **安全性与隐私** > **隐私**
2. 选择左侧的 **辅助功能**
3. 点击左下角的 🔒 图标解锁（需要管理员密码）
4. 点击 ➕ 按钮添加 TypeTranslator
5. 确保 TypeTranslator 前面的复选框已勾选

### 2. 配置 API 密钥

1. 点击菜单栏的 🌐 图标
2. 选择 "Open Settings..."
3. 选择您要使用的 AI 服务：
   - **OpenAI**: 需要 OpenAI API Key
   - **Google Gemini**: 需要 Gemini API Key
   - **Groq**: 需要 Groq API Key
   - **SambaNova**: 需要 SambaNova API Key
   - **自定义接口**: 需要自定义 API 配置

4. 输入相应的 API Key 和模型配置
5. 点击 "测试API" 验证配置
6. 点击 "应用" 保存设置

## 🎯 使用方法

### 基本翻译

1. 在任何应用的文本框中输入或选择文字
2. 按快捷键 `⌘⇧T`（Cmd+Shift+T）
3. 文字将自动翻译并替换原文

### 快捷键自定义

1. 打开设置界面
2. 在 "快捷键设置" 部分点击 "修改"
3. 按下您想要的快捷键组合
4. 点击 "应用" 保存

## 🔧 支持的 AI 服务

### OpenAI
- **获取 API Key**: https://platform.openai.com/api-keys
- **推荐模型**: gpt-4o-mini, gpt-4o

### Google Gemini
- **获取 API Key**: https://aistudio.google.com/app/apikey
- **推荐模型**: gemini-1.5-flash, gemini-1.5-pro

### Groq
- **获取 API Key**: https://console.groq.com/
- **推荐模型**: llama-3.3-70b-versatile

### SambaNova
- **获取 API Key**: https://cloud.sambanova.ai/
- **推荐模型**: Meta-Llama-3.1-70B-Instruct

## 🛠️ 故障排除

### 常见问题

**Q: 应用无法启动？**
A: 确保您的 macOS 版本为 14.0 或更高，并且已授予辅助功能权限。

**Q: 快捷键不响应？**
A: 检查辅助功能权限是否已授予，确保应用在菜单栏运行。

**Q: 翻译失败？**
A: 检查 API Key 是否正确，网络连接是否正常，可以使用"测试API"功能验证。

**Q: 某些应用无法翻译？**
A: 某些应用可能有特殊的文本框实现，建议尝试在其他应用中使用。

### 系统要求

- **操作系统**: macOS 14.0 或更高版本
- **架构**: 支持 Intel (x86_64) 和 Apple Silicon (ARM64)
- **网络**: 需要互联网连接以访问 AI 服务

## 📋 技术特性

- ✅ **通用二进制**: 同时支持 Intel 和 Apple Silicon Mac
- ✅ **代码签名**: 使用本地签名，确保系统安全
- ✅ **优化构建**: Release 模式编译，性能优化
- ✅ **完整打包**: 包含所有必要的 Swift 运行时库

## 🎊 享受使用！

TypeTranslator 现在已经准备就绪！您可以：

1. 在任何地方快速翻译文本
2. 使用多种 AI 模型获得最佳翻译质量
3. 自定义快捷键和翻译设置
4. 享受无缝的翻译体验

如有任何问题，请查看应用内的设置和帮助信息。
