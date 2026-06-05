import { common } from '@kit.AbilityKit'
import { AnimationSegment } from '@ohos/lottie'
import { LottieController } from './LottieUtil'

/** Lottie JSON 资源来源类型 */
export enum LottieResourceSource {
  /** 模块 rawfile：`<module>/src/main/resources/rawfile/` */
  RAWFILE = 'rawfile',
  /** entry ets 相对路径：仅 `entry/src/main/ets/` 下，供 `path` 加载 */
  ENTRY_PATH = 'entry_path',
  /** 已解析的 animationData */
  ANIMATION_DATA = 'animation_data',
  /** 网络 json / zip */
  URI = 'uri'
}

/**
 * Lottie 资源描述（对齐 @ohos/lottie 官方文档）。
 * - entry path（方案 B）：JSON 放 entry/src/main/ets/lottie/，entryPath: lottie/xxx.json，不设 moduleName。
 * - HSP rawfile：其它模块 JSON 放 rawfile，用 rawfilePath + moduleName + animationData。
 * - 序列帧图片：放 entry rawfile/lottie/images/，imagePath: lottie/images/
 */
export interface LottieResourceConfig {
  source: LottieResourceSource
  /** 缓存键；不填时按 rawfilePath / entryPath / uri 自动生成 */
  cacheKey?: string
  /** rawfile 相对路径（不含模块前缀），如 `lottie/guild_animation.json` */
  rawfilePath?: string
  /** HAR hvigor 模块名，如 `DubbingChallenge`；不填则读宿主 entry rawfile */
  moduleName?: string
  /** 模块 ets 相对路径，如 `lottie/guild_animation.json`（对应 src/main/ets/lottie/） */
  entryPath?: string
  /** 序列帧图片目录（相对 rawfile），如 `lottie/images/` */
  imagePath?: string
  /** 网络地址 */
  uri?: string
  /** 已解析 JSON；source 为 ANIMATION_DATA 时必填 */
  animationData?: Object
  /** module rawfile 失败时是否回退 entry rawfile（默认真） */
  fallbackToEntry?: boolean
}

/** 播放与实例配置 */
export interface LottiePlayConfig {
  loop?: boolean | number
  autoplay?: boolean
  /** Fill / Top / Bottom / Cover / Contain */
  contentMode?: string
  initialSegment?: AnimationSegment
  /** 命名实例，用于 `lottie.destroy(name)`；不填则自动生成 */
  instanceName?: string
  /**
   * 组件消失时是否销毁动画实例。
   * 未指定时由 {@link LottieManager.resolveDestroyOnDisappear} 按资源来源决定：
   * - ENTRY_PATH：false（避免列表滚动等场景误销毁 path 实例）
   * - RAWFILE / ANIMATION_DATA / URI：true
   */
  destroyOnDisappear?: boolean
}

/** 画布尺寸（vp / % / 数字均可） */
export interface LottieSizeConfig {
  width: Length
  height: Length
}

/** LottieView 完整配置 */
export interface LottieViewConfig {
  resource: LottieResourceConfig
  play?: LottiePlayConfig
  size: LottieSizeConfig
}

interface LottieCacheEntry {
  data: Object
  loadedAt: number
}

/**
 * 统一管理 Lottie 资源加载、缓存与实例命名。
 * 封装仓库内 {@link LottieController.getRawFileAnimationData}、HAR 回退 entry、预加载等重复逻辑。
 */
export class LottieManager {
  private static readonly cache: Map<string, LottieCacheEntry> = new Map()
  private static instanceSeq: number = 0
  private static cacheDataSeq: number = 0

  /** 推荐：common HSP rawfile 动画目录（相对 rawfile 根） */
  static readonly RAWFILE_LOTTIE_DIR: string = 'lottie/'
  /** entry 模块 ets 内 lottie 目录：entry/src/main/ets/common/lottie/ */
  static readonly ENTRY_LOTTIE_DIR: string = 'common/lottie/'

  static resolveCacheKey(resource: LottieResourceConfig): string {
    if (resource.cacheKey !== undefined && resource.cacheKey.length > 0) {
      return resource.cacheKey
    }
    if (resource.source === LottieResourceSource.RAWFILE && resource.rawfilePath !== undefined) {
      const mod: string = resource.moduleName ?? 'entry'
      return `rawfile:${mod}:${resource.rawfilePath}`
    }
    if (resource.source === LottieResourceSource.ENTRY_PATH && resource.entryPath !== undefined) {
      return `entry_path:${resource.entryPath}`
    }
    if (resource.source === LottieResourceSource.URI && resource.uri !== undefined) {
      return `uri:${resource.uri}`
    }
    if (resource.source === LottieResourceSource.ANIMATION_DATA) {
      LottieManager.cacheDataSeq++
      return `data:${LottieManager.cacheDataSeq}`
    }
    return `lottie:${Date.now()}`
  }

