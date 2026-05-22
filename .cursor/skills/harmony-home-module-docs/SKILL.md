---
name: harmony-home-module-docs
description: Analyze HarmonyOS feature modules and produce documentation with top-down layout mapping, component usage, API/model tracing, multi-device adaptation notes, screenshot-to-module mapping, and renderable mock data. Use when the user asks to梳理功能模块/输出README/对照截图分析组件/准备Flutter迁移文档. Home module is the default reference case.
---

# Harmony Feature Module Docs

## When to use

Use this skill when the user asks for any of:

- 梳理鸿蒙某个功能模块代码结构（首页只是案例）
- 输出模块 README/设计说明/迁移文档
- 根据截图映射页面区块到代码模块
- 整理模块接口、模型、组件调用关系
- 产出可渲染 mock 数据用于 Flutter 或前端联调

## Screenshot gate (high priority)

Screenshot-to-code mapping is a **critical** step for Flutter high-fidelity UI restoration.

Rule:

1. First auto-check whether module screenshots already exist under `screenshot/` (by mirrored module path).
2. If matching images are found (`.jpg` / `.jpeg` / `.png` / `.webp`), treat them as provided and continue directly (no need to ask user again).
3. If no matching images are found, ask user to choose:
   - provide screenshots, or
   - continue with no-screenshot analysis.
4. If user explicitly confirms “no screenshots” (or equivalent), continue the workflow and mark screenshot mapping as:
   - `无截图，按代码结构推导`
   - `还原风险较高，建议后补截图复核`

Do not silently skip screenshot mapping without this reminder/confirmation branch.

## Screenshot resource directory (mandatory)

Use a fixed screenshot directory at project root (same level as `entry/`):

- `SCREENSHOT_ROOT=screenshot/`
- Deprecated: do **not** use `.cursor/screenshot/` anymore.

Rules:

1. All user-provided reference screenshots should be placed under `SCREENSHOT_ROOT`.
2. Screenshot lookup MUST start from `SCREENSHOT_MODULE_DIR` and follow project-path mirroring.
3. Directory mapping is strict and one-to-one with project structure:
   - `feature/home` -> `screenshot/feature/home/`
   - `feature/mine` -> `screenshot/feature/mine/`
   - `feature/ReciteWords` -> `screenshot/feature/ReciteWords/`
4. Build `SCREENSHOT_MODULE_DIR` with exact formula (no custom rewrite):
   - `SCREENSHOT_MODULE_DIR = screenshot/<MODULE_ROOT>`
5. If images exist both in message attachments and `SCREENSHOT_ROOT`, use `SCREENSHOT_ROOT` as primary reference source and treat attachments as supplement.
6. Prefer filename patterns for faster matching:
   - `{module}-{section}-{state}.png`
   - `{module}-section-01.png`, `{module}-section-02.png`
   - device suffixes like `tablet-portrait`, `tablet-landscape`, `fold-unfolded`, `fold-folded`

## Module targeting (must do first)

Before analysis, lock these variables:

- `TARGET_MODULE`: e.g. `home`, `mine`, `study`
- `MODULE_ROOT`: e.g. `feature/home`
- `ENTRY_FILES`: 1-3 key pages/components requested by user
- `DOC_ROOT`: fixed to repository root `skillDocs/`
- `DOC_OUT_DIR`: `skillDocs/<MODULE_ROOT>` (mirror project directory structure)
- `SCREENSHOT_ROOT`: `screenshot`
- `SCREENSHOT_MODULE_DIR`: `screenshot/<MODULE_ROOT>`

Path formula (copy/paste):

```text
DOC_ROOT = "skillDocs"
DOC_OUT_DIR = DOC_ROOT + "/" + MODULE_ROOT
SCREENSHOT_ROOT = "screenshot"
SCREENSHOT_MODULE_DIR = SCREENSHOT_ROOT + "/" + MODULE_ROOT

# Example
MODULE_ROOT = "feature/mine"
DOC_OUT_DIR = "skillDocs/feature/mine"
SCREENSHOT_MODULE_DIR = "screenshot/feature/mine"
```

If user gives no module, default to `home`.

Home default reference:

