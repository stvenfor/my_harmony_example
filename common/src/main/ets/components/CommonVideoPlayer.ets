/**
 * ==================================================================================
 * UniversalVideoPlayer — 通用视频播放组件（与业务、页面路由无关）
 * ==================================================================================
 *
 * 【能力一览】
 *  - 播放源：http(s) 网络地址；本地绝对路径（无协议时由 normalizeMediaUrl 补全为 file://）；
 *    已含 file://、fd://、datashare:// 的字符串原样使用。
 *  - 控制：播放 / 暂停 / 停止（回到起点并暂停，不销毁实例）/ 进度拖动 seek / 当前与总时长 /
 *    音量 / 倍速 / 循环播放。
 *  - 全屏：切换窗口布局全屏并横屏；退出时恢复进入全屏前记录的方向（无记录则竖屏）。
 *  - 生命周期：aboutToDisappear 自动 release AVPlayer、退出全屏、controller.detach；
 *    src 变更（@Watch）会换源并重建解码链路（先 release 再 create）。
 *  - 缓冲表现：initialized 后展示加载圈，直至 prepared/playing。
 *
 * 【使用前提】
 *  - 必须运行在具备 UIAbilityContext 的页面中（内部通过 getContext + windowStage 取主窗口），
 *    否则全屏与方向相关能力无效，但播放仍可进行。
 *  - 从任意 HAR 引入：`import { UniversalVideoPlayer, UniversalVideoPlayerController } from '@ohos/common'`
 *
 * ----------------------------------------------------------------------------------
 * 示例 1：仅声明式 —— 只传地址与展示高度，适合详情内嵌小视频
 * ----------------------------------------------------------------------------------
 *
 *   @Entry
 *   @Component
*   struct VideoDemoPage {
 *     @State videoUrl: string = 'https://sf1-cdn-tos.huoshanstatic.com/obj/media-fe/xgplayer_doc_video/mp4/xgplayer-demo-360p.mp4';
 *
 *     build() {
 *       Column() {
 *         UniversalVideoPlayer({
 *           src: this.videoUrl,
 *           autoPlay: true,
 *           loop: false,
 *           layoutHeightVp: 220,
 *           surfaceKey: 'demo_single',
 *           showControls: true,
 *           onStateChange: (s) => { console.info('[UVP] state=' + s); },
 *           onPlayEnd: () => { console.info('[UVP] 单次播放结束'); }
 *         })
 *       }
 *       .width('100%')
 *       .height('100%');
 *     }
 *   }
 *
 * ----------------------------------------------------------------------------------
 * 示例 2：外部控制器 —— 同一页面其它按钮遥控播放（注意 attach 时机）
 * ----------------------------------------------------------------------------------
 *
 *   @Entry
 *   @Component
*   struct VideoRemotePage {
 *     @State videoUrl: string = 'https://.../a.mp4';
 *     // 控制器由页面持有；XComponent.onLoad 内组件会调用 controller.attach(engine)
 *     @State videoCtrl: UniversalVideoPlayerController = new UniversalVideoPlayerController();
 *
 *     build() {
 *       Column() {
 *         Row() {
 *           Button('播放').onClick(() => this.videoCtrl.play());
 *           Button('暂停').onClick(() => this.videoCtrl.pause());
 *           Button('停止').onClick(() => { void this.videoCtrl.stop(); });
 *           Button('15秒').onClick(() => this.videoCtrl.seek(15 * 1000));
 *         }
 *         UniversalVideoPlayer({
 *           src: this.videoUrl,
 *           controller: this.videoCtrl,
 *           autoPlay: false,
 *           layoutHeightVp: 240,
 *           surfaceKey: 'demo_remote'
 *         })
 *       }
 *       .width('100%')
 *       .height('100%');
 *     }
 *   }
 *
 * ----------------------------------------------------------------------------------
 * 示例 3：本地文件（沙箱内绝对路径，注意不要硬编码敏感路径）
 * ----------------------------------------------------------------------------------
 *
 *   // 假设 context.filesDir + '/cache/clip.mp4' 已存在
 *   @State localPath: string = '/data/storage/el2/base/haps/entry/files/clip.mp4';
 *   UniversalVideoPlayer({ src: this.localPath, surfaceKey: 'local', layoutHeightVp: 200 });
 *
 * ----------------------------------------------------------------------------------
 * @Prop / 回调 速查
 * ----------------------------------------------------------------------------------
 *  src            播放地址；变更后自动换源（引擎 release 后重建）
 *  autoPlay       prepared 后是否自动 play（用户 pause/stop 会参与判断）
 *  loop           播放 completed 后是否 seek(0) 再 play
 *  showControls   是否显示内置控制条与倍速音量
 *  surfaceKey     同页多播放器时必传不同字符串，对应 XComponent id 后缀
 *  videoScaleType AVPlayer 画面缩放，如 FIT、FIT_CROP 等
 *  layoutHeightVp 非全屏时组件高度(vp)；点击全屏后外层 height 为 100%
 *  controller     可选；传入后可在 attach 之后调用 play/pause/stop/seek/setSource/release
 *  onStateChange  引擎聚合 UI 状态：idle | buffering | prepared | playing | paused | ended | error
 *  onPlayEnd      非循环且自然播放至结尾时触发（与 ended 状态对应业务侧收尾）
 *
 * ----------------------------------------------------------------------------------
 * 与 UniversalVideoPlayerEngine 的关系
 * ----------------------------------------------------------------------------------
 *  Engine 绑定单个 AVPlayer 与 surfaceId，处理状态机；一般业务只使用 Component + Controller。
 *  若需单测或自定义 UI，可复制状态机思路单独实例化 Engine（需自行提供 XComponent surfaceId）。
 *
 * ==================================================================================
 */
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import window from '@ohos.window';

