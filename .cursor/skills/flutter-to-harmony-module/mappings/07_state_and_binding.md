# 状态与数据绑定

| Flutter（GetX） | ArkUI（本仓库习惯） |
|-----------------|----------------------|
| `GetxController` 字段 + `Obx` | 页面 struct 内 `@State`；子组件用 `@Prop` / `@Link` |
| `Rx` / `Rxn` | `@State` 或 `@Watch` 驱动刷新 |
| `GetBuilder` + `update()` | `@State` 赋值触发重建 |
| Widget 构造函数参数 | `@Prop`（父→子） |
| `Get.find` / `Tag` | 单例服务、`AppStorage`、或父组件回调 |
| `Bindings` + `Get.lazyPut` | 无 Binding；逻辑写在页面 / `viewmodel/*.ets` |
| `Get.put` 全局服务 | `AppStorage`、common 导出工具类 |
| `FZLocalStorage` / Hive | `Preferences` / 项目已有存储封装 |

## 页面结构建议

```text
XxxPage.ets          # @Component struct，build() UI
XxxViewModel.ets     # 可选：async 拉数、字段整理
XxxApi.ets           # 静态方法 request.get/post
model/XxxDTO.ets     # interface
```

- 生命周期：`aboutToAppear` 拉数；`aboutToDisappear` 释放定时器/播放器。  
- **不要**在 `build()` 里发起网络请求。  
- Dart `@JsonSerializable` → ArkTS **`interface`** + 手动赋值或统一解析函数（见 08）。