- `TARGET_MODULE=home`
- `MODULE_ROOT=feature/home`
- `ENTRY_FILES=MainPage.ets + HomeComponent.ets`
- `DOC_ROOT=skillDocs`
- `DOC_OUT_DIR=skillDocs/feature/home`
- `SCREENSHOT_ROOT=screenshot`
- `SCREENSHOT_MODULE_DIR=screenshot/feature/home`

## Required outputs

Produce docs under `DOC_OUT_DIR`:

1. **Architecture doc** (module purpose + flow + adaptation)
2. **Top-down component doc** (from top to bottom layout)
3. **Mock data section** (renderable JSON per module)
4. **Flutter file manifest** (1:1 file mapping by routes/components/common usage)

Directory rule:

- If `skillDocs/` does not exist, create it.
- Create mirrored path by module location: e.g. `feature/mine` -> `skillDocs/feature/mine/`.

Also add/update an index link in `feature/<module>/README.md` when present.

## Workflow

Follow this checklist in order:

```text
Task Progress:
- [ ] Step 0: Resolve module variables (`TARGET_MODULE`, `MODULE_ROOT`, `ENTRY_FILES`, `DOC_ROOT`, `DOC_OUT_DIR`)
- [ ] Step 1: Auto-detect module screenshots in `screenshot` (`jpg/jpeg/png/webp`)
- [ ] Step 2: Screenshot gate (only prompt user when auto-detect finds no images)
- [ ] Step 3: Build module map from entry files
- [ ] Step 4: Trace APIs/models used by each module
- [ ] Step 5: Map screenshot sections to module names/components
- [ ] Step 6: Add adaptation notes (md/lg/xl, padPortrait, foldable)
- [ ] Step 7: Write docs with tables and concise call paths
- [ ] Step 8: Add renderable mock JSON per module
- [ ] Step 9: Generate Flutter file manifest (routes/components/common mapping, 1:1 parity check)
- [ ] Step 10: Create `skillDocs` mirrored output path and verify links
```

## Step details

### Step 0: Resolve module variables

Collect from user request first:

- module name and root path
- files to prioritize
- whether screenshot mapping is required
- desired output language (default Chinese)
- compute output path: `DOC_OUT_DIR = skillDocs/<MODULE_ROOT>`

### Step 1: Check screenshot directories

Scan in this order:

1. `SCREENSHOT_MODULE_DIR` (mandatory first)
2. `SCREENSHOT_ROOT` fallback
3. message attachments as supplement

Detection rule:

- Look for screenshot files with extensions: `jpg`, `jpeg`, `png`, `webp`.
- If one or more files are found in `SCREENSHOT_MODULE_DIR` (or fallback hit from `SCREENSHOT_ROOT`), mark “screenshots available” and skip asking user for uploads.

If `SCREENSHOT_ROOT` does not exist, create it before continuing.
If screenshot filenames are chaotic, suggest renaming using the convention in `screenshot/README.md`.

### Step 2: Screenshot gate

Trigger this step only when Step 1 finds no screenshots.

Prompt user once with two options:

- provide representative screenshots for fidelity restoration, or
- confirm continue with no-screenshot analysis.

Branch:

- **User provides screenshots** -> continue normal workflow.
- **User confirms no screenshots** -> continue with code-only analysis and mark the doc with a risk note.

Recommended note text:

- `未提供对照截图，本次按代码结构推导模块映射；UI 还原精度需后续截图复核。`

### Step 2: Baseline scan

Read:

- all `ENTRY_FILES`
- existing docs under `DOC_OUT_DIR` (if any)
- module README (if exists)
- module `Index.ets` and module `oh-package.json5` (recommended)

### Step 3: Build module map

Extract:

- top-level layout sections (from top to bottom)
- routing/component dispatch matrix (if page uses tab/swiper/nav branches)
- data-driven branches (`item.module === ...`, `type === ...`, etc.)

### Step 4: API/model tracing

At minimum trace:

- module-local API folder(s)
- module-local model folder(s)
- key section components used by entry files

For each module, capture:

- data source field
- refresh API (if any)
- click navigation target

### Step 5: Screenshot mapping

For each screenshot section, map:

- visual section name -> `module` name
- section container component
- card component
- API/model fields shown in UI text

Reference priority:

1. images under `SCREENSHOT_MODULE_DIR`
2. images under `SCREENSHOT_ROOT`
3. message attachment images