/**
 * 对外控制器：由页面 / 父组件持有实例，通过 @Prop 传入 UniversalVideoPlayer。
 *
 * 绑定时机：XComponent.onLoad 内创建 UniversalVideoPlayerEngine 后会调用 controller.attach(engine)。
 * 因此 **在页面 aboutToAppear 里立刻调 play() 可能无效**（引擎尚未创建），应放在用户交互或
 * onStateChange 观察到 prepared/playing 之后再调用，或在 attach 已发生的时机调用。
 *
 * detach 由组件 aboutToDisappear 调用，避免页面仍持有已销毁引擎引用。
 */
export class UniversalVideoPlayerController {
  /** 当前绑定的内部引擎；attach 前为 null */
  private engine: UniversalVideoPlayerEngine | null = null;

  /** 由 UniversalVideoPlayer 在 XComponent.onLoad 内调用以注入引擎；业务代码勿手动 attach */
  attach(engine: UniversalVideoPlayerEngine): void {
    this.engine = engine;
  }

  /** 解绑引用，防止野指针 */
  detach(): void {
    this.engine = null;
  }

  /** 播放：支持 prepared / paused / completed；若处于 idle 且已配置 src 会重新设置 url 走初始化 */
  play(): void {
    this.engine?.play();
  }

  /** 暂停：仅在 playing 态生效 */
  pause(): void {
    this.engine?.pause();
  }

  /**
   * 停止到起点并暂停：seek(0) + pause，**不**调用 AVPlayer.stop/reset，实例保留可再次 play。
   * 若需彻底释放解码与 Surface 资源，请使用 release() 或移除组件。
   */
  stop(): void {
    void this.engine?.stop();
  }

  /**
   * 跳转播放位置
   * @param timeMs 毫秒，与 AVPlayer.currentTime / duration 单位一致
   */
  seek(timeMs: number): void {
    this.engine?.seek(timeMs);
  }

  /**
   * 设置输出音量
   * @param volume01 线性音量 0.0 ~ 1.0（与 AVPlayer.setVolume 一致）
   */
  setVolume(volume01: number): void {
    this.engine?.setVolume(volume01);
  }

  /** 设置播放倍速（枚举值需与系统支持的 PlaybackSpeed 一致） */
  setSpeed(speed: media.PlaybackSpeed): void {
    this.engine?.setSpeed(speed);
  }

  /**
   * 切换媒体地址：内部会 release 旧 AVPlayer 并创建新实例再设 url。
   * 异步执行，无需 await；若需严格顺序请在 onStateChange 里接状态。
   */
  setSource(url: string): void {
    void this.engine?.setSource(url);
  }

  /** 释放播放器；调用后如需再播应重新挂载组件或等待下一次换 src 由组件重建 */
  release(): void {
    void this.engine?.release();
  }

  /** 是否处于 playing（由引擎在 stateChange 中维护的布尔标记） */
  isPlaying(): boolean {
    return this.engine?.isPlaying() ?? false;
  }
}

