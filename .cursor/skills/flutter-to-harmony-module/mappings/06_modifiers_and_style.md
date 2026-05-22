# 修饰与样式（Flutter → ArkUI 链式修饰符）

Flutter 多为 **Widget 嵌套** 或 **Decoration**；ArkTS 常用 **链式 `.modifier()`**。

| Flutter | ArkUI |
|---------|--------|
| `SizedBox` / `ConstrainedBox` | `.width()` / `.height()` / `.constraintSize()` |
| `Padding` + `EdgeInsets` | `.padding()` / `.margin()` |
| 外层 `Padding` 作 margin | `.margin()` |
| `Container.color` / `BoxDecoration.color` | `.backgroundColor()` |
| `ClipRRect` + `BorderRadius` | `.borderRadius()` |
| `BoxDecoration.border` | `.border()` |
| `Expanded(flex: n)` | `.layoutWeight(n)` |
| `Align` / `Center` | `.align()` / 父容器 `justifyContent` |
| `Opacity` | `.opacity()` |
| `GestureDetector.onTap` / `InkWell` | `.onClick()` |
| `onPressed: null` | `.enabled(false)` 或空 `onClick` |

## 颜色与字体

- Flutter `FZColor` / `Theme` → 本仓库语义色常量或十六进制（与同 feature 文件一致）。  
- 新 UI：**固定 fp/vp**；勿引入 Flutter `NumLayout` 换算。
