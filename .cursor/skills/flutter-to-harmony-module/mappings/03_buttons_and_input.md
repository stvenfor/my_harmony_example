# 按钮与输入

## 按钮 / 开关

| Flutter | ArkUI |
|---------|--------|
| `ElevatedButton` / `TextButton` / `OutlinedButton` | `Button`；线框/白底灰边见 **`WordSubmitButton`** + `ButtonType` |
| `onPressed` | `onClick` |
| `Switch` | `Toggle`：`value`↔`isOn`，`onChanged`↔`onChange` |
| `Checkbox` | `Checkbox`：`value`↔`select` |
| `Slider` | `Slider` |
| `Radio` / `RadioListTile` | `Radio` + 分组状态 |

## 文本输入

| Flutter | ArkUI |
|---------|--------|
| `TextField` | `TextInput` / `TextArea` |
| `decoration.hintText` | `placeholder` |
| `TextEditingController` | `@State` 字符串 + `onChange` |
| `onChanged` | `onChange` |
| `keyboardType` / `obscureText` | `type` 等属性 |
| `SearchBar` | `Search` 或 `TextInput` + 前缀图标 |

## 本仓库提示

- 同步练主按钮 / 白底灰边次按钮：优先 **`WordSubmitButton`**（`@ohos/common`），勿手写重复样式。
