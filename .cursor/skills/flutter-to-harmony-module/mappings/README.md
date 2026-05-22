# Flutter（GetX）→ ArkUI（ArkTS/ETS）映射索引

按主题拆分的对照表；**生成或审阅鸿蒙迁移代码前先看本索引**，再打开对应文件。

> 与桌面 `arkts-to-dart/mappings/` 为反向关系；本仓库以 **EnglishTalk（Dubbing）** 为准。

## 查阅顺序建议

1. **适配与断点**（若 Flutter 侧有 `Get.isMobile` / `Get.isLandscape`）→ [09_flutter_breakpoints_to_harmony.md](./09_flutter_breakpoints_to_harmony.md)  
2. **数据与 API 模型** → [08_dart_types_to_arkts.md](./08_dart_types_to_arkts.md)  
3. **本地图片**（Flutter `assets/images/` → 鸿蒙 `media`）→ [10_flutter_assets_to_harmony_media.md](./10_flutter_assets_to_harmony_media.md)  
4. **UI 组件** → 01–07（布局 → 文案/图 → 控件 → 列表 → 导航 → 修饰 → 状态）

## 按主题

### UI 组件与行为（01–07）

| 文件 | 内容 |
|------|------|
| [01_layout_containers.md](./01_layout_containers.md) | `Column`/`Row`/`Stack`/`Flex`/栅格/`Blank`/`Divider` |
| [02_text_and_image.md](./02_text_and_image.md) | `Text`/`Text.rich`/`Image`/`Icon` |
| [03_buttons_and_input.md](./03_buttons_and_input.md) | `Button`/`Switch`/`Checkbox`/`Slider`/`TextField` |
| [04_list_and_scroll.md](./04_list_and_scroll.md) | `ListView`/`Scroll`/`PageView`；下拉刷新 |
| [05_navigation_and_structure.md](./05_navigation_and_structure.md) | `GetPage`/`Get.toNamed`；`pagesMap` |
| [06_modifiers_and_style.md](./06_modifiers_and_style.md) | padding、圆角、`Expanded` 等 |
| [07_state_and_binding.md](./07_state_and_binding.md) | GetX → `@State`/`@Prop`/`AppStorage` |

### 数据与适配（08–10）

| 文件 | 内容 |
|------|------|
| [08_dart_types_to_arkts.md](./08_dart_types_to_arkts.md) | Dart 标量、可空、集合、`class` → ArkTS `interface` |
| [09_flutter_breakpoints_to_harmony.md](./09_flutter_breakpoints_to_harmony.md) | `Get.isMobile`/`Get.isLandscape` → `breakPoint`/`padPortrait` |
| [10_flutter_assets_to_harmony_media.md](./10_flutter_assets_to_harmony_media.md) | `assets/images/` → `resources/base/media/`、`$r('app.media.xxx')` |

## 本仓库约定（摘要）

- 规范以根目录 **`AGENTS.md`** 为准。  
- 布局尺寸：**新代码固定 vp/fp**（见 `harmony-fixed-layout-units.mdc`）。  
- 手机/平板：`@StorageLink('breakPoint')`（`md` / `xl`）+ `@StorageLink('padPortrait')`（见 `feature/home`）。  
- 路由：**`pagesMap.ets`**；页面 struct 在对应 `feature/*/pages/`。  
- 网络：**`request.get/post`** + **`CommonResponseDTO`**（见 `http-api-request-convention.mdc`）。
