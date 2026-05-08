# common 共享模块（HSP）使用说明

本文说明工程内 **`common`** 模块（类型为 **shared**，即 HSP）的依赖方式、多环境编译、运行时 API，以及与 **HTTP / 请求头 / 时间戳** 相关工具的配合方式。

---

## 1. 模块定位

| 项 | 说明 |
| --- | --- |
| 路径 | 工程根目录下的 `common/` |
| 模块类型 | `shared`（HSP，随主应用打包或按需分发，由工程配置决定） |
| 对外包名 | `@ohos/common`（在 `oh-package.json5` 的 `dependencies` 中引用） |
| 聚合导出 | `common/Index.ets`：业务与其它 Feature 应通过此处声明的符号使用公共能力 |

**原则**：业务代码优先 `import { ... } from '@ohos/common'`，避免深层相对路径穿透 HSP 内部实现，便于后续拆分与版本管理。

---

## 2. 主模块与其它模块如何依赖 common

### 2.1 编译期（ohpm / OHM）

在**会引用 `@ohos/common` 的模块**目录下的 `oh-package.json5` 中声明依赖，例如：

- **entry**：`"@ohos/common": "file:../common"`
- **features/home**：`"@ohos/common": "file:../../common"`（路径按相对位置调整）

修改后建议在工程根执行一次依赖安装（以你本地 DevEco / ohpm 习惯为准），保证 `oh_modules` 解析正确。

### 2.2 安装期（HAP 声明运行时依赖）

**entry**（以及若存在其它独立安装的 HAP）在 `entry/src/main/module.json5` 的 `module` 中需配置 **`dependencies`**，指向本应用的 **bundleName** 与 **common** 的 **moduleName**：

```json5
"dependencies": [
  {
    "bundleName": "com.example.mixtrue_oh",
    "moduleName": "common"
  }
]
```

其中 **`bundleName`** 必须与 **`AppScope/app.json5`** 中 `app.bundleName` **完全一致**。若修改应用包名，请同步修改此处，否则安装阶段可能报错（例如 **9568305：dependent module does not exist**）。

### 2.3 Feature 模块

Feature 一般为 HAR，编译期通过 `oh-package.json5` 依赖 `@ohos/common` 即可；**最终以 entry 打整包安装**时，仍需保证 **entry → common** 的 `module.json5` 依赖链完整（见上文）。

---

## 3. 多环境（test / preRelease / production）

### 3.1 根工程 `build-profile.json5`

- **`app.products`**：定义可选的 **Product** 名称（如 `default`、`test`、`preRelease`、`production`）。
- **`modules` 中 `common` 的 `targets`**：每个 target 通过 **`applyToProducts`** 绑定到上述 Product。

切换环境时：在 **DevEco Studio** 顶部 **Product** 选择对应项后 **重新编译运行**。同一套源码会按映射编译出对应 **common** target，进而生成不同的编译期常量。

### 3.2 `common/build-profile.json5`

在各 **`targets[].config.buildOption.arkOptions.buildProfileFields`** 中配置键值，典型字段包括：

| 字段 | 含义 |
| --- | --- |
| `APP_ENV` | 环境标识：`test` / `preRelease` / `production` |
| `API_BASE_URL` | HTTP 网关根地址（建议带末尾 `/`） |
| `WEB_BASE_URL` | H5 等 Web 基地址；不需要时可填 **`"-"`**，运行时会归一成空串 |
| `CHANNEL_ID` | 渠道或包体标识，可用于请求头、埋点 |
| `HTTP_TIMEOUT_MS` | 超时毫秒数（**number** 类型） |
| `LOG_VERBOSE` | 是否详细日志（**boolean**） |

**注意**：`buildProfileFields` 的值类型需符合构建系统要求（字符串、数字、布尔等）；非法结构会导致 **common** 的 `build-profile` 校验失败。

### 3.3 运行时读取：`AppEnvironment` 与 `BuildProfile`

- **`BuildProfile`**（`common/src/main/ets/BuildProfile.ets`）：由构建根据 `buildProfileFields` **生成/覆盖**的编译期常量，**不要手写业务分支去改文件默认值**，应以实际编译产物为准。
- **`AppEnvironment`**：对 `BuildProfile` 做解析与兜底（如 `WEB_BASE_URL` 为 `-` 时转为 `''`，超时非法时回退默认毫秒数等）。

推荐 API：

- `getAppEnvKind()`：当前环境枚举。
- `getAppEnvBundle()`：一次性读取环境、API 根地址、Web 基地址、渠道、超时、日志开关等。
- `getApiBaseUrl()`：仅取 API 根地址（与 `getAppEnvBundle().apiBaseUrl` 一致）。

