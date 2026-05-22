# Design System

## 语义配色

| 类型 | Fill | Stroke |
|------|------|--------|
| Frontend | `rgba(8, 51, 68, 0.4)` | `#22d3ee` |
| Backend | `rgba(6, 78, 59, 0.4)` | `#34d399` |
| Database | `rgba(76, 29, 149, 0.4)` | `#a78bfa` |
| AWS/Cloud | `rgba(120, 53, 15, 0.3)` | `#fbbf24` |
| Security | `rgba(136, 19, 55, 0.4)` | `#fb7185` |
| Message Bus | `rgba(251, 146, 60, 0.3)` | `#fb923c` |
| External | `rgba(30, 41, 59, 0.5)` | `#94a3b8` |

页面背景 `#020617`；网格 `#1e293b` stroke `0.5`。

## 字体

```html
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
```

| 用途 | 字号 |
|------|------|
| 组件名 | 11–12px，`font-weight="600"`，白色 |
| 副标签 | 9px，`#94a3b8` |
| 连线标签 | 8–9px |
| 边界标题 | 8–10px，与边界 stroke 同色 |

## 组件盒

```svg
<rect x="X" y="Y" width="W" height="H" rx="6" fill="FILL" stroke="STROKE" stroke-width="1.5"/>
<text x="CX" y="Y+20" fill="white" font-size="11" font-weight="600" text-anchor="middle">LABEL</text>
<text x="CX" y="Y+36" fill="#94a3b8" font-size="9" text-anchor="middle">sublabel</text>
```

- 标准服务高度 **60px**；多行列表可 80–120px  
- **Security group**：`stroke-dasharray="4,4"`，透明 fill，`#fb7185`  
- **Region**：`stroke-dasharray="8,4"`，`rx="12"`，`#fbbf24`  

## 消息总线

高 20px，`rx="4"`，放在两组件 **40px 间隙正中**：

```svg
<rect x="X" y="Y" width="120" height="20" rx="4" fill="rgba(251, 146, 60, 0.3)" stroke="#fb923c" stroke-width="1"/>
<text x="CX" y="Y+14" fill="#fb923c" font-size="7" text-anchor="middle">Kafka</text>
```

## 箭头

```svg
<marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
  <polygon points="0 0, 10 3.5, 0 7" fill="#64748b" />
</marker>
```

- 数据流：实线 + `marker-end="url(#arrowhead)"`  
- 鉴权流：`#fb7185` + `stroke-dasharray="5,5"`  

## Summary Card

```html
<div class="card">
  <div class="card-header">
    <div class="card-dot cyan"></div>
    <h3>Title</h3>
  </div>
  <ul><li>• point</li></ul>
</div>
```

`card-dot` 颜色类：`cyan` | `emerald` | `violet` | `amber` | `rose`。