  static getCached(resource: LottieResourceConfig): Object | undefined {
    const key: string = LottieManager.resolveCacheKey(resource)
    return LottieManager.cache.get(key)?.data
  }

  static clearCache(cacheKey?: string): void {
    if (cacheKey === undefined || cacheKey.length === 0) {
      LottieManager.cache.clear()
      return
    }
    LottieManager.cache.delete(cacheKey)
  }

  /**
   * 从 rawfile 加载：优先 moduleName 对应 HAR，失败可回退 entry。
   */
  static async loadRawfileAnimationData(hostContext: common.UIAbilityContext,
    rawfilePath: string,
    moduleName?: string,
    fallbackToEntry: boolean = true): Promise<Object | undefined> {
    if (moduleName !== undefined && moduleName.length > 0) {
      try {
        return await LottieController.getRawFileAnimationData(hostContext, rawfilePath, moduleName)
      } catch (e) {
        const msg: string = e instanceof Error ? e.message : `${e}`
        console.error(`[LottieManager] HAR rawfile fail ${moduleName}/${rawfilePath}: ${msg}`)
      }
    }
    if (!fallbackToEntry && moduleName !== undefined && moduleName.length > 0) {
      return undefined
    }
    try {
      return await LottieController.getRawFileAnimationData(hostContext, rawfilePath)
    } catch (e) {
      const msg: string = e instanceof Error ? e.message : `${e}`
      console.error(`[LottieManager] entry rawfile fail ${rawfilePath}: ${msg}`)
    }
    return undefined
  }

  /**
   * 按 {@link LottieResourceConfig} 加载 animationData；命中缓存则直接返回。
   */
  static async loadAnimationData(hostContext: common.UIAbilityContext,
    resource: LottieResourceConfig): Promise<Object | undefined> {
    const cacheKey: string = LottieManager.resolveCacheKey(resource)
    const hit: Object | undefined = LottieManager.getCached(resource)
    if (hit !== undefined) {
      return hit
    }

    let data: Object | undefined = undefined
    if (resource.source === LottieResourceSource.ANIMATION_DATA) {
      data = resource.animationData
    } else if (resource.source === LottieResourceSource.RAWFILE) {
      if (resource.rawfilePath === undefined) {
        return undefined
      }
      const fallback: boolean = resource.fallbackToEntry !== false
      data = await LottieManager.loadRawfileAnimationData(
        hostContext,
        resource.rawfilePath,
        resource.moduleName,
        fallback
      )
    } else if (resource.source === LottieResourceSource.ENTRY_PATH ||
      resource.source === LottieResourceSource.URI) {
      // path / uri 由 Lottie 组件在 Canvas onReady 时加载，此处不预解析 JSON
      return undefined
    }

    if (data !== undefined) {
      LottieManager.putCache(cacheKey, data)
    }
    return data
  }

  /** 批量预加载（书写页、完成页等场景避免首帧闪烁） */
  static async preloadAll(hostContext: common.UIAbilityContext,
    resources: LottieResourceConfig[]): Promise<void> {
    const tasks: Promise<Object | undefined>[] = []
    for (let i = 0; i < resources.length; i++) {
      tasks.push(LottieManager.loadAnimationData(hostContext, resources[i]))
    }
    await Promise.all(tasks)
  }

  static createInstanceName(prefix: string = 'lottie'): string {
    LottieManager.instanceSeq++
    return `${prefix}-${LottieManager.instanceSeq}`
  }

  /** 拼接 entry 内 lottie 文件名 */
  static entryLottiePath(fileName: string): string {
    return `${LottieManager.ENTRY_LOTTIE_DIR}${fileName}`
  }

  /** 拼接 HAR rawfile 下 lottie 路径 */
  static rawfileLottiePath(fileName: string): string {
    return `${LottieManager.RAWFILE_LOTTIE_DIR}${fileName}`
  }

  /** 序列帧图片目录（相对 rawfile 根），如 lottie/images/ */
  static rawfileImagePath(relativeDir: string): string {
    return relativeDir
  }

  /**
   * 按资源来源解析 destroyOnDisappear，与 LottieView 各分支 `?? true/false` 语义一致。
   */
  static resolveDestroyOnDisappear(source: LottieResourceSource, play?: LottiePlayConfig): boolean {
    if (play?.destroyOnDisappear !== undefined) {
      return play.destroyOnDisappear
    }
    return source !== LottieResourceSource.ENTRY_PATH
  }

  static defaultPlayConfig(): LottiePlayConfig {
    const cfg: LottiePlayConfig = {
      loop: true,
      autoplay: true,
      contentMode: 'Contain',
      destroyOnDisappear: true
    }
    return cfg
  }

  private static putCache(key: string, data: Object): void {
    const entry: LottieCacheEntry = {
      data: data,
      loadedAt: Date.now()
    }
    LottieManager.cache.set(key, entry)
  }
}
