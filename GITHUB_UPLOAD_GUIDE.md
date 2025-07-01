# GitHub 上传指南

## 📋 准备工作

### 1. 确保已安装 Git
```bash
# 检查 Git 是否已安装
git --version

# 如果未安装，可以通过 Homebrew 安装
brew install git
```

### 2. 配置 Git（如果是首次使用）
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 🚀 上传步骤

### 第一步：在 GitHub 创建仓库

1. 访问 [GitHub.com](https://github.com)
2. 点击右上角的 "+" 按钮，选择 "New repository"
3. 填写仓库信息：
   - **Repository name**: `TypeTranslator`
   - **Description**: `A powerful macOS AI translation tool supporting 8 different AI interfaces`
   - **Visibility**: 选择 Public 或 Private
   - **不要勾选** "Add a README file"（我们已经有了）
   - **不要勾选** "Add .gitignore"（我们已经创建了）
   - **License**: 选择 MIT License 或跳过
4. 点击 "Create repository"

### 第二步：初始化本地 Git 仓库

在项目目录中执行以下命令：

```bash
# 进入项目目录
cd "/Users/joe/type translator"

# 初始化 Git 仓库
git init

# 添加所有文件到暂存区
git add .

# 查看文件状态
git status

# 提交初始版本
git commit -m "Initial commit: TypeTranslator with 8 AI interfaces support

Features:
- Support for 8 AI interfaces (OpenAI, Groq, SambaNova, Gemini, Azure, Ollama, Claude, Custom)
- Real-time text translation with global hotkeys
- Two translation modes: clipboard and in-place replacement
- Comprehensive settings interface with API testing
- Universal Binary support (Intel + Apple Silicon)
- Complete offline support with Ollama
- Enterprise-grade Azure OpenAI integration"
```

### 第三步：连接到 GitHub 仓库

```bash
# 添加远程仓库（替换 yourusername 为你的 GitHub 用户名）
git remote add origin https://github.com/yourusername/TypeTranslator.git

# 验证远程仓库
git remote -v

# 推送到 GitHub
git push -u origin main
```

如果遇到认证问题，可能需要：

#### 选项 A：使用 Personal Access Token
1. 在 GitHub 设置中创建 Personal Access Token
2. 使用 token 作为密码进行推送

#### 选项 B：使用 SSH（推荐）
```bash
# 生成 SSH 密钥（如果没有）
ssh-keygen -t ed25519 -C "your.email@example.com"

# 添加 SSH 密钥到 ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# 复制公钥到剪贴板
pbcopy < ~/.ssh/id_ed25519.pub

# 在 GitHub 设置中添加 SSH 密钥，然后使用 SSH URL
git remote set-url origin git@github.com:yourusername/TypeTranslator.git
git push -u origin main
```

## 📦 创建 Release

### 1. 准备 Release 文件
```bash
# 创建 releases 目录
mkdir -p releases

# 复制 DMG 文件到 releases 目录
cp "build/TypeTranslator-v1.0.dmg" "releases/"

# 提交 release 文件
git add releases/
git commit -m "Add v1.0 release package"
git push
```

### 2. 在 GitHub 创建 Release
1. 在 GitHub 仓库页面点击 "Releases"
2. 点击 "Create a new release"
3. 填写 Release 信息：
   - **Tag version**: `v1.0.0`
   - **Release title**: `TypeTranslator v1.0.0 - Multi-AI Interface Support`
   - **Description**: 
   ```markdown
   ## 🎉 TypeTranslator v1.0.0

   ### ✨ 新功能
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

   ### 🔧 支持的 AI 服务
   - OpenAI GPT 系列
   - Google Gemini
   - Claude (Anthropic)
   - Azure OpenAI
   - Ollama 本地模型
   - Groq 高速推理
   - SambaNova 云服务
   - 自定义 OpenAI 兼容接口
   ```
4. 上传 `TypeTranslator-v1.0.dmg` 文件
5. 点击 "Publish release"

## 📝 后续维护

### 日常更新流程
```bash
# 修改代码后
git add .
git commit -m "描述你的更改"
git push

# 发布新版本时
git tag v1.1.0
git push origin v1.1.0
# 然后在 GitHub 创建新的 Release
```

### 分支管理建议
```bash
# 创建开发分支
git checkout -b develop
git push -u origin develop

# 创建功能分支
git checkout -b feature/new-interface
# 开发完成后合并到 develop
git checkout develop
git merge feature/new-interface
git push origin develop

# 发布时合并到 main
git checkout main
git merge develop
git push origin main
```

## 🎯 完成检查清单

- [ ] GitHub 仓库已创建
- [ ] 本地 Git 仓库已初始化
- [ ] 所有文件已提交到 GitHub
- [ ] README.md 显示正常
- [ ] .gitignore 正确排除了构建文件
- [ ] LICENSE 文件已添加
- [ ] 第一个 Release 已创建
- [ ] DMG 文件已上传到 Release

## 🔗 有用的链接

- [GitHub 官方文档](https://docs.github.com)
- [Git 官方文档](https://git-scm.com/doc)
- [Markdown 语法指南](https://guides.github.com/features/mastering-markdown/)
- [开源许可证选择](https://choosealicense.com/)

---

完成上传后，你的项目将在 `https://github.com/yourusername/TypeTranslator` 可见！