---

## 4. HTTP 封装（`Request`）

路径：`common/src/main/ets/utils/Request.ets`，经 `common/Index.ets` 再导出。

- **默认 `baseURL`**：来自 `getApiBaseUrl()`；若未配置有效 `API_BASE_URL`，会回退到玩 Android 开放站约定地址（见源码常量 `WAN_ANDROID_BASE_URL`）。
- **默认超时**：来自 `getAppEnvBundle().connectTimeoutMs`。
- **全局 Loading**：与 `@pura/harmony-dialog` 配合，多请求共享引用计数；异常或切账号等可调用 **`resetHttpLoadingState()`** 强制关闭。

使用步骤简述：

1. 确保在具备 **UIAbilityContext** 的场景发起请求（以便内部绑定 `DialogHelper`），或接受首次无上下文时 Loading 可能稍晚生效。
2. 使用 **`getHttpClient()`** 或封装的 **`httpGet` / `httpPost`**（以工程导出为准）发起请求。
3. 响应结构若符合项目约定的 `errorCode` / `errorMsg` / `data`，会映射为 **`ApiResult<T>`**。

---

## 5. 业务请求头（`HttpHeaderUtil`，位于 home Feature）

`features/home/src/main/ets/utils/HttpHeaderUtil.ets` 依赖 `@ohos/common` 中的 **`getAppEnvBundle` / `getAppEnvKind`** 与 **`buildCommonQueryMapWithTimestamp`**。

- **`getHttpHeaderDic()`**：异步组装设备、应用版本、环境/渠道等 Header；环境相关字段会随 **Product → common target → BuildProfile** 变化。
- **`dictionaryWithTimestamp()`**：在公共 query 上追加 **`timestamp`**（见下一节）。

若其它 Feature 也需要相同能力，可复用 **common** 内 API 或抽一层薄封装，避免复制粘贴。

---

## 6. 带服务器时间校准的公共 Query（`CommonQueryTimestamp`）

- **`buildCommonQueryMapWithTimestamp()`**：从 **preferences**（与 `HttpHeaderUtil` 使用同一 store 名 **`app_settings`**）读取 **`KEY_SERVER_TIME_OFFSET`**（`kServerTimeOffsetSeconds`），将 **客户端秒级时间戳 + 偏移** 写入 `timestamp` 字段。
- 业务在登录后或 NTP/服务端时间接口返回后，将**服务端与本地的时间差（秒）**写入该 key，即可让后续请求时间与服务端对齐。

---

## 7. `common/Index.ets` 再导出一览（维护参考）

聚合导出包括但不限于：常量、路由、布局工具、通用 UI（如 `PageHeaderComp`、`CommonVideoPlayer`）、`PopupDialogQueueManager`、`Request` 系列、`AppEnvironment`、`CommonQueryTimestamp`，以及对 **`@pura/harmony-utils`** 的常用工具再导出。

新增对外 API 时：

1. 在 `src/main/ets` 内实现；
2. 在 **`common/Index.ets`** 增加 `export`；
3. 在本文或模块内注释中补充用途，便于其它 Feature 接入。

---

## 8. 常见问题

| 现象 | 可能原因 | 处理 |
| --- | --- | --- |
| 安装报错 **9568305**，提示 entry 依赖的 **common** 不存在 | entry 的 `module.json5` 未声明 `dependencies`，或 `bundleName` 与 `app.json5` 不一致 | 按第 2.2 节补全并核对 **bundleName** |
| 编译找不到 `@ohos/common` | 当前模块 `oh-package.json5` 未声明 `file:../common`（或路径错误） | 补全依赖并刷新 ohpm |
| `getAppEnvBundle` 等运行异常或值始终为默认 | `BuildProfile` 未随 target 注入；或文件不在 **HSP 编译进包的目录**（应在 `common/src/main/ets`） | 检查 **common** 的 **target** 与 **buildProfileFields** 配置 |
| `build-profile.json5` 校验失败 | `buildProfileFields` 放在错误层级 | 应位于 **`config.buildOption.arkOptions.buildProfileFields`** |

---

## 9. 建议工作流（每次发版前）

1. 确认 **`AppScope/app.json5`** 的 **bundleName** 与各 HAP **`dependencies.bundleName`** 一致。  
2. 在目标 **Product** 下 **Clean Project** 后 **Rebuild**。  
3. 真机/模拟器安装验证：环境头字段、API 域名、超时是否符合该环境预期。  

如需把 **其它 Feature** 也打成独立 HAP，需同样在其 `module.json5` 中声明对 **common** 的 **dependencies**（规则与 entry 相同）。
