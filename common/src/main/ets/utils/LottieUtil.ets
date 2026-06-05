import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import lottie, {
  AnimationDirection,
  AnimationEventCallback,
  AnimationEventName,
  AnimationItem,
  AnimationSegment,
  BMCompleteEvent,
  BMCompleteLoopEvent,
  BMDestroyEvent,
  BMEnterFrameEvent,
  BMSegmentStartEvent
} from '@ohos/lottie';

/** lottie 事件回调参数联合类型 */
type LottieEventPayload =
  BMDestroyEvent | BMEnterFrameEvent | BMCompleteLoopEvent | BMCompleteEvent | BMSegmentStartEvent


/**
 * lottie 封装组件
 */
@Preview
@Component
export struct LottieUtil {
  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings)
  controller: LottieController = new LottieController()
  @Prop autoPlay: boolean = true
  @Prop contentMode: string = 'Contain'
  @Prop loop: boolean | number = true
  /** HSP 场景必传宿主 UIAbilityContext */
  @Prop context?: common.UIAbilityContext = undefined
  @Prop initialSegment?: AnimationSegment = undefined
  /**
   * loadAnimation path：模块 ets 相对路径，如 lottie/guild_animation.json
   */
  @Prop animationPath?: string = undefined
  /** 序列帧图片目录（相对 rawfile 根），如 lottie/images/ */
  @Prop imagePath?: string = undefined
  @Prop animationData?: Object = undefined
  @Prop animationUri?: string = undefined
  @Prop instanceName?: string = undefined
  @Prop canvasWidth: Length = '100%'
  @Prop canvasHeight: Length = '100%'
  @Prop destroy: boolean = true

  build() {
    Canvas(this.canvasRenderingContext)
      .width(this.canvasWidth)
      .height(this.canvasHeight)
      .onReady(() => {
        if (this.instanceName !== undefined && this.instanceName.length > 0) {
          lottie.destroy(this.instanceName)
        }
        this.canvasRenderingContext.imageSmoothingEnabled = true
        this.canvasRenderingContext.imageSmoothingQuality = 'medium'
        if (this.animationPath !== undefined && this.animationPath.length > 0) {
          if (this.imagePath !== undefined && this.imagePath.length > 0) {
            this.controller.animationItem = lottie.loadAnimation({
              context: this.context,
              container: this.canvasRenderingContext,
              renderer: 'canvas',
              contentMode: this.contentMode,
              loop: this.loop,
              autoplay: this.autoPlay,
              initialSegment: this.initialSegment,
              path: this.animationPath,
              imagePath: this.imagePath,
              name: this.instanceName
            })
          } else {
            this.controller.animationItem = lottie.loadAnimation({
              context: this.context,
              container: this.canvasRenderingContext,
              renderer: 'canvas',
              contentMode: this.contentMode,
              loop: this.loop,
              autoplay: this.autoPlay,
              initialSegment: this.initialSegment,
              path: this.animationPath,
              name: this.instanceName
            })
          }
        } else if (this.animationData !== undefined) {
          if (this.imagePath !== undefined && this.imagePath.length > 0) {
            this.controller.animationItem = lottie.loadAnimation({
              context: this.context,
              container: this.canvasRenderingContext,
              renderer: 'canvas',
              contentMode: this.contentMode,
              loop: this.loop,
              autoplay: this.autoPlay,
              initialSegment: this.initialSegment,
              animationData: this.animationData,
              imagePath: this.imagePath,
              name: this.instanceName
            })
          } else {
            this.controller.animationItem = lottie.loadAnimation({
              context: this.context,
              container: this.canvasRenderingContext,
              renderer: 'canvas',
              contentMode: this.contentMode,
              loop: this.loop,
              autoplay: this.autoPlay,
              initialSegment: this.initialSegment,
              animationData: this.animationData,
              name: this.instanceName
            })
          }
        } else if (this.animationUri !== undefined && this.animationUri.length > 0) {
          this.controller.animationItem = lottie.loadAnimation({
            context: this.context,
            container: this.canvasRenderingContext,
            renderer: 'canvas',
            contentMode: this.contentMode,
            loop: this.loop,
            autoplay: this.autoPlay,
            initialSegment: this.initialSegment,
            uri: this.animationUri,
            name: this.instanceName
          })
        }
      })
      .onDisAppear(() => {
        if (!this.destroy) {
          return
        }
        if (this.instanceName !== undefined && this.instanceName.length > 0) {
          lottie.destroy(this.instanceName)
        }
        this.controller.stop()
        this.controller.destroy()
      })
  }
}


export class LottieController {
  animationItem?: AnimationItem

