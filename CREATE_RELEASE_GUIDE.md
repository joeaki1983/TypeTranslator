# 📦 创建 GitHub Release 指南

## 🎯 快速步骤

### 第一步：访问 GitHub 仓库
1. 打开浏览器，访问：**https://github.com/joeaki1983/TypeTranslator**
2. 确保您已登录 GitHub

### 第二步：创建 Release
1. 在仓库页面点击 **"Releases"** 标签（在 Code 标签旁边）
2. 点击 **"Create a new release"** 按钮

### 第三步：填写 Release 信息

#### 标签和标题
- **Choose a tag**: 输入 `v1.0.0`（会自动创建新标签）
- **Release title**: 输入 `TypeTranslator v1.0.0 - Multi-AI Interface Support`

#### 描述内容
复制以下内容到描述框：

```markdown
## 🎉 TypeTranslator v1.0.0

### ✨ 主要功能
- 支持 8 种 AI 接口：OpenAI、Groq、SambaNova、Google Gemini、Azure OpenAI、Ollama、Claude、自定义接口
- 全局快捷键实时翻译
- 两种翻译模式：剪贴板和原地替换
- 完整的设置界面和 API 测试功能
- Universal Binary 支持（Intel + Apple Silicon）
- Ollama 本地模型支持（完全离线）

### 📦 安装说明
1. 下载 `TypeTranslator-v1.0.dmg`
2. 双击挂载 DMG 文件
3. 将 TypeTranslator.app 拖拽到 Applications 文件夹
4. 首次运行时需要授予辅助功能权限

### 🖥️ 系统要求
- macOS 14.0 或更高版本
- 辅助功能权限
- 网络连接（在线 API）

### 🤖 支持的 AI 服务
- **OpenAI**: GPT-4o, GPT-4o-mini, GPT-4, GPT-3.5-turbo
- **Google Gemini**: Gemini-1.5-flash, Gemini-1.5-pro
- **Claude**: Claude-3.5-sonnet, Claude-3-haiku
- **Azure OpenAI**: 企业级服务
- **Ollama**: 本地模型（llama3.2, qwen2.5, gemma2, mistral）
- **Groq**: 高速推理服务
- **SambaNova**: 高性能计算平台
- **自定义接口**: OpenAI 兼容格式

### 🚀 使用方法
1. 选中任意文本
2. 按 `Cmd+Shift+T` 快捷键
3. 等待翻译完成

### 🔧 技术特性
- Universal Binary (Intel + Apple Silicon)
- 完全离线支持 (Ollama)
- 企业级集成 (Azure)
- 开源 MIT 许可证

---

**享受智能翻译的便利！** 🎊
```

### 第四步：上传文件
1. 在页面下方找到 **"Attach binaries by dropping them here or selecting them"**
2. 点击选择文件，或直接拖拽 `TypeTranslator-v1.0.dmg` 文件
3. 文件路径：`/Users/joe/type translator/releases/TypeTranslator-v1.0.dmg`

### 第五步：发布
1. 确保 **"Set as the latest release"** 已勾选
2. 点击 **"Publish release"** 按钮

## ✅ 完成后的效果

发布成功后，用户可以：
- 在 Releases 页面看到 v1.0.0 版本
- 直接下载 DMG 安装包
- 查看详细的功能介绍和安装说明
- 通过 GitHub 的 Release API 获取最新版本信息

## 📊 Release 统计

发布后您可以在 GitHub 上看到：
- 下载次数统计
- Release 页面访问量
- 用户反馈和 Issues

## 🔄 后续版本发布

当有新版本时，重复以上步骤：
1. 更新版本号（如 v1.1.0）
2. 更新 Release 说明
3. 上传新的 DMG 文件
4. 发布新版本

---

**准备好创建您的第一个 Release 了吗？** 🚀

按照以上步骤，几分钟内就能完成！