/**
 * 内部引擎：封装单个 media.AVPlayer 与官方状态流转（idle → initialized → prepared → playing …）。
 *
 * 典型链路：createAVPlayer → 设置 url → initialized 回调里 surfaceId + prepare()
 * → prepared 里应用音量/倍速/缩放并按 autoPlay 决定是否 play()。
 *
 * 回调说明：
 *  - onState：供 UI 展示缓冲圈、控制栏状态等
 *  - onTime：timeUpdate / durationUpdate / seekDone 聚合刷新进度条
 *  - onError：解码或网络错误；内部会 reset 尝试恢复空闲态
 *  - onEnded：自然播放结束且非循环时由 completed 分支触发一次
 *
 * 防串台：所有回调首行判断 this.avPlayer === p，避免 release 后旧实例异步回调污染新逻辑。
 */
export class UniversalVideoPlayerEngine {
  /** 当前媒体实例；releaseInternal 时先置 null 再对旧实例 release，避免重入 */
  private avPlayer: media.AVPlayer | null = null;
  /** XComponent 提供的 SurfaceId，必须在 prepare 前赋值给 AVPlayer */
  private surfaceId: string = '';
  /** 最近一次业务侧设置的原始地址（用于 idle 后 play 重新 set url） */
  private src: string = '';
  /** prepared 成功后是否自动播放 */
  private autoPlay: boolean = true;
  /** 播放至尾后是否循环 */
  private loop: boolean = false;
  /** 缓存音量，prepared 时写入播放器 */
  private volume01: number = 1;
  /** 缓存倍速 */
  private speed: media.PlaybackSpeed = media.PlaybackSpeed.SPEED_FORWARD_1_00_X;
  /** 用户主动暂停/停止后置 true，阻止 autoPlay 再次自动起播 */
  private userPaused: boolean = false;
  /** 与 state playing 同步，供 Controller.isPlaying() 查询 */
  private playingFlag: boolean = false;
  /** 画面如何适配 Surface 区域 */
  private videoScaleType: media.VideoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;

  /** UI 状态通知 */
  onState: (s: UniversalVideoPlayerUiState) => void = () => {
  };
  /** 当前时间与总时长（毫秒） */
  onTime: (cur: number, duration: number) => void = () => {
  };
  /** 错误码与信息 */
  onError: (code: number, msg: string) => void = () => {
  };
  /** 单次播放自然结束（非循环） */
  onEnded: () => void = () => {
  };

  constructor(surfaceId: string) {
    this.surfaceId = surfaceId;
  }

  /** 在 start 前由组件注入初始配置（与 @Prop 对齐） */
  configure(options: UniversalVideoPlayerEngineOptions): void {
    this.src = options.src;
    this.autoPlay = options.autoPlay;
    this.loop = options.loop;
    this.volume01 = options.volume01;
    this.speed = options.speed;
    this.videoScaleType = options.videoScaleType;
  }

  isPlaying(): boolean {
    return this.playingFlag;
  }

  /**
   * 首次打开：规范化地址后创建播放器并赋值 url（触发状态机）。
   * 仅应由组件 XComponent.onLoad 在拿到 surface 后调用一次（或换源逻辑复用 createAndOpen）。
   */
  async start(src: string): Promise<void> {
    this.src = src;
    await this.createAndOpen(normalizeMediaUrl(src));
  }

  /**
   * 换源：更新内存中的 src 并完整重建 AVPlayer（先 releaseInternal 再 create）。
   * 用于 @Watch('src') 与外部 controller.setSource。
   */
  async setSource(url: string): Promise<void> {
    this.src = url;
    await this.createAndOpen(normalizeMediaUrl(url));
  }

  play(): void {
    this.userPaused = false;
    if (!this.avPlayer) {
      return;
    }
    const st = this.avPlayer.state;
    if (st === 'idle' && this.src.length > 0) {
      this.avPlayer.url = normalizeMediaUrl(this.src);
      return;
    }
    if (st === 'prepared' || st === 'paused' || st === 'completed') {
      this.avPlayer.play();
    }
  }

  pause(): void {
    this.userPaused = true;
    if (this.avPlayer && this.avPlayer.state === 'playing') {
      this.avPlayer.pause();
    }
  }

