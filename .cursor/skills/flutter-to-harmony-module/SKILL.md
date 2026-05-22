---
name: flutter-to-harmony-module
description: Convert Flutter/GetX modules to HarmonyOS ArkTS feature HAR modules in EnglishTalk (Dubbing)—UI mappings (mappings/01–07), Dart→ArkTS types (08), Get.isMobile/isLandscape→breakPoint/padPortrait (09), assets→media (10), request/CommonResponseDTO, pagesMap routing. Use when migrating Flutter to Harmony, porting fz_* modules, or generating feature HAR from Dart.
---

# Flutter To Harmony Module

## Purpose

Generate or补全 **HarmonyOS ArkTS / ArkUI** 功能模块（`feature/<name>` HAR），对齐本仓库 **EnglishTalk（Dubbing）** 约定。与 `arkts-to-dart` 互为反向 skill。

流程概要：

1. 分析 Flutter 模块（源码 + 可选模块文档 / 截图）。  
2. 按 `mappings/` 做组件、状态、适配、模型对照。  
3. 阅读根目录 **`AGENTS.md`** 与相关 **`.cursor/rules/*.mdc`**。  
4. 按 UI 层级 **1:1** 生成/修改 `.ets`（pages / components / model / api）。  
5. 注册路由（`pagesMap.ets`、必要时 `router_map.json` / `build-profile.json5`）。

## Required inputs

迁移开始前必须锁定（缺一则先问用户）：

| 变量 | 示例 |
|------|------|
| `FLUTTER_MODULE` | `modules/fz_home` 或 `lib/.../home` |
| `FLUTTER_ENTRY` | `home_view.dart`、`home_logic.dart` 等 1–3 个入口 |
| `HARMONY_MODULE` | 逻辑名，如 `home`、`DubbingChallenge` |
| `MODULE_ROOT` | `feature/home`（新建或已有 HAR 路径） |
| `IS_NEW_HAR` | 新建 HAR 还是扩展现有 feature |

可选但强烈建议：

- Flutter 侧模块说明 / `skillDocs` 文档（可用 **[harmony-home-module-docs](../harmony-home-module-docs/SKILL.md)** 的逆向产出作输入）。  
- 对照截图：`screenshot/<MODULE_ROOT>/`（与 `harmony-home-module-docs` 相同目录约定）。

## Mapping tables (`mappings/`)

| 主题 | 文件 |
|------|------|
| 索引与查阅顺序 | [mappings/README.md](./mappings/README.md) |
| 布局与容器 | [01_layout_containers.md](./mappings/01_layout_containers.md) |
| 文本与图片 | [02_text_and_image.md](./mappings/02_text_and_image.md) |
| 按钮与输入 | [03_buttons_and_input.md](./mappings/03_buttons_and_input.md) |
| 列表与滚动 | [04_list_and_scroll.md](./mappings/04_list_and_scroll.md) |
| 导航与结构 | [05_navigation_and_structure.md](./mappings/05_navigation_and_structure.md) |
| 修饰与样式 | [06_modifiers_and_style.md](./mappings/06_modifiers_and_style.md) |
| 状态与绑定 | [07_state_and_binding.md](./mappings/07_state_and_binding.md) |
| Dart 类型 → ArkTS | [08_dart_types_to_arkts.md](./mappings/08_dart_types_to_arkts.md) |
| Flutter 适配 → 鸿蒙断点 | [09_flutter_breakpoints_to_harmony.md](./mappings/09_flutter_breakpoints_to_harmony.md) |
| Flutter assets → 鸿蒙 media | [10_flutter_assets_to_harmony_media.md](./mappings/10_flutter_assets_to_harmony_media.md) |

**迁移输出模板：** [assets/template.md](./assets/template.md)。

## Repository anchors (read before coding)

|  concern | Location |
|----------|----------|
| 模块地图、路由入口 | 根 **`AGENTS.md`** |
| 页面聚合路由 | `entry/src/main/ets/pages/pagesMap.ets` |
| Deep link | `common/src/main/ets/utils/schemeMap.ets` |
| HTTP | `common/src/main/ets/api/request.ets`；规范 **`.cursor/rules/http-api-request-convention.mdc`** |
| 公共导出 | `common/Index.ets` |
| ArkTS 子集 / catch | **`.cursor/rules/arkts-no-any-unknown.mdc`** |
| 尺寸 vp/fp | **`.cursor/rules/harmony-fixed-layout-units.mdc`** |
| CustomDialog 关闭 | **`.cursor/rules/harmony-customdialog-controller.mdc`** |
| 白底灰边按钮 | `WordSubmitButton` + **`ButtonType.WhiteShadowGreenText`**（**`.cursor/rules/harmony-word-submit-button.mdc`**） |
| 参考 HAR 结构 | `feature/DubbingChallenge`、`feature/mine`、`feature/home` |

## Execution workflow

### Step 0: Lock paths & reference module

- 选定 **同类型** 的现有 `feature/*` 作样板（列表页、详情页、弹窗、播放页各找 1 个最近邻）。  
- 若 `IS_NEW_HAR`：对照 `build-profile.json5`、`oh-package.json5` 中已有模块条目，准备新增 module 名与 `file:` 依赖。

