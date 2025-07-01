# TypeTranslator 打包指南

本指南将帮助你将TypeTranslator项目打包成可分发的.app文件。

## 🛠 准备工作

### 系统要求
- macOS 14.0 或更高版本
- Xcode 15.0 或更高版本
- Apple Developer账户（用于代码签名，可选）

### 检查项目配置
确保以下文件存在并配置正确：
- ✅ `TypeTranslator/Info.plist` - 应用信息配置
- ✅ `TypeTranslator/TypeTranslator.entitlements` - 权限配置
- ✅ 所有Swift源文件完整

## 📦 方法一：使用自动化脚本（推荐）

1. **给脚本添加执行权限**
   ```bash
   chmod +x build_app.sh
   ```

2. **运行构建脚本**
   ```bash
   ./build_app.sh
   ```

3. **获取构建结果**
   - 应用文件：`build/Export/TypeTranslator.app`
   - 安装包：`build/TypeTranslator-v1.0.dmg`

## 🔧 方法二：手动构建

### 步骤1：在Xcode中打开项目

```bash
open TypeTranslator.xcodeproj
```

### 步骤2：配置构建设置

1. 选择项目根节点 `TypeTranslator`
2. 在 `TARGETS` 下选择 `TypeTranslator`
3. 切换到 `Signing & Capabilities` 标签
4. 设置 `Team`（如果有Developer账户）或保持 `Automatically manage signing` 选中

### 步骤3：选择构建目标

1. 在Xcode顶部工具栏选择目标设备为 `Any Mac`
2. 确保scheme设置为 `TypeTranslator`

### 步骤4：构建归档

1. 菜单栏选择 `Product` > `Archive`
2. 等待构建完成（可能需要几分钟）
3. 构建成功后会自动打开 `Organizer` 窗口

### 步骤5：导出应用

在Organizer窗口中：

1. 选择刚刚创建的归档
2. 点击 `Distribute App` 按钮
3. 选择 `Copy App`
4. 点击 `Next`
5. 选择导出位置
6. 点击 `Export`

### 步骤6：获取.app文件

导出完成后，你将在选择的位置找到 `TypeTranslator.app` 文件。

## 🚨 可能遇到的问题

### 代码签名错误

**问题**: `Code signing error` 或 `No signing certificate found`

**解决方案**:
1. 在项目设置中关闭 `Automatically manage signing`
2. 设置 `Signing Certificate` 为 `Sign to Run Locally`
3. 或者注册Apple Developer账户

### 构建失败

**问题**: Swift编译错误

**解决方案**:
1. 清理构建缓存：`Product` > `Clean Build Folder`
2. 重新构建：`Product` > `Build`
3. 检查所有Swift文件语法是否正确

### 权限问题

**问题**: 应用运行时无法获取辅助功能权限

**解决方案**:
1. 确保 `Info.plist` 包含正确的权限描述
2. 确保 `TypeTranslator.entitlements` 配置正确

## 📱 分发应用

### 本地使用
直接双击 `TypeTranslator.app` 即可运行。

### 分享给他人

**无Developer账户**:
- 分享 `.app` 文件
- 用户首次运行时需要右键点击 > 打开，并确认运行

**有Developer账户**:
- 可以通过公证（Notarization）让应用在任何Mac上直接运行
- 可以上传到Mac App Store分发

### 创建安装包（可选）

如果想创建专业的安装包，可以使用：

1. **DMG格式** - 推荐，类似脚本中的方法
2. **PKG格式** - 使用Packages等工具
3. **ZIP格式** - 最简单的方式

## 🔍 验证应用

### 基本检查
1. 应用能够正常启动
2. 菜单栏显示🌐图标
3. 设置界面可以正常打开
4. 权限申请弹窗正常显示

### 功能测试
1. 配置API密钥
2. 授予辅助功能权限
3. 在文本编辑器中测试翻译功能
4. 验证快捷键响应

## 📋 发布清单

发布前确保完成：

- [ ] 应用版本号正确
- [ ] 所有功能正常工作
- [ ] 权限申请文案准确
- [ ] 代码签名完成
- [ ] 创建了用户说明文档
- [ ] 测试在不同Mac上的兼容性

---

🎉 恭喜！你现在有了一个可分发的TypeTranslator应用！ 