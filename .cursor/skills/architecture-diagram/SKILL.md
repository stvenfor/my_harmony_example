---
name: architecture-diagram
description: >-
  Generates polished dark-themed system/infrastructure/cloud/security/network
  topology diagrams as self-contained HTML+SVG (export to PNG/PDF via toolbar).
  Use when the user asks for architecture diagrams, 架构图, 系统拓扑, 技术方案图,
  infrastructure diagrams, or module/service relationship visuals.
---

# Architecture Diagram

产出 **单文件 `.html`**：暗色主题、内联 SVG、可选导出工具栏（Copy PNG / 下载 PNG / PDF）。基于 Cocoon AI architecture-diagram v1.1，已按 Cursor Skill 规范拆分。

## 何时使用

- 用户要 **架构图 / 拓扑图 / 方案图**（中英文均可）
- 需要 **可浏览器直接打开**、可截图/导出的交付物（非 Mermaid 纯文本）
- 描述系统模块、云资源、安全边界、数据流、消息总线关系

**不要**用本 skill 做：数据统计图表、甘特图、UML 类图细节、Harmony/Flutter UI 线框（用各自模块 skill）。

## 执行流程

```
1. 澄清范围 → 2. 复制 template → 3. 布局 SVG → 4. 校验 → 5. 交付路径
```

### Step 1：锁定输入

| 项 | 说明 |
|----|------|
| 标题 / 副标题 | 页眉 `h1`、`.subtitle` |
| 组件列表 | 名称、类型（见 design-system）、端口/协议标注 |
| 连接关系 | 方向、标签（HTTPS、JWT、Kafka 等）、是否虚线（鉴权流） |
| 边界 | Region / Cluster / Security Group 是否需要的框 |
| 输出路径 | 默认 `docs/diagrams/<slug>.html` 或用户指定 |

缺信息时先问 1–2 个关键问题，不要臆造未给出的云服务名称。

### Step 2：从模板起步

1. **复制** [resources/template.html](resources/template.html) 到目标路径（勿在模板目录原地改）。
2. 替换 `[PROJECT NAME]`、副标题、三张 summary card、footer。
3. **保留**（勿删）：
   - `id="report-container"` 的 `.container`
   - `<head>` 内 html2canvas + jsPDF（含 SRI `integrity`，版本与 hash 成对，勿只改 URL）
   - `.toolbar` / `copyAsImage` / `downloadPNG` / `downloadPDF`
4. 字体：仅允许 Google Fonts 的 JetBrains Mono 外链；样式全部内联。

### Step 3：绘制 SVG

1. 先定 **viewBox** 宽高（默认 `1000×680`，有图例/长列表时向下扩高）。
2. **绘制顺序**（见 [layout-rules.md](layout-rules.md)）：
   - 网格背景 → **连接线/箭头** → 边界框 → 组件（必要时先不透明底再半透明面）
3. 按组件语义上色：见 [design-system.md](design-system.md)。
4. 图例放在 **所有边界框下方** ≥20px，必要时增大 viewBox。

### Step 4：自检清单

- [ ] 垂直堆叠组件间距 ≥40px，消息总线在间隙内、不与盒子重叠
- [ ] 箭头在组件下层；半透明盒需不透明遮罩 rect（`#0f172a`）再画半透明层
- [ ] 图例不在 Region/Cluster 虚线框内部
- [ ] 未使用 `<foreignObject>`（html2canvas 导出不稳定）
- [ ] 浏览器直接打开 HTML 可渲染；导出按钮在 https / localhost / file 下可测

### Step 5：交付

告知用户：

- 文件路径
- 用浏览器打开预览
- `⋯` 工具栏：复制高清 PNG、下载 PNG/PDF

## 快速参考

| 主题 | 文件 |
|------|------|
| 配色、字体、SVG 片段 | [design-system.md](design-system.md) |
| 间距、图例、层级、导出约束 | [layout-rules.md](layout-rules.md) |
| 完整可编辑样板 | [resources/template.html](resources/template.html) |

## 页面结构（固定）

1. Header：脉冲点 + 标题 + `⋯` 导出工具栏  
2. Diagram card：主 SVG  
3. 3 列 summary cards  
4. Footer 元数据  

## 与仓库文档的关系

若图为 **EnglishTalk / Dubbing** 模块架构，组件名应对齐根目录 `AGENTS.md` 的 module 表（`entry`、`common`、`feature/*`），HTTP 入口写 `pagesMap.ets` / `request.ets` 等真实路径，避免虚构模块名。
