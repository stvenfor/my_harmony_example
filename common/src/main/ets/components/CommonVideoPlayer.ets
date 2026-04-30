import { media } from '@kit.MediaKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

/**
 * 通用视频播放器控制器（增强版）
 * 支持全屏、进度控制、横竖屏切换等功能
 */
export class CommonVideoPlayer {
  private surfaceID: string = '';
  private avPlayer: media.AVPlayer | null = null;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private mainWindow?: window.Window;

  // 状态回调
  onPlayStatusChange?: (status: PlayerStatus) => void;
  onUpdateTime?: (currentTime: number, totalTime: number) => void;
  onVideoSizeChange?: (width: number, height: number) => void;
  onError?: (error: BusinessError) => void;
  onFullScreenChange?: (isFullScreen: boolean) => void;

  // 播放器状态
  private currentStatus: PlayerStatus = PlayerStatus.Idle;
  private isFullScreen: boolean = false;

  /**
   * 初始化主窗口引用
   */
  async initWindow(): Promise<void> {
    try {
      const windowStage = this.context.windowStage;
      this.mainWindow = await windowStage.getMainWindow();
    } catch (error) {
      console.error('[CommonVideoPlayer] Init window error:', error);
    }
  }

  /**
   * 设置渲染 Surface ID
   */
  setSurfaceID(surfaceId: string): void {
    this.surfaceID = surfaceId;
  }

  /**
   * 初始化播放器
   */
  async init(url: string): Promise<void> {
    try {
      await this.initWindow();
      await this.release();

      this.avPlayer = await media.createAVPlayer();
      this.setupCallbacks();
      this.avPlayer.url = url;
    } catch (error) {
      this.onError?.(error as BusinessError);
    }
  }

  /**
   * 设置回调监听
   */
  private setupCallbacks(): void {
    if (!this.avPlayer) return;

    this.avPlayer.on('timeUpdate', (updateTime: number) => {
      this.onUpdateTime?.(updateTime, this.avPlayer?.duration ?? 0);
    });

    this.avPlayer.on('videoSizeChange', (width: number, height: number) => {
      this.onVideoSizeChange?.(width, height);
    });

    this.avPlayer.on('seekDone', (seekTime: number) => {
      console.info(`[CommonVideoPlayer] Seek completed: ${seekTime}ms`);
    });

    this.avPlayer.on('error', (err: BusinessError) => {
      console.error(`[CommonVideoPlayer] Error: ${err.code}, ${err.message}`);
      this.onError?.(err);
      this.reset();
    });

    this.avPlayer.on('stateChange', async (state: string) => {
      this.handleStateChange(state);
    });
  }

  /**
   * 处理状态机变化
   */
  private async handleStateChange(state: string): Promise<void> {
    switch (state) {
      case 'idle':
        this.currentStatus = PlayerStatus.Idle;
        this.onPlayStatusChange?.(PlayerStatus.Idle);
        break;

      case 'initialized':
        this.currentStatus = PlayerStatus.Initialized;
        this.onPlayStatusChange?.(PlayerStatus.Initialized);
        if (this.avPlayer && this.surfaceID) {
          this.avPlayer.surfaceId = this.surfaceID;
          this.avPlayer.prepare();
        }
        break;

      case 'prepared':
        this.currentStatus = PlayerStatus.Prepared;
        this.onPlayStatusChange?.(PlayerStatus.Prepared);
        this.avPlayer?.play();
        break;

      case 'playing':
        this.currentStatus = PlayerStatus.Playing;
        this.onPlayStatusChange?.(PlayerStatus.Playing);
        break;

      case 'paused':
        this.currentStatus = PlayerStatus.Paused;
        this.onPlayStatusChange?.(PlayerStatus.Paused);
        break;

      case 'completed':
        this.currentStatus = PlayerStatus.Completed;
        this.onPlayStatusChange?.(PlayerStatus.Completed);
        break;

      case 'stopped':
        this.currentStatus = PlayerStatus.Stopped;
        this.onPlayStatusChange?.(PlayerStatus.Stopped);
        this.reset();
        break;

      case 'released':
        this.currentStatus = PlayerStatus.Released;
        this.onPlayStatusChange?.(PlayerStatus.Released);
        break;
    }
  }

