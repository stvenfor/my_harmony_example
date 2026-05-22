# Examples

This file provides reusable examples for the `harmony-home-module-docs` skill.

---

## Example 1: Full home module docs from code

### Input (user request)

```text
帮我梳理鸿蒙首页模块，重点 MainPage.ets 和 HomeComponent.ets，
把组件用途、接口调用、model 结构整理成文档，后续我要迁移 Flutter。
```

### Expected output docs

Create/update:

- `skillDocs/feature/home/HOME_MODULE.md`
- `skillDocs/feature/home/HOME_TOPDOWN_COMPONENTS.md`
- `feature/home/README.md` (doc links only, link to `skillDocs` path)

### Recommended output structure

```markdown
# 首页模块说明

## 1. 模块定位
- 首页容器与 entry 的关系
- MainPage / HomeComponent 职责

## 2. 主流程
- Tab 配置接口 -> 渲染路由矩阵
- 首页 list[module] -> 区块渲染

## 3. 模块映射表
| module | 组件组合 | 数据来源 | 刷新方式 | 跳转 |
|---|---|---|---|---|

## 4. 多端适配
- md/lg/xl、padPortrait、折叠屏分支

## 5. 模型与 API
- 关键字段与接口列表
```

---

## Example 2: Screenshot-to-module mapping

### Input (user request)

```text
我给你几张首页截图，帮我逐张标注这些区块分别是哪个 module，
并说明用到的组件和点击跳转。
```

### Expected response pattern

```markdown
## 截图 A

| 截图区域 | module | 组件 | 调用方式 |
|---|---|---|---|
| 4月趣学计划 | `series_audio` | `SwiperStackComponent` | 点击进入 `SeriesAudioDetail` |
| 看听读绘本 | `series_bag` | `HomeSeriesBags` | 点击卡片进入 `SeriesDetailPage` |

## 截图 B
...
```

### Validation checklist

- Use only module names that exist in `HomeComponent` branches
- If uncertain, mark as “推测，需后端配置确认”
- Keep mapping in screenshot top-down order

---

## Example 3: Add renderable mock data per module

### Input (user request)

```text
在文档里为每个模块补一份可渲染 mock 数据，后续我用 Flutter 做联调。
```

### Expected output section

~~~markdown
## 每个模块可渲染 Mock 数据（JSON）

### `slider`
```json
{
  "module": "slider",
  "slider": [
    {
      "id": "s1",
      "type": "url",
      "title": "学习档案",
      "pic": "https://img.example.com/banner.jpg",
      "url": "https://example.com"
    }
  ]
}
```

### `series`
```json
{
  "module": "series",
  "id": "ser1001",
  "title": "10秒变身小主播",
  "series": [
    {
      "type": "album",
      "pic": "https://img.example.com/album.jpg",
      "album": {
        "id": "a1",
        "album_id": "a1",
        "album_title": "魔女宅急便",
        "course_num": "6",
        "is_vip": "0",
        "is_needbuy": "0",
        "subtitle_num": "0",
        "resource_type": "album",
        "views": "0",
        "show_peoples": "0",
        "words": "0",
        "dif_level": "1",
        "sub_title": ""
      }
    }
  ]
}
```
~~~

### Validation checklist

- Mock keys align with current model interfaces
- Contains enough fields to render title, image, count, tag
- Includes realistic URLs and ids

---

## Example 4: Quick user-facing summary format

Use this concise final summary after doc updates:

```markdown
已完成，新增/更新如下：

- `feature/home/docs/HOME_MODULE.md`：模块定位、API/model、多端适配
- `feature/home/docs/HOME_TOPDOWN_COMPONENTS.md`：从上到下组件与调用方式总表
- `feature/home/README.md`：文档入口链接

补充内容：
- 首页所有核心 `module` 的组件调用链
- 每个模块可渲染 mock JSON
- 截图区块到代码模块的映射说明
```

---

## Example 5: Apply to non-home module (`mine`)

### Input (user request)

```text
帮我梳理 mine 模块的 VIP 中心，输出文档，后续我要迁移 Flutter。
重点看 VipCenter.ets 和相关 api/model。
```

### Variable resolution

```text
TARGET_MODULE=mine
MODULE_ROOT=feature/mine
ENTRY_FILES=VipCenter.ets + Vip API files
DOC_ROOT=skillDocs
DOC_OUT_DIR=skillDocs/feature/mine
```

### Expected output docs

- `skillDocs/feature/mine/MINE_MODULE.md`
- `skillDocs/feature/mine/MINE_TOPDOWN_COMPONENTS.md`
- update `feature/mine/README.md` links (if exists, link to `skillDocs/feature/mine/...`)

### Minimal output skeleton

```markdown
# Mine 模块说明（VIP中心）

## 1. 模块定位
## 2. 页面结构（从上到下）
## 3. 组件调用方式（点击/刷新/弹窗）
## 4. API 与模型映射
## 5. 多端适配
## 6. 模块级 mock 数据
```

---

## Example 6: Home as reference case

When user asks for “同样按首页的方式梳理其他模块”:

1. Reuse the same table format and headings from home docs.
2. Replace home-specific module names with target module branches.
3. Keep three outputs unchanged in form:
   - architecture doc
   - top-down component doc
   - renderable mock data section
4. Always write docs under mirrored `skillDocs/<MODULE_ROOT>/`.

Quick reminder snippet:

```markdown
沿用首页案例方法：
- 先做从上到下布局映射
- 再做组件调用方式（刷新/跳转/弹窗）
- 最后给每个模块补一份可渲染 mock JSON
```

---

## Example 7: Missing screenshot handling (required gate)

### Input (user request)

```text
帮我梳理这个模块并生成迁移文档（未提供截图）。
```

### Expected assistant behavior

1. First ask user to补充截图（说明用于 Flutter 高还原）。
2. If user later says “没有截图/先不提供”，继续分析但在文档写风险说明。

### Prompt template (first reminder)

```text
为保证 Flutter 对鸿蒙 UI 高度还原，请补充关键页面截图（建议顶部/中部/底部及弹窗态）。
如果当前无法提供，我可以先按代码结构继续分析，但会在文档中标注“无截图推导，需后续复核”。
```

### Fallback doc note (when user confirms no screenshots)

```markdown
> 截图映射说明：未提供对照截图（用户已确认），本次按代码结构推导模块映射；
> UI 还原精度存在风险，建议后续补图复核布局与视觉细节。
```

---

## Example 8: Screenshot folder-first matching

### Input (user request)

```text
请按截图分析这个模块并输出文档，截图我已经给过你。
```

### Expected assistant behavior

1. First search `screenshot/<MODULE_ROOT>/`.
2. If not found, search `screenshot/`.
3. Then use message attachments as supplement.

### Suggested note in docs

```markdown
截图参考来源：
- 主参考：`screenshot/feature/<module>/...`
- 补充参考：会话附件截图
```