  /**
   * 停止到起点并暂停（保持实例，可再次 play）
   * 实现：seek(0) + pause()，并通知 UI paused；不走 AVPlayer.stop，避免进入 stopped/reset 的复杂重入。
   */
  async stop(): Promise<void> {
    this.userPaused = true;
    if (!this.avPlayer) {
      return;
    }
    const st = this.avPlayer.state;
    if (st === 'playing' || st === 'paused' || st === 'completed' || st === 'prepared') {
      try {
        this.avPlayer.seek(0, media.SeekMode.SEEK_PREV_SYNC);
      } catch (_e) {
      }
      try {
        await this.avPlayer.pause();
      } catch (_e) {
      }
    }
    this.playingFlag = false;
    this.onState('paused');
  }

  /** 跳转进度；仅在可 seek 的状态下调用，使用 SEEK_PREV_SYNC 略向前对齐关键帧 */
  seek(timeMs: number): void {
    if (!this.avPlayer) {
      return;
    }
    if (this.avPlayer.state === 'prepared' || this.avPlayer.state === 'paused' ||
      this.avPlayer.state === 'playing' || this.avPlayer.state === 'completed') {
      this.avPlayer.seek(timeMs, media.SeekMode.SEEK_PREV_SYNC);
    }
  }

  setVolume(volume01: number): void {
    this.volume01 = clamp01(volume01);
    try {
      this.avPlayer?.setVolume(this.volume01);
    } catch (_e) {
    }
  }

  setSpeed(speed: media.PlaybackSpeed): void {
    this.speed = speed;
    try {
      this.avPlayer?.setSpeed(speed);
    } catch (_e) {
    }
  }

  /** 对外释放：先销毁原生实例，再通知 UI 回到 idle */
  async release(): Promise<void> {
    await this.releaseInternal();
    this.onState('idle');
  }

  /** 仅释放实例不触发 onState，供 createAndOpen 换源前清理旧播放器 */
  private async releaseInternal(): Promise<void> {
    this.playingFlag = false;
    const p = this.avPlayer;
    this.avPlayer = null;
    if (p) {
      try {
        await p.release();
      } catch (_e) {
      }
    }
  }

  /** 串行：释放旧播放器 → 创建新实例 → 注册监听 → 设置 url 进入 initialized */
  private async createAndOpen(url: string): Promise<void> {
    await this.releaseInternal();
    this.avPlayer = await media.createAVPlayer();
    this.bindCallbacks(this.avPlayer);
    this.avPlayer.url = url;
  }

  /** 注册 AVPlayer 全部监听；注意同一实例不要重复 bind（本类每次新建实例只调一次） */
  private bindCallbacks(p: media.AVPlayer): void {
    p.on('durationUpdate', (d: number) => {
      if (this.avPlayer !== p) {
        return;
      }
      this.onTime(p.currentTime, d);
    });
    p.on('timeUpdate', (t: number) => {
      if (this.avPlayer !== p) {
        return;
      }
      this.onTime(t, p.duration > 0 ? p.duration : t);
    });
    p.on('seekDone', (_t: number) => {
      if (this.avPlayer !== p) {
        return;
      }
      this.onTime(p.currentTime, p.duration);
    });
    p.on('error', (err: BusinessError) => {
      this.onError(err.code, err.message);
      this.onState('error');
      try {
        p.reset();
      } catch (_e) {
      }
    });
    p.on('stateChange', async (state: string, _reason: media.StateChangeReason) => {
      if (this.avPlayer !== p) {
        return;
      }
      switch (state) {
        case 'idle':
          // reset/release 后的空闲态；本实现不在此自动接链，换源统一走 createAndOpen
          break;
        case 'initialized':
          // 已设置 url：挂 Surface 并准备解码资源
          this.onState('buffering');
          p.surfaceId = this.surfaceId;
          p.prepare();
          break;
        case 'prepared':
          try {
            p.videoScaleType = this.videoScaleType;
            p.setVolume(this.volume01);
            p.setSpeed(this.speed);
          } catch (_e) {
          }
          this.onTime(0, p.duration);
          this.onState('prepared');
          if (this.autoPlay && !this.userPaused) {
            p.play();
          }
          break;
        case 'playing':
          this.playingFlag = true;
          this.onState('playing');
          break;
        case 'paused':
          this.playingFlag = false;
          this.onState('paused');
          break;
        case 'completed':
          // 自然播放到末尾：循环则回零再播；否则回零 pause 并上报 ended 供 UI 显示重播态
          this.playingFlag = false;
          this.onEnded();
          if (this.loop) {
            try {
              p.seek(0, media.SeekMode.SEEK_PREV_SYNC);
              p.play();
            } catch (_e) {
              this.onState('ended');
            }
          } else {
            try {
              p.seek(0, media.SeekMode.SEEK_PREV_SYNC);
              p.pause();
            } catch (_e) {
            }
            this.onState('ended');
          }
          break;
        case 'stopped':
          // 若外部或其它逻辑调用了 stop，则 reset 回到 idle（本组件常规路径少用）
          try {
            await p.reset();
          } catch (_e) {
          }
          break;
        default:
          break;
      }
    });
  }
}