  /**
   * 从 rawfile 资源文件夹中获取 json 动画对象
   * @param module 用于从 share 库中获取 json 动画对象
   */
  static async getRawFileAnimationData(context: common.Context, path: string, module?: string): Promise<Object> {
    let data: Uint8Array
    if (module) {
      let moduleContext = context.createModuleContext(module) as common.UIAbilityContext
      data = await moduleContext.resourceManager.getRawFileContent(path)
    } else {
      data = await context.resourceManager.getRawFileContent(path)
    }
    let decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true })
    return JSON.parse(decoder.decodeWithStream(new Uint8Array(data)))
  }

  /**
   * 从 rawfile 资源文件夹中获取 json 动画对象
   * @param module 用于从 share 库中获取 json 动画对象
   */
  async getRawFileAnimationData(context: common.Context, path: string, module?: string): Promise<Object> {
    return LottieController.getRawFileAnimationData(context, path, module)
  }

  /**
   * 播放动画
   * @since 8
   * @design
   */
  play() {
    this.animationItem?.play()
    console.log('Lottie---play')
  }

  /**
   * 停止动画
   * @since 8
   * @design
   */
  stop() {
    this.animationItem?.stop()
    console.log('Lottie---stop')
  }

  /**
   * 播放或暂停动画
   * @since 8
   * @design
   */
  togglePause() {
    this.animationItem?.togglePause()
  }

  /**
   * 销毁动画
   * @since 8
   * @design
   */
  destroy() {
    this.animationItem?.destroy()
  }

  /**
   * 暂停动画
   * @since 8
   * @design
   */
  pause() {
    this.animationItem?.pause()
  }

  /**
   * 控制动画画面停止在某一帧或某个时刻
   * @param value 帧号(值>=0)或时刻(ms)
   * @param isFrame true按帧控制, false按时间控制, 缺省默认false
   * @since 8
   * @design
   */
  goToAndStop(value: number, isFrame?: boolean) {
    this.animationItem?.goToAndStop(value, isFrame)
  }

  /**
   * 控制动画画面从在某一帧或某个时刻开始播放
   * @param value 帧号(>=0)或时刻(ms)
   * @param isFrame true按帧控制, false按时间控制, 缺省默认false
   * @since 8
   * @design
   */
  goToAndPlay(value: number, isFrame?: boolean) {
    this.animationItem?.goToAndPlay(value, isFrame)
  }

  /**
   * 限定动画资源播放时的整体帧范围
   * @param init 起始帧号
   * @param end 结束帧号
   * @since 8
   * @design
   */
  setSegment(init: number, end: number) {
    this.animationItem?.setSegment(init, end)
  }

  /**
   * 重置动画播放片段, 使动画重新从第一帧开始播放完整动画
   * @param forceFlag 值为true立刻生效, 值为false循环下次播放的时候生效
   * @since 8
   * @design
   */
  resetSegments(forceFlag: boolean) {
    this.animationItem?.resetSegments(forceFlag)
  }

  /**
   * 刷新动画布局
   * @since 8
   * @design
   */
  resize() {
    this.animationItem?.resize()
  }

  /**
   * 设置播放速度
   * @param speed 值为浮点类型, speed>0正向播放, speed<0反向播放, speed=0暂停播放, speed=1.0/-1.0正常速度播放
   * @since 8
   * @design
   */
  setSpeed(speed: number) {
    this.animationItem?.setSpeed(speed)
  }

  /**
   * 设置播放方向
   * @param direction 1为正向, -1为反向
   * @since 8
   * @design
   */
  setDirection(direction: AnimationDirection) {
    this.animationItem?.setDirection(direction)
  }

  /**
   * 设置仅播放指定范围的帧动画
   * @param segments 片段或片段数组; 若传入的是数组, 且当前loop!=0, 播放结束后, 仅循环播放最后一个片段
   * @param forceFlag 值为true立刻生效, 值为false循环下次播放的时候生效
   * @since 8
   * @design
   */
  playSegments(segments: AnimationSegment | AnimationSegment[], forceFlag?: boolean) {
    this.animationItem?.playSegments(segments, forceFlag)
  }

  /**
   * 设置是否尽可能地更新动画帧率
   * @param useSubFrames 默认值是true, 值为true时尽可能的更新动画帧率, 值为false时尊重原始AE fps
   * @since 8
   * @design
   */
  setSubframe(useSubFrames: boolean) {
    this.animationItem?.setSubframe(useSubFrames)
  }

  /**
   * 获取动画单次完整播放的时间(与播放速度无关)或帧数, 与Lottie.loadAnimation接口入参initialSegment有关
   * @param inFrames 值为true时获取帧数, 值为false时获取时间(单位ms)
   * @since 8
   * @design
   */
  getDuration(inFrames?: boolean): number | undefined {
    return this.animationItem?.getDuration(inFrames)
  }

  /**
   * 直接触发指定事件的所有已设置的回调
   * @param name 事件名称, 有效范围见AnimationEventName声明
   * @param args 用户自定义回调参数
   * @since 8
   * @design
   */
  triggerEvent(name: AnimationEventName, args: LottieEventPayload) {
    this.animationItem?.triggerEvent(name, args)
  }

  /**
   * 添加侦听事件, 事件完成后会触发指定回调函数
   * @param name 事件名称, 有效范围见AnimationEventName声明
   * @param AnimationEventCallback 用户自定义回调函数
   * @since 8
   * @design
   */
  addEventListener(name: AnimationEventName, callback: AnimationEventCallback<LottieEventPayload>) {
    this.animationItem?.addEventListener(name, callback)
  }

  /**
   * 删除侦听事件
   * @param name 事件名称, 有效范围见AnimationEventName声明
   * @param AnimationEventCallback 用户自定义回调函数； 缺省为空时, 删除此事件的所有回调函数。
   * @since 8
   * @design
   */
  removeEventListener(name: AnimationEventName, callback?: AnimationEventCallback<LottieEventPayload>) {
    this.animationItem?.removeEventListener(name, callback)
  }

  /**
   * 修改动画颜色
   * @param color 颜色数组RGBA
   * @param layer 层次的下标值
   * @param index 对应层次里面的elements的下标值
   */
  changeColor(color: number[], layer?: number, index?: number) {
    this.animationItem?.changeColor(color, layer, index)
  }

  /**
   * 修改动画的关键帧颜色
   * @param startColor 开始颜色数组RGBA
   * @param endColor 结束颜色数组RGBA
   * @param layer 层次的下标值
   * @param index 对应层次里面的elements的下标值
   */
  changeSegmentColor(startColor: number[], endColor: number[], layer?: number, index?: number) {
    this.animationItem?.changeColor(startColor, endColor, layer, index)
  }
}