  /**
   * 播放
   */
  async play(): Promise<void> {
    if (this.currentStatus === PlayerStatus.Paused || this.currentStatus === PlayerStatus.Prepared) {
      this.avPlayer?.play();
    }
  }

  /**
   * 暂停
   */
  pause(): void {
    if (this.currentStatus === PlayerStatus.Playing) {
      this.avPlayer?.pause();
    }
  }

  /**
   * 停止
   */
  stop(): void {
    this.avPlayer?.stop();
  }

  /**
   * Seek 到指定位置
   */
  seekTo(timeMs: number): void {
    if (this.avPlayer) {
      this.avPlayer.seek(timeMs, media.SeekMode.SEEK_NEXT_SYNC);
    }
  }

  /**
   * 设置音量 (0.0 - 1.0)
   */
  setVolume(volume: number): void {
    if (this.avPlayer && volume >= 0 && volume <= 1) {
      this.avPlayer.setVolume(volume);
    }
  }

  /**
   * 设置播放倍速
   */
  setSpeed(speed: number): void {
    if (this.avPlayer && speed > 0) {
      this.avPlayer.setSpeed(speed);
    }
  }

  /**
   * 重置播放器
   */
  reset(): void {
    this.avPlayer?.reset();
  }

  /**
   * 释放资源
   */
  async release(): Promise<void> {
    if (this.avPlayer) {
      try {
        await this.exitFullScreen();
        await this.avPlayer.release();
      } catch (e) {
        console.error('[CommonVideoPlayer] Release error:', e);
      }
      this.avPlayer = null;
    }
    this.currentStatus = PlayerStatus.Released;
  }

  /**
   * 切换全屏状态
   */
  async toggleFullScreen(): Promise<void> {
    if (!this.mainWindow) return;

    try {
      if (this.isFullScreen) {
        await this.exitFullScreen();
      } else {
        await this.enterFullScreen();
      }
    } catch (error) {
      console.error('[CommonVideoPlayer] Toggle fullscreen error:', error);
    }
  }

  /**
   * 进入全屏
   */
  private async enterFullScreen(): Promise<void> {
    if (!this.mainWindow) return;

    await this.mainWindow.setWindowLayoutFullScreen(true);
    await this.mainWindow.setPreferredOrientation(window.Orientation.AUTO_ROTATION);
    this.isFullScreen = true;
    this.onFullScreenChange?.(true);
  }

  /**
   * 退出全屏
   */
  private async exitFullScreen(): Promise<void> {
    if (!this.mainWindow) return;

    await this.mainWindow.setWindowLayoutFullScreen(false);
    await this.mainWindow.setPreferredOrientation(window.Orientation.UNSPECIFIED);
    this.isFullScreen = false;
    this.onFullScreenChange?.(false);
  }

  /**
   * 设置横屏
   */
  async setLandscape(): Promise<void> {
    if (!this.mainWindow) return;

    await this.mainWindow.setPreferredOrientation(window.Orientation.LANDSCAPE);
  }

  /**
   * 设置竖屏
   */
  async setPortrait(): Promise<void> {
    if (!this.mainWindow) return;

    await this.mainWindow.setPreferredOrientation(window.Orientation.PORTRAIT);
  }

  /**
   * 获取当前状态
   */
  getStatus(): PlayerStatus {
    return this.currentStatus;
  }

  /**
   * 获取视频时长 (ms)
   */
  getDuration(): number {
    return this.avPlayer?.duration ?? 0;
  }

  /**
   * 获取当前播放位置 (ms)
   */
  getCurrentTime(): number {
    return this.avPlayer?.currentTime ?? 0;
  }

  /**
   * 是否全屏
   */
  isFullScreenMode(): boolean {
    return this.isFullScreen;
  }

  /**
   * 切换播放/暂停
   */
  togglePlayPause(): void {
    if (this.currentStatus === PlayerStatus.Playing) {
      this.pause();
    } else {
      this.play();
    }
  }
}

/**
 * 播放器状态枚举
 */
export enum PlayerStatus {
  Idle = 0,
  Initialized = 1,
  Prepared = 2,
  Playing = 3,
  Paused = 4,
  Completed = 5,
  Stopped = 6,
  Released = 7
}


