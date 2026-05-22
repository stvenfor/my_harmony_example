# Flutter `assets/images/` → 鸿蒙 `media/`

将 Flutter 模块内静态图迁入 **目标 feature HAR** 的 `src/main/resources/base/media/`（或全应用共用图放 **`common/src/main/resources/base/media/`**）。

## Flutter 侧（源）

| 引用 | 常见路径 |
|------|----------|
| `Image.asset('assets/images/foo.png')` | `modules/<m>/assets/images/foo.png` |
| `FZAssetImage(..., package: 'fz_xxx')` | 对应 package 的 `assets/images/` |

迁移前 **全文搜索** `assets/images/`、`FZAssetImage`、`Image.asset`，列出实际用到的文件。

## 鸿蒙侧（目标）

| 引用 | 目录 |
|------|------|
| `$r('app.media.xxx')` | `feature/<module>/src/main/resources/base/media/xxx.png` |
| 多模块共用 | `common/src/main/resources/base/media/` |

**命名：** 与 `$r` 逻辑名一致；磁盘文件带扩展名（`xxx.png`）。避免与已有 media 冲突。

## 操作清单

1. **盘点** — 列出 Flutter 图 → 目标文件名。  
2. **复制** — 仅复制本模块页面/组件 **引用到的** 文件；不要整目录 bulk copy。  
3. **引用** — ArkUI `Image($r('app.media.xxx'))`；跨 HAR 时注意资源所属 module。  
4. **校验** — DevEco 编译；运行时缺图检查路径与 module 依赖。

## 与 UI 映射的关系

`objectFit`、宽高等见 [02_text_and_image.md](./02_text_and_image.md)；本文件只覆盖 **文件落盘与路径**。
