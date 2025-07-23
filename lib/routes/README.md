# 路由管理系统

这个目录包含了应用的统一路由管理系统，提供类型安全和易于维护的页面导航。

## 文件结构

```
routes/
├── app_routes.dart          # 路由名称常量定义
├── route_arguments.dart     # 路由参数类定义
├── route_generator.dart     # 路由生成器
├── route_helper.dart        # 路由助手方法
├── routes.dart             # 统一导出文件
└── README.md               # 使用说明
```

## 使用方法

### 1. 基本跳转

```dart
import '../../routes/route_helper.dart';

// 跳转到动漫详情页
RouteHelper.goToAnimeData(
  context,
  animeId: 12345,
  animeName: '动漫名称',
  imageUrl: 'https://example.com/image.jpg',
);

// 返回上一页
RouteHelper.goBack(context);

// 回到主页
RouteHelper.goToTabs(context);
```

### 2. 添加新路由

#### 步骤1: 在 `app_routes.dart` 中添加路由名称
```dart
class AppRoutes {
  static const String newPage = '/new_page';
}
```

#### 步骤2: 在 `route_arguments.dart` 中添加参数类（如需要）
```dart
class NewPageArguments {
  final String title;
  final int id;
  
  const NewPageArguments({required this.title, required this.id});
}
```

#### 步骤3: 在 `route_generator.dart` 中添加路由处理
```dart
case AppRoutes.newPage:
  final args = settings.arguments as NewPageArguments;
  return MaterialPageRoute(
    builder: (_) => NewPage(title: args.title, id: args.id),
    settings: settings,
  );
```

#### 步骤4: 在 `route_helper.dart` 中添加助手方法
```dart
static Future<void> goToNewPage(
  BuildContext context, {
  required String title,
  required int id,
}) {
  return Navigator.pushNamed(
    context,
    AppRoutes.newPage,
    arguments: NewPageArguments(title: title, id: id),
  );
}
```

### 3. 特殊导航

```dart
// 替换当前页面
RouteHelper.replaceTo(context, AppRoutes.newPage);

// 清空导航栈并跳转
RouteHelper.clearAndGoTo(context, AppRoutes.tabs);
```

## 优势

- ✅ **类型安全**: 编译时检查参数类型
- ✅ **集中管理**: 所有路由逻辑在一个地方
- ✅ **易于维护**: 修改路由只需要在一个地方
- ✅ **错误处理**: 自动处理404页面
- ✅ **向后兼容**: 支持多种参数格式
- ✅ **代码复用**: 避免重复的导航代码

## 注意事项

1. 所有新页面都应该通过路由系统管理
2. 路由名称使用常量，避免硬编码字符串
3. 复杂参数建议使用参数类，简单参数可以直接传递
4. 记得在路由生成器中处理新添加的路由 