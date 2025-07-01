#!/bin/bash

# TypeTranslator 应用打包脚本

set -e

# 配置
APP_NAME="TypeTranslator"
SCHEME_NAME="TypeTranslator"
PROJECT_FILE="TypeTranslator.xcodeproj"
BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
EXPORT_PATH="$BUILD_DIR/Export"

echo "🚀 开始构建 TypeTranslator..."

# 清理之前的构建
if [ -d "$BUILD_DIR" ]; then
    echo "🧹 清理之前的构建文件..."
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"

# 构建归档
echo "📦 创建应用归档..."
xcodebuild archive \
    -project "$PROJECT_FILE" \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=macOS" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# 检查归档是否成功
if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "❌ 归档失败"
    exit 1
fi

echo "✅ 归档成功: $ARCHIVE_PATH"

# 导出应用
echo "📤 导出应用..."
mkdir -p "$EXPORT_PATH"

# 创建导出配置文件
cat > "$BUILD_DIR/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>destination</key>
    <string>export</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string></string>
</dict>
</plist>
EOF

# 导出应用
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist"

# 检查导出是否成功
if [ ! -d "$EXPORT_PATH/$APP_NAME.app" ]; then
    echo "❌ 导出失败"
    exit 1
fi

echo "✅ 应用导出成功: $EXPORT_PATH/$APP_NAME.app"

# 创建DMG文件（可选）
echo "💿 创建DMG安装包..."
DMG_NAME="$APP_NAME-v1.0.dmg"
hdiutil create -size 100m -fs HFS+ -volname "$APP_NAME" "$BUILD_DIR/temp.dmg"
hdiutil attach "$BUILD_DIR/temp.dmg" -mountpoint "/Volumes/$APP_NAME"

# 复制应用到DMG
cp -R "$EXPORT_PATH/$APP_NAME.app" "/Volumes/$APP_NAME/"

# 创建Applications链接
ln -s /Applications "/Volumes/$APP_NAME/Applications"

# 卸载并压缩DMG
hdiutil detach "/Volumes/$APP_NAME"
hdiutil convert "$BUILD_DIR/temp.dmg" -format UDZO -o "$BUILD_DIR/$DMG_NAME"
rm "$BUILD_DIR/temp.dmg"

echo "✅ DMG创建成功: $BUILD_DIR/$DMG_NAME"

# 显示最终结果
echo ""
echo "🎉 构建完成！"
echo "📁 应用文件: $EXPORT_PATH/$APP_NAME.app"
echo "💿 安装包: $BUILD_DIR/$DMG_NAME"
echo ""
echo "📋 安装说明:"
echo "1. 双击 $DMG_NAME 挂载安装包"
echo "2. 将 $APP_NAME.app 拖拽到 Applications 文件夹"
echo "3. 首次运行时需要在系统偏好设置中授予辅助功能权限"
echo "" 