/**
 * 组件对外可见的聚合 UI 状态（与原生 AVPlayer.state 名称不完全等同，便于界面分支）
 * - idle：未创建或已释放
 * - buffering：已设源，解码准备中（initialized → prepare 阶段）
 * - prepared：可播；若 autoPlay 将很快进入 playing
 * - playing / paused：字面含义
 * - ended：单次播放自然结束且非循环
 * - error：on('error') 触发
 */
export type UniversalVideoPlayerUiState = 'idle' | 'buffering' | 'prepared' | 'playing' | 'paused' | 'ended' | 'error';

/** 引擎启动参数快照（与 UniversalVideoPlayer 的 @Prop 对齐） */
interface UniversalVideoPlayerEngineOptions {
  src: string;
  autoPlay: boolean;
  loop: boolean;
  volume01: number;
  speed: media.PlaybackSpeed;
  videoScaleType: media.VideoScaleType;
}

/** 将音量限制在 0~1，避免 setVolume 入参越界 */
function clamp01(v: number): number {
  if (v < 0) {
    return 0;
  }
  if (v > 1) {
    return 1;
  }
  return v;
}

/**
 * 将「无协议」路径视为本地绝对路径并补全为 file://；
 * 已是 http(s)/file/fd/datashare 的字符串保持不变。
 * 用于沙箱文件或拷贝到应用目录后的 mp4 等。
 */
export function normalizeMediaUrl(src: string): string {
  const t = src.trim();
  if (t.length === 0) {
    return t;
  }
  if (t.startsWith('http://') || t.startsWith('https://') || t.startsWith('file://') || t.startsWith('fd://') ||
  t.startsWith('datashare://')) {
    return t;
  }
  return `file://${t}`;
}

/**
 * 通用视频播放 UI：底层 XComponent(Surface) + 叠层控制栏（播放/停/进度/全屏/倍速/音量）。
 *
 * 布局说明：
 *  - 非全屏：高度由 layoutHeightVp 决定，宽度一般父级给 100%。
 *  - 全屏：高度变为 100%，需父容器在竖屏列表里给足宽度；全屏同时会改系统窗口横屏。
 *
 * 交互说明：
 *  - 点击画面：切换控制栏显隐；播放中约 4s 无操作自动隐藏控制栏。
 *  - 进度条：拖动过程仅刷新本地 currentMs；松手（SliderChangeMode.End）才 seek，减少解码压力。
 */
@Component
export struct CommonVideoPlayer {
  /** 媒体地址；变更时触发 handleSrcChange → 引擎 setSource 完整换源 */
  @Prop @Watch('handleSrcChange') src: string = '';
  /** prepared 后是否自动开始播放 */
  @Prop autoPlay: boolean = true;
  /** 是否单曲循环 */
  @Prop loop: boolean = false;
  /** 是否显示内置控制层（false 时仅保留视频画面，适合自定义蒙层） */
  @Prop showControls: boolean = true;
  /**
   * XComponent 的 id 后缀：`uvp_${surfaceKey}`。
   * 同一页面树出现多个本组件时 **必须** 使用不同 surfaceKey，否则 id 冲突导致渲染异常。
   */
  @Prop surfaceKey: string = 'uvp';
  /** 视频在 Surface 中的缩放策略，传给 AVPlayer.videoScaleType */
  @Prop videoScaleType: media.VideoScaleType = media.VideoScaleType.VIDEO_SCALE_TYPE_FIT;
  /** 非全屏模式下组件高度，单位 vp；全屏时忽略该值改用 100% */
  @Prop layoutHeightVp: number = 200;
  /**
   * 可选外部控制器：传入后组件在引擎创建完成时 attach，销毁时 detach。
   * 典型用法见文件头「示例 2」。
   */
  @Prop controller: UniversalVideoPlayerController | null = null;
  /** 引擎聚合状态回调，可用于日志或联动其它 UI */
  onStateChange?: (s: UniversalVideoPlayerUiState) => void = undefined;
  /** 自然播放结束且非 loop 时回调一次（completed 分支 seek 到起点并 pause 后） */
  onPlayEnd?: () => void = undefined;

