# OAuth回调实现说明 (纯Flutter方案)

## 功能概述

本项目使用纯Flutter方式实现了Bangumi OAuth授权登录功能，无需修改Android原生代码：

1. **深度链接监听**: 使用`app_links`包监听`animeflow://auth/callback`回调
2. **授权码获取**: 自动解析回调URL中的code参数
3. **Stream通知**: 使用Stream实时通知授权码获取状态

## 实现文件

### 1. OAuth回调处理
- **文件**: `lib/request/bangumi/bangumi_oauth.dart`
- **功能**: 使用`app_links`包处理深度链接，提供Stream监听机制

### 2. UI界面集成
- **文件**: `lib/page/tabs/user/profile.dart`
- **功能**: 个人中心页面，集成OAuth登录功能和授权码显示

### 3. AndroidManifest.xml配置
- **文件**: `android/app/src/main/AndroidManifest.xml`
- **配置**: 已配置intent-filter来处理`animeflow://auth/callback`回调

## 依赖包

在`pubspec.yaml`中添加：
```yaml
dependencies:
  app_links: ^3.4.5
```

## 使用方法

### 1. 初始化OAuth处理
```dart
// 在应用启动时初始化
await OAuthCallbackHandler.initialize();
```

### 2. 监听授权码
```dart
// 监听授权码获取
OAuthCallbackHandler.codeStream.listen((code) {
  print('获取到授权码: $code');
  // 处理授权码，例如获取access_token
});
```

### 3. 启动授权流程
```dart
// 打开授权页面
final Uri url = Uri.parse('https://bgm.tv/oauth/authorize?response_type=code&client_id=YOUR_CLIENT_ID&redirect_uri=animeflow://auth/callback');
await launchUrl(url);
```

## 测试方法

1. **模拟测试**: 在个人中心页面点击"测试OAuth回调"按钮
2. **真实测试**: 点击"授权登录"按钮，完成Bangumi授权后会自动返回应用

## 回调URL格式

期望的回调URL格式：
```
animeflow://auth/callback?code=YOUR_AUTHORIZATION_CODE
```

## 优势

1. **纯Flutter实现**: 无需修改Android原生代码
2. **自动监听**: 应用启动时自动处理深度链接
3. **实时通知**: 使用Stream实时通知授权码状态
4. **错误处理**: 完整的错误处理和日志输出
5. **测试友好**: 提供测试功能方便调试

## 注意事项

1. **Client ID**: 需要替换为您的实际Bangumi应用Client ID
2. **权限配置**: AndroidManifest.xml中已配置必要的网络权限
3. **URL Scheme**: 使用`animeflow`作为自定义URL Scheme
4. **依赖管理**: 使用最新的`app_links`包替代已弃用的`uni_links`

## 下一步

获取到授权码后，您可以：
1. 调用Bangumi API获取access_token
2. 使用access_token访问用户数据
3. 实现用户登录状态管理 