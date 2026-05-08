/**
 * 运行环境解析层：把编译期注入的 BuildProfile 字段转为业务可读结构。
 *
 * 数据流：根 build-profile.json5（Product）→ common 某 target 的 buildProfileFields
 * → hvigor 生成/更新 BuildProfile.ets → 本文件读取常量并做类型安全与默认值处理。
 *
 * 不要在业务里写死域名；应通过 getAppEnvBundle() / getApiBaseUrl() 获取。
 */
import BuildProfile from '../BuildProfile'

/**
 * 与根工程 app.products 及 common/build-profile.json5 中各 env_* target 对应。
 * 切换方式：DevEco 顶部 Product 选 test / preRelease / production（或 default 映射到 production 链路的 target）后重新编译。
 */
export type AppEnvKind = 'test' | 'preRelease' | 'production'

/** 当前运行环境可读配置（由编译期 BuildProfile 注入，勿在业务里写死域名） */
export interface AppEnvBundle {
  env: AppEnvKind
  /** HTTP 网关根地址，建议带末尾 / */
  apiBaseUrl: string
  /** H5 / 分享页等可选基地址 */
  webBaseUrl: string
  /** 渠道或包体标识，可给埋点、网关鉴权使用 */
  channelId: string
  /** axios 等超时（毫秒） */
  connectTimeoutMs: number
  /** 是否打印更详细日志（仅开发态建议 true） */
  logVerbose: boolean
}

function parseTimeoutMs(raw: string | number | undefined, fallback: number): number {
  if (raw === undefined) {
    return fallback
  }
  if (typeof raw === 'number') {
    return Number.isFinite(raw) && raw > 0 ? Math.floor(raw) : fallback
  }
  if (raw.length === 0) {
    return fallback
  }
  const n = Number.parseInt(raw, 10)
  return Number.isFinite(n) && n > 0 ? n : fallback
}

function parseLogVerbose(raw: string | boolean | undefined): boolean {
  if (raw === undefined) {
    return false
  }
  if (typeof raw === 'boolean') {
    return raw
  }
  return raw === 'true'
}

function normalizeWebBase(raw: string | undefined): string {
  if (raw === undefined || raw.length === 0 || raw === '-') {
    return ''
  }
  return raw
}

/**
 * 解析当前编译产物对应的环境标识。
 * 若 BuildProfile 未包含 APP_ENV（旧配置），则视为 production。
 */
export function getAppEnvKind(): AppEnvKind {
  const raw: string = BuildProfile.APP_ENV
  if (raw === 'test') {
    return 'test'
  }
  if (raw === 'preRelease') {
    return 'preRelease'
  }
  if (raw === 'production') {
    return 'production'
  }
  return 'production'
}

/**
 * 读取当前包注入的完整环境参数（全部来自 BuildProfile，编译期常量）。
 */
export function getAppEnvBundle(): AppEnvBundle {
  const env = getAppEnvKind()
  const apiBaseUrl: string =
    BuildProfile.API_BASE_URL.length > 0 ? BuildProfile.API_BASE_URL : 'https://www.wanandroid.com/'
  const webBaseUrl: string = normalizeWebBase(BuildProfile.WEB_BASE_URL)
  const channelId: string = BuildProfile.CHANNEL_ID.length > 0 ? BuildProfile.CHANNEL_ID : env
  const connectTimeoutMs: number = parseTimeoutMs(BuildProfile.HTTP_TIMEOUT_MS, 20000)
  const logVerbose: boolean = parseLogVerbose(BuildProfile.LOG_VERBOSE)
  return {
    env,
    apiBaseUrl,
    webBaseUrl,
    channelId,
    connectTimeoutMs,
    logVerbose
  }
}

/** 当前环境 API 根地址（与 {@link getAppEnvBundle} 中 apiBaseUrl 一致） */
export function getApiBaseUrl(): string {
  return getAppEnvBundle().apiBaseUrl
}