  /** 与 UniversalVideoPlayerUiState 同步，用于控制栏图标与错误提示 */
  @State private uiState: UniversalVideoPlayerUiState = 'idle';
  /** 当前播放时间 ms，来自 timeUpdate / seekDone */
  @State private currentMs: number = 0;
  /** 总时长 ms，来自 duration 或 durationUpdate */
  @State private durationMs: number = 0;
  /** 控制栏是否可见（点击画面切换；播放中定时自动隐藏） */
  @State private controlsVisible: boolean = true;
  /** 是否处于窗口全屏 + 横屏模式（与 layoutHeightVp 二选一高度策略） */
  @State private isWindowFullscreen: boolean = false;
  /** 音量 Slider 0~100，与引擎 setVolume 换算 */
  @State private volumeUi: number = 100;
  /** 当前选中的倍速展示文案 */
  @State private speedLabel: string = '1.0x';

  /** 由系统填充 Surface，需 onLoad 后取 surfaceId 交给 AVPlayer */
  private xComponentController: XComponentController = new XComponentController();
  /** 与 XComponent 同生命周期的播放引擎 */
  private engine: UniversalVideoPlayerEngine | null = null;
  /** 自动隐藏控制栏的定时器 id；-1 表示未启动 */
  private hideControlsTimer: number = -1;
  /** 缓存主窗口，减少重复 getMainWindowSync */
  private mainWindow: window.Window | null = null;
  /** 进入全屏前记录的方向，用于退出时恢复 */
  private savedOrientation: window.Orientation | null = null;

  /**
   * 组件销毁：清定时器、退出全屏恢复方向、解绑 controller、release 引擎。
   * 页面侧一般无需再手动 controller.release()。
   */
  aboutToDisappear(): void {
    this.clearHideTimer();
    void this.exitFullscreenUi();
    this.controller?.detach();
    void this.engine?.release();
    this.engine = null;
  }

  /** 取消自动隐藏控制栏的计时，避免离屏后仍改 UI 状态 */
  private clearHideTimer(): void {
    if (this.hideControlsTimer >= 0) {
      clearTimeout(this.hideControlsTimer);
      this.hideControlsTimer = -1;
    }
  }

  /** 播放开始后 4s 无操作则隐藏控制栏，节省画面空间 */
  private scheduleHideControls(): void {
    this.clearHideTimer();
    this.hideControlsTimer = setTimeout(() => {
      this.controlsVisible = false;
    }, 4000);
  }

  /**
   * @Watch：src 变化且引擎已存在时异步换源。
   * 注意：首次 src 在 onLoad 里通过 start() 打开，此处仅处理后续变更。
   */
  private handleSrcChange(): void {
    if (this.engine && this.src.length > 0) {
      void this.engine.setSource(this.src);
    }
  }

  /** mm:ss 或 hh:mm:ss，入参为毫秒 */
  private formatTime(ms: number): string {
    if (ms < 0) {
      ms = 0;
    }
    const totalSec = Math.floor(ms / 1000);
    const h = Math.floor(totalSec / 3600);
    const m = Math.floor((totalSec % 3600) / 60);
    const s = totalSec % 60;
    const mm = m < 10 ? `0${m}` : `${m}`;
    const ss = s < 10 ? `0${s}` : `${s}`;
    return h > 0 ? `${h < 10 ? `0${h}` : `${h}`}:${mm}:${ss}` : `${mm}:${ss}`;
  }

  /** 获取 UIAbility 主窗口；非页面环境 catch 后返回 null，全屏按钮将无效果 */
  private ensureWindow(): window.Window | null {
    if (this.mainWindow) {
      return this.mainWindow;
    }
    try {
      const ctx = getContext(this) as common.UIAbilityContext;
      this.mainWindow = ctx.windowStage.getMainWindowSync();
      return this.mainWindow;
    } catch (_e) {
      return null;
    }
  }

