/**
 * 编译期常量（BuildProfile）：构建时根据当前选中的 common「target」
 * 将 buildProfileFields 写入本文件各 export 常量。
 *
 * 约束：
 * - 文件必须位于 common/src/main/ets，否则 HSP 打包后业务模块可能读不到注入值。
 * - 勿在业务代码中 import 错误层级的 BuildProfile；AppEnvironment 已做统一解析。
 * - 若本地出现「未随 Product 变化」的残留，执行 Clean 后全量编译。
 */
export const HAR_VERSION = '1.0.0'
export const BUILD_MODE_NAME = 'debug'
export const DEBUG = true
export const TARGET_NAME = 'default'

/** 当前环境：test | preRelease | production */
export const APP_ENV: string = 'production'
/** HTTP 网关根地址 */
export const API_BASE_URL: string = 'https://www.wanandroid.com/'
/** H5 / Web 基地址；未配置或 "-" 表示不使用 */
export const WEB_BASE_URL: string = '-'
/** 渠道或包标识 */
export const CHANNEL_ID: string = 'production'
/** 请求超时（毫秒），与 buildProfileFields 中 number 类型一致 */
export const HTTP_TIMEOUT_MS: number = 15000
/** 是否详细日志 */
export const LOG_VERBOSE: boolean = false

export default class BuildProfile {
  static readonly HAR_VERSION = HAR_VERSION
  static readonly BUILD_MODE_NAME = BUILD_MODE_NAME
  static readonly DEBUG = DEBUG
  static readonly TARGET_NAME = TARGET_NAME
  static readonly APP_ENV = APP_ENV
  static readonly API_BASE_URL = API_BASE_URL
  static readonly WEB_BASE_URL = WEB_BASE_URL
  static readonly CHANNEL_ID = CHANNEL_ID
  static readonly HTTP_TIMEOUT_MS = HTTP_TIMEOUT_MS
  static readonly LOG_VERBOSE = LOG_VERBOSE
}
