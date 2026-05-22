# Layout & Export Rules

## 垂直间距（必守）

| 常量 | 值 |
|------|-----|
| 标准组件高 | 60px（大组件 80–120px） |
| 最小垂直间隙 | 40px |

**示例**

```
A: y=70, h=60  → 底 130
间隙 130–170    → 总线放 y=140, h=20
B: y=170, h=60  → 底 230
```

❌ 总线 y=160 且 B 从 y=170 起 → 重叠  
✅ 总线在间隙几何中心

## 图例位置（必守）

- 图例在所有 Region / Cluster / SG **下缘之外** ≥20px  
- 扩大 `viewBox` 高度容纳图例，勿压在虚线框内  

```
Cluster: y=30, h=460 → 底 490
图例起点 ≥ 510
viewBox 高度 ≥ 560
```

## SVG 绘制顺序

1. `<defs>`（arrowhead、grid pattern）  
2. 网格背景 rect  
3. **所有连线/箭头**（先画，后在下层）  
4. Region / Cluster 大框  
5. Security group 虚线框  
6. 组件：需遮箭头时 **先** `fill="#0f172a"` 同尺寸 rect，**再**半透明描边 rect + text  

半透明 fill 遮不住箭头；必须不透明底。

## 导出工具栏（模板已含）

**禁止删除或弱化：**

- CDN（版本与 SRI 成对）：
  - html2canvas@1.4.1
  - jspdf@2.5.2
- `id="report-container"`
- `.toolbar` + `@media print { .toolbar { display: none !important; } }`
- `getBoundingClientRect()` + `html2canvas(..., { ignoreElements: toolbar, scale: 2, pad 32 })`

**限制：**

- 不用 `<foreignObject>`  
- 剪贴板需用户手势 + 安全上下文（https / localhost / file）  
- 更高清：export `scale` 改为 3 或 4  

## 产出物

单一 `.html`：

- 内联 CSS（除 JetBrains Mono 字体链接）  
- 内联 SVG（无外链图）  
- 导出依赖模板内联 script + 上述两个 CDN  
