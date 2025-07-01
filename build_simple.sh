#!/bin/bash

# TypeTranslator 简化构建脚本（适用于只有命令行工具的环境）

set -e

echo "🚀 开始构建 TypeTranslator (简化版)..."

# 检查Swift编译器
if ! command -v swift &> /dev/null; then
    echo "❌ 未找到Swift编译器，请安装Xcode Command Line Tools"
    exit 1
fi

# 检查swiftc编译器
if ! command -v swiftc &> /dev/null; then
    echo "❌ 未找到swiftc编译器，请安装Xcode Command Line Tools"
    exit 1
fi

echo "✅ Swift编译器检查通过"

# 创建构建目录
BUILD_DIR="build_simple"
APP_NAME="TypeTranslator"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "📁 创建应用包结构..."

# 清理之前的构建
if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
fi

# 创建目录结构
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# 编译Swift文件
echo "🔨 编译Swift源文件..."

# 收集所有Swift文件
SWIFT_FILES=(
    "TypeTranslator/TypeTranslatorApp.swift"
    "TypeTranslator/Models.swift"
    "TypeTranslator/HotKeyManager.swift"
    "TypeTranslator/AccessibilityManager.swift"
    "TypeTranslator/TranslationService.swift"
    "TypeTranslator/ContentView.swift"
    "TypeTranslator/SettingsView.swift"
)

# 编译应用
swiftc -o "$MACOS_DIR/$APP_NAME" \
    "${SWIFT_FILES[@]}" \
    -framework SwiftUI \
    -framework Foundation \
    -framework AppKit \
    -framework Carbon \
    -framework ApplicationServices \
    -target x86_64-apple-macos14.0 \
    -O

if [ $? -ne 0 ]; then
    echo "❌ Swift编译失败"
    exit 1
fi

echo "✅ Swift编译成功"

# 创建Info.plist
echo "📄 创建Info.plist..."
cp "TypeTranslator/Info.plist" "$CONTENTS_DIR/Info.plist"

# 复制资源文件
echo "📋 复制资源文件..."
if [ -d "TypeTranslator/Assets.xcassets" ]; then
    cp -r "TypeTranslator/Assets.xcassets" "$RESOURCES_DIR/"
fi

# 设置可执行权限
chmod +x "$MACOS_DIR/$APP_NAME"

echo "✅ 应用构建完成: $APP_DIR"

# 创建启动脚本
echo "📝 创建启动脚本..."
cat > "$BUILD_DIR/run_app.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
open TypeTranslator.app
EOF

chmod +x "$BUILD_DIR/run_app.sh"

# 创建简单的安装说明
cat > "$BUILD_DIR/README.txt" << 'EOF'
TypeTranslator 安装说明
====================

1. 将 TypeTranslator.app 拖拽到 /Applications 文件夹
2. 双击运行 TypeTranslator.app
3. 首次运行时，系统会要求授予辅助功能权限：
   - 打开 系统偏好设置 > 安全性与隐私 > 隐私 > 辅助功能
   - 点击左下角的锁图标解锁
   - 添加并勾选 TypeTranslator

使用方法：
- 配置API密钥：点击菜单栏的🌐图标 > Open Settings
- 在任何文本框中输入文字，按 Cmd+Shift+T 进行翻译

注意：此版本使用简化构建，可能在某些系统上需要额外配置。
EOF

echo ""
echo "🎉 构建完成！"
echo "📁 应用位置: $APP_DIR"
echo "📋 使用说明: $BUILD_DIR/README.txt"
echo ""
echo "✨ 下一步："
echo "1. 运行: open $APP_DIR"
echo "2. 或者: $BUILD_DIR/run_app.sh"
echo "" 