  /** 记录原方向 → 布局全屏 → 强制横屏，供沉浸式观影 */
  private async enterFullscreenUi(): Promise<void> {
    const win = this.ensureWindow();
    if (!win) {
      return;
    }
    try {
      this.savedOrientation = await win.getPreferredOrientation();
    } catch (_e) {
      this.savedOrientation = null;
    }
    try {
      await win.setWindowLayoutFullScreen(true);
    } catch (_e) {
    }
    try {
      await win.setPreferredOrientation(window.Orientation.LANDSCAPE);
    } catch (_e) {
    }
    this.isWindowFullscreen = true;
  }

  /** 退出布局全屏并恢复进入前记录的方向（无记录则竖屏） */
  private async exitFullscreenUi(): Promise<void> {
    const win = this.mainWindow ?? this.ensureWindow();
    if (!win) {
      this.isWindowFullscreen = false;
      return;
    }
    try {
      await win.setWindowLayoutFullScreen(false);
    } catch (_e) {
    }
    if (this.savedOrientation !== null) {
      try {
        await win.setPreferredOrientation(this.savedOrientation);
      } catch (_e) {
      }
    } else {
      try {
        await win.setPreferredOrientation(window.Orientation.PORTRAIT);
      } catch (_e) {
      }
    }
    this.savedOrientation = null;
    this.isWindowFullscreen = false;
  }

  /** 全屏与窗口状态联动切换 */
  private toggleFullscreen(): void {
    if (this.isWindowFullscreen) {
      void this.exitFullscreenUi();
    } else {
      void this.enterFullscreenUi();
    }
  }

  private applySpeedByLabel(label: string): void {
    let sp = media.PlaybackSpeed.SPEED_FORWARD_1_00_X;
    if (label === '0.75x') {
      sp = media.PlaybackSpeed.SPEED_FORWARD_0_75_X;
    } else if (label === '1.0x') {
      sp = media.PlaybackSpeed.SPEED_FORWARD_1_00_X;
    } else if (label === '1.25x') {
      sp = media.PlaybackSpeed.SPEED_FORWARD_1_25_X;
    } else if (label === '1.5x') {
      sp = media.PlaybackSpeed.SPEED_FORWARD_1_50_X;
    } else if (label === '2.0x') {
      sp = media.PlaybackSpeed.SPEED_FORWARD_2_00_X;
    }
    this.speedLabel = label;
    this.engine?.setSpeed(sp);
  }

