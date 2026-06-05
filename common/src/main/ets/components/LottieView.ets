import { common } from '@kit.AbilityKit'
import { LottieController, LottieUtil } from '../utils/LottieUtil'
import {
  LottieManager,
  LottiePlayConfig,
  LottieResourceConfig,
  LottieResourceSource,
  LottieSizeConfig
} from '../utils/LottieManager'

/**
 * Lottie 展示组件。
 * - entry ets path：JSON 在 entry/src/main/ets/common/lottie/，path 加载（勿设 moduleName）
 * - HSP rawfile：animationData + createModuleContext（其它模块兜底）
 * - 序列帧：imagePath 指向 entry rawfile 下 lottie/images/
 */
@Component
export struct LottieView {
  @Prop resource: LottieResourceConfig = {
    source: LottieResourceSource.ENTRY_PATH,
    entryPath: 'common/lottie/guild_animation.json'
  }
  @Prop play: LottiePlayConfig = LottieManager.defaultPlayConfig()
  @Prop lottieSize: LottieSizeConfig = { width: 120, height: 120 }
  @Prop uiContext?: common.UIAbilityContext = undefined
  /** 与 LottieUtil 共享同一实例，供外部 play/pause */
  controller: LottieController = new LottieController()

  @State private animationData?: Object = undefined
  @State private dataReady: boolean = false
  @State private loadFailed: boolean = false
  private hostContext?: common.UIAbilityContext = undefined
  private instanceName: string = LottieManager.createInstanceName()

  aboutToAppear(): void {
    this.hostContext = this.uiContext ?? (getContext(this) as common.UIAbilityContext)
    if (this.play.instanceName !== undefined && this.play.instanceName.length > 0) {
      this.instanceName = this.play.instanceName
    }
    void this.prepareResource()
  }

  /** HSP 场景传 createModuleContext，供 loadAnimation 读取对应模块 rawfile */
  private resolveLottieContext(): common.UIAbilityContext | undefined {
    if (this.hostContext === undefined) {
      return undefined
    }
    if (this.resource.moduleName !== undefined && this.resource.moduleName.length > 0) {
      try {
        return this.hostContext.createModuleContext(this.resource.moduleName) as common.UIAbilityContext
      } catch (e) {
        const msg: string = e instanceof Error ? e.message : `${e}`
        console.error(`[LottieView] createModuleContext(${this.resource.moduleName}) fail: ${msg}`)
      }
    }
    return this.hostContext
  }

  private async prepareResource(): Promise<void> {
    if (this.resource.source === LottieResourceSource.ANIMATION_DATA) {
      this.animationData = this.resource.animationData
      this.dataReady = this.animationData !== undefined
      this.loadFailed = !this.dataReady
      return
    }
    if (this.resource.source === LottieResourceSource.ENTRY_PATH ||
      this.resource.source === LottieResourceSource.URI) {
      this.dataReady = true
      return
    }
    if (this.resource.source === LottieResourceSource.RAWFILE) {
      if (this.hostContext === undefined) {
        this.loadFailed = true
        return
      }
      const cached: Object | undefined = LottieManager.getCached(this.resource)
      if (cached !== undefined) {
        this.animationData = cached
        this.dataReady = true
        return
      }
      const data: Object | undefined =
        await LottieManager.loadAnimationData(this.hostContext, this.resource)
      if (data !== undefined) {
        this.animationData = data
        this.dataReady = true
      } else {
        this.loadFailed = true
        console.error(`[LottieView] rawfile load fail: ${this.resource.rawfilePath ?? ''}`)
      }
      return
    }
    this.loadFailed = true
  }

  private resolvedWidth(): Length {
    return this.lottieSize.width
  }

  private resolvedHeight(): Length {
    return this.lottieSize.height
  }

  @Builder
  private emptyPlaceholder() {
    Row()
      .width(this.resolvedWidth())
      .height(this.resolvedHeight())
      .hitTestBehavior(HitTestMode.None)
  }

  @Builder
  private failedPlaceholder() {
    Row() {
      Text('加载失败')
        .fontSize(12)
        .fontColor('#999999')
    }
    .width(this.resolvedWidth())
    .height(this.resolvedHeight())
    .justifyContent(FlexAlign.Center)
    .hitTestBehavior(HitTestMode.None)
  }

  private resolvedDestroyOnDisappear(): boolean {
    return LottieManager.resolveDestroyOnDisappear(this.resource.source, this.play)
  }

  build() {
    if (this.loadFailed) {
      this.failedPlaceholder()
    } else if (!this.dataReady) {
      this.emptyPlaceholder()
    } else if (this.resource.source === LottieResourceSource.RAWFILE ||
      this.resource.source === LottieResourceSource.ANIMATION_DATA) {
      if (this.animationData === undefined) {
        this.emptyPlaceholder()
      } else {
        LottieUtil({
          controller: this.controller,
          context: this.resolveLottieContext(),
          autoPlay: this.play.autoplay ?? true,
          loop: this.play.loop ?? true,
          destroy: this.resolvedDestroyOnDisappear(),
          animationData: this.animationData,
          imagePath: this.resource.imagePath,
          contentMode: this.play.contentMode ?? 'Contain',
          initialSegment: this.play.initialSegment,
          instanceName: this.instanceName,
          canvasWidth: this.resolvedWidth(),
          canvasHeight: this.resolvedHeight()
        })
      }
    } else if (this.resource.source === LottieResourceSource.ENTRY_PATH) {
      LottieUtil({
        controller: this.controller,
        context: this.hostContext,
        autoPlay: this.play.autoplay ?? true,
        loop: this.play.loop ?? true,
        destroy: this.resolvedDestroyOnDisappear(),
        animationPath: this.resource.entryPath,
        imagePath: this.resource.imagePath,
        contentMode: this.play.contentMode ?? 'Contain',
        initialSegment: this.play.initialSegment,
        instanceName: this.instanceName,
        canvasWidth: this.resolvedWidth(),
        canvasHeight: this.resolvedHeight()
      })
    } else if (this.resource.source === LottieResourceSource.URI) {
      LottieUtil({
        controller: this.controller,
        context: this.hostContext,
        autoPlay: this.play.autoplay ?? true,
        loop: this.play.loop ?? true,
        destroy: this.resolvedDestroyOnDisappear(),
        animationUri: this.resource.uri,
        contentMode: this.play.contentMode ?? 'Contain',
        initialSegment: this.play.initialSegment,
        instanceName: this.instanceName,
        canvasWidth: this.resolvedWidth(),
        canvasHeight: this.resolvedHeight()
      })
    } else {
      this.emptyPlaceholder()
    }
  }
}
