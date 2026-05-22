# Flutter 设备 / 横竖屏 → 鸿蒙（`breakPoint` / `padPortrait`）

从 **Flutter `FZGet`** 迁到本仓库时，用下表把分支条件对齐到鸿蒙 **`@StorageLink`**（工程内已在 `feature/home` 等使用）。

## 手机 / 平板

| Flutter（fz 仓库） | 鸿蒙（本仓库） | 含义 |
|--------------------|----------------|------|
| `Get.isMobile` | `breakPoint == 'md'`（`BreakpointConstants.BREAKPOINT_MD`） | 手机布局 |
| `!Get.isMobile` | `breakPoint == 'xl'` | 平板布局 |

页面内典型写法：

```typescript
@StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD
```

## 横竖屏（平板）

| Flutter | 鸿蒙 | 含义 |
|---------|------|------|
| `Get.isLandscape` | `padPortrait == false` | 横屏 |
| `!Get.isLandscape` | `padPortrait == true` | 竖屏 |

```typescript
@StorageLink('padPortrait') padPortrait: boolean = false
```

## 组合示例

```text
// Flutter：平板且横屏
!Get.isMobile && Get.isLandscape

// 鸿蒙
breakPoint == 'xl' && padPortrait == false
```

```text
// Flutter：手机且竖屏
Get.isMobile && !Get.isLandscape

// 鸿蒙（手机侧 padPortrait 常为 true，按源码简化）
breakPoint == 'md' && padPortrait == true
```

以 Flutter 源码分支为准；若 **`padPortrait` 仅出现在平板分支**，只在 `xl` 内判断横竖屏。

## 注意

- 鸿蒙 **新 UI** 尺寸用固定 **vp**，勿照搬 Flutter `NumLayout`。  
- 存量页 `replaceLpx2Vp` 可保留；新页按 **`harmony-fixed-layout-units.mdc`**（`lpx/2` → vp）。
