/**
 * @ohos/common（HSP）对外聚合导出入口。
 *
 * 使用约定：
 * 1. 其它模块在 oh-package.json5 中声明 "@ohos/common": "file:相对路径/common"。
 * 2. entry 的 module.json5 须声明对 common 的 dependencies（bundleName 与 AppScope/app.json5 一致）。
 * 3. 业务只应 import 本文件暴露的符号，避免直接依赖 common 内部深层路径。
 *
 * 多环境：见 docs/COMMON_HSP_使用说明.md；运行时读 getAppEnvBundle / getApiBaseUrl。
 */
export { StyleConstants } from './src/main/ets/constants/StyleConstants';

export { BreakpointConstants } from './src/main/ets/constants/BreakpointConstants'

export { CommonConstants } from './src/main/ets/constants/CommonConstants'

export { BreakpointSystem, BreakPointType } from './src/main/ets/utils/BreakpointSystem'

export { RouteConstants } from './src/main/ets/constants/RouteConstants'

export { CommonGrid } from './src/main/ets/components/CommonGrid'

export { CommonImageText } from './src/main/ets/components/CommonImageText'

export { RawfileUtil } from './src/main/ets/utils/RawfileUtil'

export { GridModel } from './src/main/ets/model/GridModel'

export { updateBreakPoint } from './src/main/ets/utils/LayoutTool'

export {
  AdaptiveProfile,
  DeviceLayoutMode,
  buildAdaptiveProfile,
  syncAdaptiveProfile
} from './src/main/ets/utils/AdaptiveProfile'

export { NavItem, NAV_ITEM_BAR_HEIGHT } from './src/main/ets/components/NavItem'

export { PageHeaderComp } from './src/main/ets/components/PageHeaderComp'

export { NavConstants } from './src/main/ets/constants/NavConstants'

export { NavInfo } from './src/main/ets/model/NavModel'

export { StringConstants } from './src/main/ets/constants/StringConstants'

export { ConfigParams } from './src/main/ets/constants/ConfigParams'

export {
  AppEnvBundle,
  AppEnvKind,
  getApiBaseUrl,
  getAppEnvBundle,
  getAppEnvKind
} from './src/main/ets/constants/AppEnvironment'

export { buildCommonQueryMapWithTimestamp, KEY_SERVER_TIME_OFFSET } from './src/main/ets/utils/CommonQueryTimestamp'

export { SpineAnimationManager } from './src/main/ets/utils/SpineAnimationManager'

export { SpineResourceConfig } from './src/main/ets/utils/SpineAnimationManager'

export { ResourceSourceType } from './src/main/ets/utils/SpineAnimationManager'

export { CommonGridRow } from './src/main/ets/components/CommonGridRow'

export { replaceLpx2Vp } from './src/main/ets/utils/LayoutTool'

export { ResBasicModel } from './src/main/ets/model/ResBasicModel'

export {
  ApiResult,
  HttpRequestOptions,
  IsolatedHttpClient,
  IsolatedHttpClientOptions,
  WAN_ANDROID_BASE_URL,
  getHttpClient,
  httpGet,
  httpPost,
  resetHttpLoadingState
} from './src/main/ets/utils/Request'


export {
  CommonVideoPlayer,
  UniversalVideoPlayerController,
  UniversalVideoPlayerEngine,
  normalizeMediaUrl
} from './src/main/ets/components/CommonVideoPlayer'


export {
  PopupDialogQueueManager,
  PopupQueuePriority,
  POPUP_SCOPE_APP,
  popupScopeForPage
} from './src/main/ets/utils/PopupDialogQueueManager'

export {
  SupabaseClient,
  SupabaseConfig,
  SupabaseQueryParams,
  SupabaseResult,
  SupabaseError,
  createSupabaseClient
} from './src/main/ets/utils/SupabaseClient'

export { AppUtil,
  WindowUtil,
  DeviceUtil,
  ToastUtil,
  DialogUtil,
  LogUtil,
  PreferencesUtil,
  CacheUtil,
  NetworkUtil,
  EmitterUtil,
  LRUCacheUtil,
  GlobalContext,
  FileUtil,
  ImageUtil,
  SnapshotUtil,
  PreviewUtil,
  DateUtil,
  StrUtil,
  Base64Util,
  NumberUtil,
  JSONUtil,
  AssetUtil,
  CryptoUtil,
  RSA,
  MD5,
  AES ,
  CryptoHelper} from '@pura/harmony-utils'
