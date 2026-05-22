# 导航与页面结构

| Flutter（GetX） | 本仓库 Harmony |
|-----------------|----------------|
| `GetMaterialApp` + `getPages` | `entry` Ability + **`pagesMap.ets`** |
| `Get.toNamed(AppRoutes.xxx, arguments: ...)` | `router.pushUrl` / 项目内封装的 `push`；参数对象或 `router` options |
| `Get.arguments` | 路由参数类型：`model/*NavParam.ets` 或 `router.getParams()` |
| `DefaultTabController` + `TabBar` + `TabBarView` | `Tabs` + `TabContent` |
| `AppBar` / `FZAppBar` | 项目 `TitleBar` / 自定义顶栏 struct（如 `*TopBar.ets`） |
| `FZAuthMiddleware` | 登录校验在跳转前或页面 `aboutToAppear`；对照 `schemeMap` / 现有页 |

## 注册 checklist

1. 在 `feature/<module>/src/main/ets/pages/` 新增 `@Component` 页面 struct。  
2. `entry/src/main/ets/pages/pagesMap.ets`：**import** + **map 键**（与产品路由名一致）。  
3. 若模块有 `constants/*NavNames.ets`，Flutter `AppRoutes` 名与鸿蒙键对齐并文档化。  
4. 新 HAR：根 `build-profile.json5` + `oh-package.json5` + `entry` 依赖。  
5. Deep link：必要时更新 `common/.../schemeMap.ets`。

参考：`feature/DubbingChallenge/src/main/ets/constants/DubbingChallengeNavNames.ets`。
