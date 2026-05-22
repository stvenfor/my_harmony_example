# 列表与滚动

| Flutter | ArkUI | 说明 |
|---------|--------|------|
| `ListView` / `ListView.builder` | `List` + `LazyForEach` 或 `ForEach` | 长列表用 `LazyForEach` |
| `ListTile` | `ListItem` 或自定义 `Row` | `onTap`→`onClick` |
| `children: items.map(...)` | `ForEach` | 短列表 |
| `SingleChildScrollView` | `Scroll` | 单页滚动 |
| `ScrollController` | `Scroller` / `scroller` 绑定 | 页面 `aboutToDisappear` 释放 |
| `BouncingScrollPhysics` 等 | `edgeEffect` | 按产品对齐 |
| `PageView` / carousel | `Swiper` | 指示器单独实现 |

## 下拉刷新 / 加载

| Flutter（fz 仓库） | 本仓库 ArkUI |
|--------------------|--------------|
| `FZRefresh` + controller | 项目内现有 `Refresh` 封装或 `List` 的 `onReachEnd`；对照同 feature 列表页 |
| `FZLoadingPage` + mixin | 页面 `@State isLoading` + 条件渲染 / 公共 Loading 组件 |

迁移时 **先 grep 同模块列表页** 的刷新写法，不要新造一套。