  build() {
    // 自下而上：视频 Surface → 加载圈 → 控制层；点击最外层 Stack 切换控制栏显隐
    Stack({ alignContent: Alignment.Bottom }) {
      XComponent({
        id: `uvp_${this.surfaceKey}`,
        type: XComponentType.SURFACE,
        controller: this.xComponentController
      })
        .onLoad(async () => {
          // 1) 创建引擎并注入与 @Prop 一致的配置
          const sid = this.xComponentController.getXComponentSurfaceId();
          const eng = new UniversalVideoPlayerEngine(sid);
          eng.configure({
            src: this.src,
            autoPlay: this.autoPlay,
            loop: this.loop,
            volume01: this.volumeUi / 100,
            speed: media.PlaybackSpeed.SPEED_FORWARD_1_00_X,
            videoScaleType: this.videoScaleType
          });
          eng.onState = (s: UniversalVideoPlayerUiState) => {
            this.uiState = s;
            this.onStateChange?.(s);
            if (s === 'buffering') {
              this.controlsVisible = true;
            }
            if (s === 'playing') {
              this.scheduleHideControls();
            }
          };
          eng.onTime = (c: number, d: number) => {
            this.currentMs = c;
            if (d > 0) {
              this.durationMs = d;
            }
          };
          eng.onError = (_c: number, _m: string) => {
            this.controlsVisible = true;
          };
          eng.onEnded = () => {
            this.onPlayEnd?.();
          };
          this.engine = eng;
          // 2) 外部控制器与引擎绑定，此后页面可调用 videoCtrl.play() 等
          this.controller?.attach(eng);
          // 3) 首次打开：有地址则走完整 start（内部 createAVPlayer + set url）
          if (this.src.length > 0) {
            await eng.start(this.src);
          }
        })
        .width('100%')
        .height('100%')
        .backgroundColor(Color.Black)

      // 首帧前或尚未 prepared 时给出加载反馈（idle 仅首帧极短可能出现）
      if (this.uiState === 'buffering' || this.uiState === 'idle') {
        LoadingProgress()
          .width(48)
          .height(48)
          .color(Color.White)
      }

      if (this.showControls) {
        // 控制层：顶栏错误提示 + 中部留白 + 底栏主控 + 次栏倍速音量；列整体透明命中让点击穿透到视频（除按钮区域）
        Column() {
          Row() {
            Blank().layoutWeight(1)
            Text(this.uiState === 'error' ? '加载失败' : '')
              .fontColor(Color.White)
              .fontSize(12)
              .visibility(this.uiState === 'error' ? Visibility.Visible : Visibility.Hidden)
          }
          .width('100%')
          .padding(8)
          .visibility(this.controlsVisible ? Visibility.Visible : Visibility.Hidden)
          .backgroundColor('#66000000')

          Blank().layoutWeight(1)

          Row() {
            Image(this.uiState === 'playing' ? $r('app.media.play') : $r('app.media.pause'))
              .width(28)
              .height(28)
              .onClick(() => {
                if (this.uiState === 'playing') {
                  this.engine?.pause();
                } else {
                  this.engine?.play();
                }
                this.controlsVisible = true;
                this.scheduleHideControls();
              })
            Text('■')
              .fontColor(Color.White)
              .fontSize(14)
              .margin({ left: 16 })
              .onClick(() => {
                void this.engine?.stop();
                this.controlsVisible = true;
              })

            Text(this.formatTime(this.currentMs))
              .fontColor(Color.White)
              .fontSize(12)
              .margin({ left: 12 })

            Slider({
              value: this.currentMs,
              min: 0,
              max: this.durationMs > 0 ? this.durationMs : 1,
              style: SliderStyle.OutSet
            })
              .layoutWeight(1)
              .selectedColor('#2CD3D7')
              .trackColor('#888888')
              .blockColor(Color.White)
              .margin({ left: 8, right: 8 })
              .onChange((v: number, mode: SliderChangeMode) => {
                if (mode === SliderChangeMode.Moving) {
                  this.currentMs = v;
                }
                if (mode === SliderChangeMode.End) {
                  this.engine?.seek(v);
                }
              })

            Text(this.formatTime(this.durationMs))
              .fontColor(Color.White)
              .fontSize(12)

            Image($r('app.media.full_screen'))
              .width(22)
              .height(22)
              .margin({ left: 8 })
              .onClick(() => {
                this.toggleFullscreen();
              })
          }
          .width('100%')
          .padding(10)
          .alignItems(VerticalAlign.Center)
          .visibility(this.controlsVisible ? Visibility.Visible : Visibility.Hidden)
          .backgroundColor('#99000000')

          Row() {
            Text('倍速').fontColor(Color.White).fontSize(12)
            this.speedChip('0.75x');
            this.speedChip('1.0x');
            this.speedChip('1.25x');
            this.speedChip('1.5x');
            this.speedChip('2.0x');
            Text('音量').fontColor(Color.White).fontSize(12).margin({ left: 12 })
            Slider({
              value: this.volumeUi,
              min: 0,
              max: 100,
              style: SliderStyle.InSet
            })
              .width(120)
              .selectedColor('#2CD3D7')
              .trackColor('#555555')
              .onChange((v: number) => {
                this.volumeUi = v;
                this.engine?.setVolume(v / 100);
              })
          }
          .width('100%')
          .padding({ left: 10, right: 10, bottom: 6 })
          .visibility(this.controlsVisible ? Visibility.Visible : Visibility.Hidden)
          .backgroundColor('#66000000')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        // 允许点击穿透到下层视频区域，用于「点画面显隐控制条」
        .hitTestBehavior(HitTestMode.Transparent)
      }
    }
    .width('100%')
    .height(this.isWindowFullscreen ? '100%' : this.layoutHeightVp)
    .backgroundColor(Color.Black)
    // 点击视频区域：切换控制栏；展开时重启自动隐藏计时
    .onClick(() => {
      this.controlsVisible = !this.controlsVisible;
      if (this.controlsVisible) {
        this.scheduleHideControls();
      } else {
        this.clearHideTimer();
      }
    })
  }

  /** 倍速快捷 chip：选中态高亮，点击后 setSpeed */
  @Builder
  speedChip(label: string) {
    Text(label)
      .fontSize(11)
      .fontColor(this.speedLabel === label ? Color.Black : Color.White)
      .backgroundColor(this.speedLabel === label ? '#2CD3D7' : '#444444')
      .padding({
        left: 6,
        right: 6,
        top: 4,
        bottom: 4
      })
      .borderRadius(4)
      .margin({ left: 6 })
      .onClick(() => {
        this.applySpeedByLabel(label);
      })
  }
}