### Step 1: Analyze Flutter module

- 读 `view` / `logic` / `binding` / `state` / `widgets/`。  
- 提取：页面列表、**自上而下渲染顺序**、API（路径/方法/参数）、DTO 字段、**`Get.isMobile` / `Get.isLandscape`** 分支、路由名与参数。  
- 产出迁移清单（先不写代码）：页面 ↔ `.ets` 文件表、待复制图片列表、待注册路由名。

### Step 2: Component & adaptation mapping

- 打开 [mappings/README.md](./mappings/README.md)，按建议顺序读 **09 → 08 → 01–07**。  
- Dart 模型对照 [08_dart_types_to_arkts.md](./mappings/08_dart_types_to_arkts.md)。  
- 响应式分支对照 [09_flutter_breakpoints_to_harmony.md](./mappings/09_flutter_breakpoints_to_harmony.md)（`@StorageLink('breakPoint')` / `@StorageLink('padPortrait')`，参考 `feature/home`）。  
- 显式输出四张表（见 [assets/template.md](./assets/template.md) §3）：组件、状态、适配、数据模型。

### Step 3: Plan Harmony module layout

目标目录（与现有 feature 一致）：

```text
feature/<HARMONY_MODULE>/src/main/ets/
  pages/          # @Entry 或路由页 struct
  components/     # 可复用 UI
  model/          # interface / DTO
  api/            # *Api.ets
  viewmodel/      # 可选，复杂页状态
  constants/      # 路径、路由名
feature/<HARMONY_MODULE>/src/main/resources/base/media/
```

- **API**：`import { request, setUserParam } from '@ohos/common'`；`CommonResponseDTO` / `CommonObj` 来自 **`fzlibrary`**；失败 `throw Error(result.getMsg())`。  
- **Model**：仅本 feature 用的放 `feature/.../model/`；全应用共用放 `common/src/main/ets/model/` 并从 `@ohos/common` 导出。  
- **尺寸**：新 UI 用固定 **vp/fp**；勿新引入 `replaceLpx2Vp`（存量可保留）。  
- **禁止**把 Web/React 习惯套到 ArkUI；以华为 ArkTS 文档与 **`.cursor/rules/harmonyos-huawei-official-docs-mdc`** 为准。

### Step 4: Generate ArkTS 1:1 by UI block

- 按 Flutter `build` 树自上而下实现；保留交互（刷新、Tab、加载更多、弹窗）。  
- **图片（必做）**：仅复制当前模块 **实际引用** 的 assets 到  
  `feature/<HARMONY_MODULE>/src/main/resources/base/media/`  
  命名与 `$r('app.media.xxx')` 一致；跨模块共用图优先放 **`common/.../media/`**。  
  流程见 [10_flutter_assets_to_harmony_media.md](./mappings/10_flutter_assets_to_harmony_media.md)。  
- **GetX → ArkUI 状态**：见 [07_state_and_binding.md](./mappings/07_state_and_binding.md)（`@State` / `@Prop` / 页面内字段 + `async` 方法）。  
- **弹窗**：`@CustomDialog` 必须 `onRequestClose` + 外层 `CustomDialogController` 闭包（见规则文件）。  
- 不做无关重构；命名、缩进与 **同目录已有文件** 一致。

### Step 5: Wire routing & module config

1. **pagesMap**：在 `entry/src/main/ets/pages/pagesMap.ets` import 新页面并加入 `pagesMap` 字典（键名与产品/Flutter `AppRoutes` 对齐，先搜是否已有同名）。  
2. **HAR 路由资源**（若模块使用 `router_map.json`）：在 `feature/<name>/src/main/resources/base/profile/` 维护。  
3. **新 HAR**：更新根 `build-profile.json5` modules、`oh-package.json5` dependencies、`entry` 对 HAR 的依赖。  
4. **Scheme**（若有）：`schemeMap.ets`。

### Step 6: Validation

- DevEco：**Compile** 目标 module + `entry`。  
- 自检：无显式 `any`/`unknown`；`.catch` 无参或固定文案（见 arkts-no-any-unknown）。  
- 可选维护脚本： [scripts/validate.sh](./scripts/validate.sh)

## Model rules (DTO / `interface`)

- 见 [08_dart_types_to_arkts.md](./mappings/08_dart_types_to_arkts.md)。  
- 列表用 `Array<T>` / `T[]`，字段可空与后端 JSON 一致；蛇形字段在解析处显式映射或统一命名。  
- 避免 `CommonObj` 大面积替代已知的强类型。

## Output format

按顺序回复用户：

1. 分析摘要（范围、风险、截图状态）。  
2. 四张映射表（组件 / 状态 / 适配 / 模型）。  
3. 新建/修改文件列表（含 **media** 复制清单）。  
4. 路由与 `build-profile` / `oh-package` 变更。  
5. 编译/自检结果。  
6. 遗留项与需产品确认点。

## Related skills

- **[harmony-home-module-docs](../harmony-home-module-docs/SKILL.md)**：迁移前/后输出 `skillDocs/`、截图门控、mock JSON（Flutter→Harmony 时可作需求输入）。  
- 反向迁移（Harmony→Flutter）：参考桌面 **`arkts-to-dart`** skill（若已安装）。
