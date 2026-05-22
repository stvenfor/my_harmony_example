# Dart 数据类型 → ArkTS 映射

用于把 Dart 3 模型、API 字段迁到 ArkTS **`interface`**。网络层统一 **`CommonResponseDTO<T>`** + **`getDataRow()`**。

## 基础标量

| Dart | ArkTS | 说明 |
|------|-------|------|
| `String` | `string` | |
| `int` | `number` | JSON 整数 |
| `double` | `number` | |
| `bool` | `boolean` | |
| `BigInt` | `string` 或 `number` | ID 建议 `string` 防精度 |

## 空值与可选

| Dart | ArkTS | 说明 |
|------|-------|------|
| `T?` | `T` 可选字段或 `\| undefined` 语义 | 接口字段 `field?: T` |
| `??` / `?.` | `??` / 显式判空 | 避免 `any` |
| `!` 断言 | 先判空再使用 | ArkTS 少用非空断言 |

## 集合

| Dart | ArkTS |
|------|-------|
| `List<T>` | `Array<T>` 或 `T[]` |
| `Map<String, dynamic>` | `Record<string, Object>` 或 `CommonObj`（边界解析后收窄） |
| `Set<T>` | `Set<T>` 或 `T[]`（按用法） |

## 对象

| Dart | ArkTS |
|------|-------|
| `class` / `@JsonSerializable` | `interface` + 解析函数 |
| `@JsonKey(name: 'snake_case')` | 接口用 camelCase，解析时写字段映射 |
| `extends` | `extends`（interface） |
| `implements` | `implements` |

## 枚举

| Dart | ArkTS |
|------|-------|
| `enum` | `enum` 或 `const` 联合 |
| 字符串 JSON 枚举 | `enum` + 转换函数 |

## 异步

| Dart | ArkTS |
|------|-------|
| `Future<T>` | `Promise<T>`；页面用 **`async`/`await`** |
| `.catch((e) => ...)` | **避免**带 `unknown` 参数的 `.catch`；用无参 catch 或 `try/await`（见 arkts-no-any-unknown） |

## API 字段惯例（本仓库）

| 情况 | ArkTS 写法 |
|------|------------|
| 可能缺 key / null | 字段可选 `field?: T` |
| 总为数组（可空数组） | `T[]`，解析时 `\|\| []` |
| snake_case JSON | 解析到 camelCase `interface` |
| 嵌套对象 | 独立 `interface` |

## HTTP 模板

```typescript
let result = await request.get<CommonResponseDTO<YourDTO[]>>('path', setUserParam({ ... }));
if (!result.getSuccess()) {
  throw Error(result.getMsg());
}
return result.getDataRow();
```

详见 **`.cursor/rules/http-api-request-convention.mdc`**。
