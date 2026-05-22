# 文本与图片

## Text

| Flutter | ArkUI |
|---------|--------|
| `Text('...', style: TextStyle(...))` | `Text('...').fontSize().fontColor().fontWeight()` |
| `TextStyle.fontSize` | `fontSize`（常用 **fp**） |
| `TextStyle.color` | `fontColor` |
| `TextStyle.fontWeight` | `fontWeight` |
| `TextStyle.height` | `lineHeight` 或 `maxLines` 组合 |
| `maxLines` + `overflow` | `maxLines` + `textOverflow` |
| `TextStyle.decoration` | `decoration` |

## 富文本

| Flutter | ArkUI |
|---------|--------|
| `Text.rich` + `TextSpan` | `Text` + 多个 `Span` |

## Image

| Flutter | ArkUI |
|---------|--------|
| `Image.asset` / `FZAssetImage` | `Image($r('app.media.xxx'))` 或模块 media |
| `Image.network` / `FZCacheImage` | `Image(url)`；缓存策略按项目现有封装 |
| `BoxFit.cover` / `contain` | `ImageFit.Cover` / `Contain` |
| `semanticLabel` | `alt` |
| `width` / `height` | `.width()` / `.height()` |

## Icon

| Flutter | ArkUI |
|---------|--------|
| `Icon` | `SymbolGlyph` 或 `Image` 资源图标 |

资源迁移见 [10_flutter_assets_to_harmony_media.md](./10_flutter_assets_to_harmony_media.md)。
