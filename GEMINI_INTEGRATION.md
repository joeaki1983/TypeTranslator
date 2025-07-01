# Google Gemini 接口集成说明

## 概述

TypeTranslator 现已支持 Google Gemini API，为用户提供更多的AI翻译选择。Gemini 是 Google 开发的先进大语言模型，具有出色的多语言理解和翻译能力。

## 新增功能

### 1. Gemini API 支持
- 完整的 Gemini API 集成
- 支持 Gemini 1.5 Flash、Gemini 1.5 Pro、Gemini 1.0 Pro 等模型
- 自动处理 Gemini API 的特殊请求和响应格式

### 2. 配置界面
- 在设置界面新增 "Google Gemini" 选项
- 专门的 Gemini API Key 配置字段
- 模型选择和配置选项
- 显示 Gemini API 的基础 URL 信息

### 3. 代码更改

#### Models.swift
- 在 `APIInterface` 枚举中添加了 `.gemini` 选项
- 新增 `geminiApiKey` 和 `geminiModel` 配置属性
- 更新了所有便利方法以支持 Gemini 接口
- 默认 Gemini 模型设置为 `gemini-1.5-flash`

#### SettingsView.swift
- 添加了 `geminiConfigView` 配置界面
- 包含 API Key 输入、模型配置和使用说明
- 显示常用 Gemini 模型列表

#### TranslationService.swift
- 修改 `getAPIURL()` 方法以支持 Gemini 的特殊 URL 格式
- 更新 `translateText()` 方法以处理 Gemini 的请求格式
- 实现 Gemini API 响应解析逻辑

## 使用方法

### 1. 获取 Gemini API Key
1. 访问 [Google AI Studio](https://aistudio.google.com/app/apikey)
2. 登录您的 Google 账户
3. 创建新的 API Key
4. 复制生成的 API Key

### 2. 配置 TypeTranslator
1. 打开 TypeTranslator 设置界面
2. 在"接口选择"中选择"Google Gemini"
3. 输入您的 Gemini API Key
4. 选择要使用的模型（推荐 `gemini-1.5-flash`）
5. 点击"测试API"验证配置

### 3. 开始使用
配置完成后，您就可以使用快捷键进行翻译，系统将使用 Gemini API 进行翻译处理。

## 支持的模型

- **gemini-1.5-flash** - 快速响应，适合日常翻译
- **gemini-1.5-pro** - 更高质量，适合专业翻译
- **gemini-1.0-pro** - 稳定版本，兼容性好

## 技术细节

### API 格式差异
Gemini API 与 OpenAI API 在请求和响应格式上有所不同：

**请求格式：**
```json
{
  "contents": [
    {
      "parts": [
        {
          "text": "翻译内容"
        }
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.3
  }
}
```

**响应格式：**
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "翻译结果"
          }
        ]
      }
    }
  ]
}
```

### URL 结构
Gemini API 使用不同的 URL 结构：
```
https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}
```

## 注意事项

1. **API Key 安全**：请妥善保管您的 Gemini API Key，不要在公共场所或代码中暴露
2. **使用限制**：请注意 Google 对 Gemini API 的使用限制和配额
3. **网络连接**：确保您的网络可以访问 Google 服务
4. **模型选择**：根据您的需求选择合适的模型，Flash 版本响应更快，Pro 版本质量更高

## 故障排除

### 常见问题

**Q: API 测试失败？**
A: 检查 API Key 是否正确，网络是否可以访问 Google 服务

**Q: 翻译质量不理想？**
A: 尝试使用 gemini-1.5-pro 模型，或调整 Temperature 参数

**Q: 响应速度慢？**
A: 使用 gemini-1.5-flash 模型可以获得更快的响应速度

## 更新日志

- **v1.1.0** - 新增 Google Gemini API 支持
- 完整的 Gemini API 集成
- 新增 Gemini 配置界面
- 支持多种 Gemini 模型选择
