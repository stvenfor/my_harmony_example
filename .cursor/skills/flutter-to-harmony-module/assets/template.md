# Flutter → Harmony Module Migration Template

Use this template when porting a Flutter/GetX module into an ArkTS `feature/*` HAR in **EnglishTalk（Dubbing）**.

## 1) Input Checklist

- [ ] Flutter module path confirmed (`FLUTTER_MODULE`)
- [ ] Entry files listed (`view` / `logic` / `binding` / `widgets/`)
- [ ] Target Harmony path confirmed (`MODULE_ROOT`, `IS_NEW_HAR`)
- [ ] Root **`AGENTS.md`** and relevant **`.cursor/rules/*.mdc`** reviewed
- [ ] Reference feature module chosen (e.g. `DubbingChallenge`, `home`, `mine`)
- [ ] Screenshots under `screenshot/<MODULE_ROOT>/` (optional)

## 2) Analysis Output

### Scope & Goals
- Flutter module:
- Harmony module:
- Pages:
- Business goal:

### Render Order
1.
2.
3.

### API Contracts
| API | Method | Params | Response summary |
|-----|--------|--------|------------------|
| | | | |

### Responsive Rules
- Phone (`Get.isMobile`):
- Tablet (`!Get.isMobile`):
- Portrait / Landscape:

### Flutter → Harmony adaptation
- See `mappings/09_flutter_breakpoints_to_harmony.md`:
  - `Get.isMobile` → `breakPoint == 'md'`
  - `!Get.isMobile` → `breakPoint == 'xl'`
  - `Get.isLandscape` → `padPortrait == false`

### Navigation Rules
| Flutter `AppRoutes` | pagesMap key | Params model |
|---------------------|--------------|--------------|
| | | |

## 3) Mapping Tables

### 3.1 Component Mapping (Flutter → ArkTS)
| Flutter | Harmony file | ArkUI struct / component |
|---------|--------------|---------------------------|
| | | |

### 3.2 State Mapping
| Flutter GetX | ArkTS location | Notes |
|--------------|----------------|-------|
| | | |

### 3.3 Adaptation Mapping
| Scenario | Flutter | Harmony |
|----------|---------|---------|
| Phone portrait | | |
| Phone landscape | | |
| Tablet portrait | | |
| Tablet landscape | | |

### 3.4 Data Model Mapping
| Dart field | ArkTS interface field | Type / optional | JSON key |
|------------|----------------------|-----------------|----------|
| | | | |

## 4) Implementation Plan

- [ ] Create/extend `feature/<name>/` HAR (`module.json5`, `build-profile`, `oh-package`)
- [ ] Add `pages/*.ets`, `components/*.ets`
- [ ] Add `model/*.ets`, `api/*Api.ets`
- [ ] Copy `media/` assets (checklist in §6)
- [ ] Register `pagesMap.ets`
- [ ] Update `schemeMap.ets` if needed
- [ ] DevEco compile `entry` + feature module

## 5) Page Skeleton

```typescript
@Component
export struct ExamplePage {
  @State isLoading: boolean = true
  @State items: ExampleItemDTO[] = []

  async aboutToAppear(): Promise<void> {
    try {
      this.items = await ExampleApi.loadList()
    } catch (_) {
      // Toast：固定文案；勿用 unknown 的 catch 参数
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column() {
      // UI
    }
    .width('100%')
    .height('100%')
  }
}
```

## 6) Asset Copy Checklist

| Flutter path | Harmony `media/` name | Used by |
|--------------|----------------------|---------|
| | | |

## 7) Route Registration

```text
# pagesMap.ets
import { ExamplePage } from '...'
'ExamplePage': wrapBuilder(ExamplePageBuilder)  // 与项目现有写法一致
```

## 8) Delivery Checklist

- [ ] Analysis summary
- [ ] Four mapping tables
- [ ] Files created/updated (+ media)
- [ ] Route / build-profile changes
- [ ] Compile result
- [ ] Remaining risks
