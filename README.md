# OAuth Demo - Flutter应用

这是一个演示OAuth授权流程的Flutter应用，使用BGM.tv的OAuth API进行授权。

## 功能特性

- 🔐 使用url_launcher库打开外部授权页面
- 📱 通过app_links库处理应用内回调
- 🎨 现代化的Material Design 3界面
- ✅ 完整的错误处理和用户反馈
- 📋 可复制的授权码显示

## 技术栈

- **Flutter**: 跨平台UI框架
- **url_launcher**: 用于打开外部URL
- **app_links**: 处理应用内链接回调
- **http**: HTTP请求库（预留）

## 项目结构

```
lib/
├── main.dart          # 主应用入口和OAuth逻辑
android/
├── app/src/main/AndroidManifest.xml  # Android URL scheme配置
ios/
├── Runner/Info.plist  # iOS URL scheme配置
```

## OAuth流程

1. **启动授权**: 用户点击"开始授权"按钮
2. **打开授权页面**: 使用url_launcher打开BGM.tv的OAuth授权页面
3. **用户授权**: 用户在BGM.tv网站完成授权
4. **回调处理**: 授权完成后通过`animeflow://auth/callback`回调到应用
5. **显示结果**: 应用解析回调URL并显示授权码

## 配置说明

### Android配置
在`android/app/src/main/AndroidManifest.xml`中已配置：
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="animeflow" android:host="auth" android:path="/callback" />
</intent-filter>
```

### iOS配置
在`ios/Runner/Info.plist`中已配置：
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>animeflow.auth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>animeflow</string>
        </array>
    </dict>
</array>
```

## 使用方法

1. **运行应用**:
   ```bash
   flutter run
   ```

2. **开始授权**:
   - 点击应用中的"开始授权"按钮
   - 应用将打开BGM.tv的授权页面

3. **完成授权**:
   - 在BGM.tv网站登录并授权
   - 授权完成后会自动返回到应用

4. **查看结果**:
   - 成功时显示授权码
   - 失败时显示错误信息

## OAuth参数

- **授权URL**: `https://bgm.tv/oauth/authorize`
- **响应类型**: `code`
- **客户端ID**: `bgm42366890dd59f2baf`
- **回调URI**: `animeflow://auth/callback`

## 开发说明

### 主要组件

- `OAuthDemoApp`: 主应用组件
- `OAuthDemoPage`: 主页面，包含OAuth逻辑
- `_OAuthDemoPageState`: 状态管理，处理授权流程

### 关键方法

- `_startOAuthFlow()`: 启动OAuth授权流程
- `_handleAuthCallback()`: 处理授权回调
- `_initAppLinks()`: 初始化应用链接监听

### 错误处理

应用包含完整的错误处理机制：
- 网络连接错误
- 授权失败
- URL启动失败
- 回调解析错误

## 注意事项

1. **网络连接**: 需要网络连接访问BGM.tv
2. **浏览器支持**: 需要设备有默认浏览器
3. **回调处理**: 确保应用在后台时能正确处理回调
4. **安全性**: 授权码仅用于演示，实际应用中需要安全存储

## 扩展功能

可以基于此demo扩展以下功能：
- 使用授权码获取访问令牌
- 实现用户信息获取
- 添加令牌刷新机制
- 实现完整的OAuth 2.0流程

## 许可证

此项目仅用于学习和演示目的。
