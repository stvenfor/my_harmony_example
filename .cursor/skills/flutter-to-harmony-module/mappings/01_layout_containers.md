# 布局与容器

## 组件对应

| Flutter | ArkUI | 说明 |
|---------|--------|------|
| `Column` | `Column` | 纵向主轴 |
| `Row` | `Row` | 横向主轴 |
| `Stack` | `Stack` | 层叠；ArkUI 后声明子节点通常在上层 |
| `Flex` | `Flex` 或 `Row`/`Column` | `direction` 决定轴向 |
| `Positioned` + `Stack` | `Stack` + `align` / `position` / `offset` | 按设计选手写约束 |
| `GridView` / `Wrap` | `GridRow`/`GridCol` 或 `WaterFlow` | 按列数与跨度换算 |
| `Spacer` / `Expanded(child: SizedBox.shrink())` | `Blank` 或 `layoutWeight(1)` | 占满剩余空间 |
| `Divider` / `VerticalDivider` | `Divider` | 纵向分隔注意方向 |

## 属性对应

| Flutter | ArkUI |
|---------|--------|
| `mainAxisAlignment` | `justifyContent` |
| `crossAxisAlignment` | `alignItems` |
| `spacing`（Row/Column 3.16+） | `space` 或子项 `margin` |
| 子节点 z 序 | `Stack` 声明顺序；需要时用 `zIndex` |

## 本仓库提示

- **不要**用 `NumLayout` / `.w` / `.h`（Flutter 仓库习惯）；鸿蒙侧用 **固定 vp**。  
- 存量 `replaceLpx2Vp(n)` 可保留；新代码改为 **`n/2` vp** 固定值。  
- 响应式分支见 [09_flutter_breakpoints_to_harmony.md](./09_flutter_breakpoints_to_harmony.md)。