If no screenshots (confirmed branch), include a placeholder section:

- `截图映射：未提供截图（用户已确认）`
- list inferred mapping from code only
- include explicit risk note

### Step 6: Multi-device adaptation (when present)

Document how layout changes with:

- `breakPoint` (`md` / `lg` / `xl`)
- `padPortrait`
- `isPuraXHorizontal` and other device flags
- helper methods used for adaptive sizing

### Step 7: Documentation format

Prefer tables and short bullets.
Required table columns for top-down doc:

- layout order
- module/section
- components used
- data source/API
- call method (refresh/jump)

### Step 8: Mock JSON

Add one renderable JSON example per module:

- For home case, use canonical modules (`slider`, `channel`, `series`, etc.)
- For non-home modules, use actual branch/module names in that module
- Keep one minimal renderable sample per visual section

Rules:

- Keep keys aligned with current model interfaces
- Keep values realistic (title, pic, count, id, url)
- Ensure each sample can render without extra fields

### Step 9: Flutter file manifest (mandatory)

After module analysis, generate one extra markdown file under `DOC_OUT_DIR`:

- `DOC_OUT_DIR/<MODULE_NAME>_FLUTTER_FILE_MANIFEST.md`

Manifest must include:

1. **Page-route mapping table**
   - Harmony page route / page file
   - target Flutter route
   - target Flutter page file path
2. **Component-route or component-call mapping table**
   - Harmony component file
   - parent page/component
   - target Flutter widget file path
3. **Common module usage mapping table**
   - each used `common` capability (UI component / utility / API wrapper / constant)
   - Harmony import path
   - target Flutter shared module path
4. **1:1 parity check**
   - page count: Harmony vs Flutter planned files
   - component count: Harmony vs Flutter planned files
   - explicit mismatch list if counts differ (must not hide)

Parity rule:

- Keep page and component granularity aligned with current Harmony module.
- Do not merge multiple Harmony pages/components into one Flutter file unless user explicitly allows it.
- If merge/split is unavoidable, mark as `偏差项` with reason.

### Step 10: Verify

Before finishing:

- Ensure `skillDocs/` exists
- Ensure docs are in `DOC_OUT_DIR` and directory mirrors source module path
- Ensure `screenshot/` exists for future runs
- Ensure module README links to new docs
- Ensure Flutter manifest exists and includes page/component count parity
- Keep wording consistent (`module`, `组件`, `调用方式`)
- Do not include unrelated refactors
- If screenshots were missing, ensure risk note is present in final docs

## Output templates

### A) Top-down section table template

```markdown
| 布局顺序 | `module`/区域 | 区块用途 | 组件组合 | 调用方式（刷新/跳转） |
|---|---|---|---|---|
| 1 | `slider` | 顶部轮播 | `Swiper` + `Image` | 点击走 `HandleJumpUil...` |
```

### B) Screenshot mapping template

```markdown
| 截图区域 | 模块 | 组件 | 数据字段 |
|---|---|---|---|
| 4月趣学计划 | `series_audio` | `SwiperStackComponent` | `title`, `learn_num`, `album_num`... |
```

### C) Mock section template

~~~markdown
### `series_bag`
```json
{
  "module": "series_bag",
  "id": "sb1001",
  "title": "看听读绘本",
  "sub_title": "精选全球经典绘本",
  "colour": "EAF8F0",
  "series_bag": []
}
```
~~~

## Guardrails

- Stay surgical: only update documentation files unless explicitly asked for code changes.
- Do not invent module names not present in target module branches.
- If code and screenshot conflict, state both and mark as “需后端配置确认”.
- Prefer Chinese output if user uses Chinese.

## Additional resources

- For concrete end-to-end examples, see [examples.md](examples.md)

## Suggested default filenames

Use these names unless user requests different names:

- `DOC_OUT_DIR/<MODULE_NAME>_MODULE.md` (architecture + flow)
- `DOC_OUT_DIR/<MODULE_NAME>_TOPDOWN_COMPONENTS.md` (top-down mapping + calls)

Home case keeps existing names:

- `skillDocs/feature/home/HOME_MODULE.md`
- `skillDocs/feature/home/HOME_TOPDOWN_COMPONENTS.md`

