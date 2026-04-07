

import {
  AssetManager,
  AtlasAttachmentLoader,
  AnimationState,
  AnimationStateData,
  SkeletonRenderer,
  SkeletonJson,
  SkeletonBinary,
  Skeleton,
  TextureAtlas,
  Physics,
  Delay,
  Bound,
  SkeletonData,
  Animation
} from '@ohos/spine'

import { AnimatorResult, AnimatorOptions } from '@kit.ArkUI';
import { Logger } from './LoggerUtil';

export enum ResourceSourceType {
  LOCAL = 'local',
  NETWORK = 'network',
  SANDBOX = 'sandbox'
}

export interface SpineResourceConfig {
  basePath: string;
  skeletonFile: string;
  atlasFile: string;
  isBinary?: boolean;
  extraTextures?: Array<string>;
  sourceType?: ResourceSourceType;
  timeout?: number;
}

export interface SpineAnimatorConfig {
  duration?: number;
  expectedFrameRate?: ExpectedFrameRateRange;
  autoPlay?: boolean;
}

export interface SpineRenderConfig {
  triangleRendering?: boolean;
  horizontalCenter?: boolean;
  verticalOffset?: number;
  scaleRatio?: number;
  flipY?: boolean;
}

export interface SpineLoadCallback {
  onSuccess?: (skeleton: Skeleton, animationState: AnimationState) => void;
  onError?: (error: Error) => void;
  onProgress?: (progress: number) => void;
  onNetworkStart?: () => void;
  onNetworkComplete?: () => void;
}

export interface SpineRenderCallback {
  onBeforeRender?: (skeleton: Skeleton, deltaTime: number) => void;
  onAfterRender?: (skeleton: Skeleton) => void;
}

export class SpineAnimationManager {
  private assetManager: AssetManager | null = null;
  private skeletonRenderer: SkeletonRenderer | null = null;
  private skeleton: Skeleton | null = null;
  private animationState: AnimationState | null = null;
  private animator: AnimatorResult | null = null;
  private bounds: Bound | null = null;

  private lastFrameTime: number = 0;
  private isLoaded: boolean = false;
  private isLoading: boolean = false;
  private renderCallback: SpineRenderCallback | null = null;
  private currentContext: CanvasRenderingContext2D | null = null;
  private currentConfig: SpineResourceConfig | null = null;

  async loadAnimation(
    config: SpineResourceConfig,
    canvasContext: CanvasRenderingContext2D,
    animatorConfig?: SpineAnimatorConfig,
    renderConfig?: SpineRenderConfig,
    callback?: SpineLoadCallback
  ): Promise<void> {
    if (this.isLoading) {
      Logger.warn('SpineAnimation', '动画正在加载中，请等待');
      return;
    }

    this.isLoading = true;
    this.currentConfig = config;

    try {
      const sourceType: ResourceSourceType = this.detectSourceType(config.basePath);
      Logger.info('SpineAnimation', `检测到资源类型: ${sourceType}, 路径: ${config.basePath}`);

      if (sourceType === ResourceSourceType.NETWORK) {
        await this.loadFromNetwork(config, canvasContext, animatorConfig, renderConfig, callback);
      } else {
        await this.loadFromLocal(config, canvasContext, animatorConfig, renderConfig, callback);
      }
    } catch (error) {
      Logger.error('SpineAnimation', `加载失败: ${JSON.stringify(error)}`);
      this.isLoaded = false;
      this.isLoading = false;

      if (callback?.onError) {
        callback.onError(error as Error);
      }

    }
  }

  private async loadFromLocal(
    config: SpineResourceConfig,
    canvasContext: CanvasRenderingContext2D,
    animatorConfig?: SpineAnimatorConfig,
    renderConfig?: SpineRenderConfig,
    callback?: SpineLoadCallback
  ): Promise<void> {
    try {
      Logger.info('SpineAnimation', `开始加载本地资源: ${config.skeletonFile}`);

      this.currentContext = canvasContext;
      this.skeletonRenderer = new SkeletonRenderer(canvasContext);
      this.skeletonRenderer.triangleRendering = renderConfig?.triangleRendering ?? true;

      this.assetManager = new AssetManager(config.basePath);

      if (config.isBinary) {
        this.assetManager.loadBinary(config.skeletonFile);
      } else {
        this.assetManager.loadText(config.skeletonFile);
      }

      this.assetManager.loadTextureAtlas(config.atlasFile);

      if (config.extraTextures && config.extraTextures.length > 0) {
        config.extraTextures.forEach((texture: string) => {
          this.assetManager?.loadTexture(texture);
        });
      }

      await this.assetManager.loadAll();
      Logger.info('SpineAnimation', '本地资源加载完成');

      await this.initializeSkeleton(config, callback);
    } catch (error) {

    }
  }

  private async loadFromNetwork(
    config: SpineResourceConfig,
    canvasContext: CanvasRenderingContext2D,
    animatorConfig?: SpineAnimatorConfig,
    renderConfig?: SpineRenderConfig,
    callback?: SpineLoadCallback
  ): Promise<void> {
    try {
      Logger.info('SpineAnimation', `开始加载网络资源: ${config.basePath}${config.skeletonFile}`);

      if (callback?.onNetworkStart) {
        callback.onNetworkStart();
      }

      this.currentContext = canvasContext;
      this.skeletonRenderer = new SkeletonRenderer(canvasContext);
      this.skeletonRenderer.triangleRendering = renderConfig?.triangleRendering ?? true;

      const networkPath: string = this.ensureTrailingSlash(config.basePath);
      this.assetManager = new AssetManager(networkPath);

      if (config.isBinary) {
        this.assetManager.loadBinary(config.skeletonFile);
      } else {
        this.assetManager.loadText(config.skeletonFile);
      }

      this.assetManager.loadTextureAtlas(config.atlasFile);

      if (config.extraTextures && config.extraTextures.length > 0) {
        config.extraTextures.forEach((texture: string) => {
          this.assetManager?.loadTexture(texture);
        });
      }

      Logger.info('SpineAnimation', '开始网络下载...');
      await this.assetManager.loadAll();
      Logger.info('SpineAnimation', '网络资源下载完成');

      if (callback?.onNetworkComplete) {
        callback.onNetworkComplete();
      }

      await this.initializeSkeleton(config, callback);
    } catch (error) {
      Logger.error('SpineAnimation', `网络加载失败: ${JSON.stringify(error)}`);

    }
  }

  private async initializeSkeleton(
    config: SpineResourceConfig,
    callback?: SpineLoadCallback
  ): Promise<void> {
    if (!this.assetManager) {
      throw new Error('AssetManager 未初始化');
    }

    const atlas: TextureAtlas = this.assetManager.require(config.atlasFile);
    const atlasLoader: AtlasAttachmentLoader = new AtlasAttachmentLoader(atlas);

    let skeletonData: SkeletonData;
    if (config.isBinary) {
      const skeletonBinary: SkeletonBinary = new SkeletonBinary(atlasLoader);
      skeletonData = skeletonBinary.readSkeletonData(this.assetManager.require(config.skeletonFile));
      Logger.info('SpineAnimation', '使用二进制解析器');
    } else {
      const skeletonJson: SkeletonJson = new SkeletonJson(atlasLoader);
      skeletonData = skeletonJson.readSkeletonData(this.assetManager.require(config.skeletonFile));
      Logger.info('SpineAnimation', '使用 JSON 解析器');
    }

    this.skeleton = new Skeleton(skeletonData);
    this.skeleton.setToSetupPose();
    this.skeleton.updateWorldTransform(Physics.update);
    this.bounds = this.skeleton.getBoundsRect();

    const animationStateData: AnimationStateData = new AnimationStateData(this.skeleton.data);
    animationStateData.defaultMix = 0.2;
    this.animationState = new AnimationState(animationStateData);

    this.isLoaded = true;
    this.isLoading = false;

    const animations: Array<string> = this.getAvailableAnimations();
    Logger.info('SpineAnimation', `加载成功，可用动画: [${animations.join(', ')}]`);

    if (callback?.onSuccess && this.skeleton && this.animationState) {
      callback.onSuccess(this.skeleton, this.animationState);
    }
  }

  startAnimation(
    createAnimatorFn: (options: AnimatorOptions) => AnimatorResult,
    config?: SpineAnimatorConfig
  ): void {
    if (!this.validateState()) {
      return;
    }

    this.lastFrameTime = Date.now() / 1000;

    if (this.animator) {
      this.animator.finish();
    }

    const animatorOptions: AnimatorOptions = {
      duration: config?.duration ?? 20000,
      easing: 'linear',
      delay: 0,
      fill: 'forwards',
      direction: 'normal',
      iterations: -1,
      begin: 0,
      end: 1
    };

    const expectedFrameRate: ExpectedFrameRateRange = config?.expectedFrameRate ?? {
      min: 0,
      max: 120,
      expected: 60
    };

    this.animator = createAnimatorFn(animatorOptions);
    this.animator.setExpectedFrameRateRange(expectedFrameRate);

    const result: Delay = { time: this.lastFrameTime, isFinish: true };

    this.animator.onFrame = (value: number) => {
      if (result.isFinish) {
        result.isFinish = false;
        this.renderFrame(result);
      }
    };

    if (config?.autoPlay !== false) {
      this.animator.play();
    }

    Logger.info('SpineAnimation', '动画器启动');
  }

  private renderFrame(result: Delay): Delay {
    if (!this.skeleton || !this.animationState || !this.skeletonRenderer || !this.bounds || !this.currentContext) {
      return result;
    }

    const now: number = Date.now() / 1000;
    const delta: number = now - result.time;
    result.time = now;

    if (this.renderCallback?.onBeforeRender) {
      this.renderCallback.onBeforeRender(this.skeleton, delta);
    }

    this.currentContext.clearRect(0, 0, this.currentContext.width, this.currentContext.height);

    this.skeleton.x = this.currentContext.width / 2;
    this.skeleton.y = this.currentContext.height - this.currentContext.height * 0.1;
    const scale: number = this.currentContext.height / this.bounds.height * 0.5;
    this.skeleton.scaleX = scale;
    this.skeleton.scaleY = -scale;

    this.animationState.update(delta);
    this.animationState.apply(this.skeleton);
    this.skeleton.updateWorldTransform(Physics.update);
    this.skeletonRenderer.draw(this.skeleton);

    if (this.renderCallback?.onAfterRender) {
      this.renderCallback.onAfterRender(this.skeleton);
    }

    result.isFinish = true;
    return result;
  }

  setAnimation(trackIndex: number, animationName: string, loop: boolean = true): void {
    if (!this.animationState) {
      Logger.warn('SpineAnimation', '动画状态未初始化');
      return;
    }
    this.animationState.setAnimation(trackIndex, animationName, loop);
  }

  addAnimation(trackIndex: number, animationName: string, loop: boolean = false): void {
    if (!this.animationState) {
      Logger.warn('SpineAnimation', '动画状态未初始化');
      return;
    }
    this.animationState.addAnimation(trackIndex, animationName, loop);
  }

  play(): void {
    this.animator?.play();
  }

  pause(): void {
    this.animator?.pause();
  }

  stop(): void {
    this.animator?.finish();
  }

  clearCanvas(): void {
    if (this.currentContext) {
      this.currentContext.clearRect(0, 0, this.currentContext.width, this.currentContext.height);
    }
  }

  clearAnimations(): void {
    this.animationState?.setEmptyAnimations(0);
    this.clearCanvas();
  }

  setRenderCallback(callback: SpineRenderCallback): void {
    this.renderCallback = callback;
  }

  getAnimationState(): AnimationState | null {
    return this.animationState;
  }

  getSkeleton(): Skeleton | null {
    return this.skeleton;
  }

  getAvailableAnimations(): Array<string> {
    if (!this.skeleton) {
      return [];
    }
    const animations: Array<string> = [];
    this.skeleton.data.animations.forEach((anim: Animation) => {
      animations.push(anim.name);
    });
    return animations;
  }

  isAnimationLoaded(): boolean {
    return this.isLoaded;
  }

  isAnimationLoading(): boolean {
    return this.isLoading;
  }

  getCurrentConfig(): SpineResourceConfig | null {
    return this.currentConfig;
  }

  dispose(): void {
    Logger.info('SpineAnimation', '销毁资源');

    if (this.animator) {
      this.animator.finish();
      this.animator = null;
    }

    this.clearCanvas();
    this.skeleton = null;
    this.animationState = null;
    this.skeletonRenderer = null;
    this.assetManager = null;
    this.bounds = null;
    this.currentContext = null;
    this.currentConfig = null;
    this.isLoaded = false;
    this.isLoading = false;
  }

  private validateState(): boolean {
    if (!this.isLoaded || !this.skeleton || !this.animationState) {
      Logger.error('SpineAnimation', '动画未加载');
      return false;
    }
    return true;
  }

  private detectSourceType(basePath: string): ResourceSourceType {
    if (basePath.startsWith('http://') || basePath.startsWith('https://')) {
      return ResourceSourceType.NETWORK;
    }
    if (basePath.startsWith('cache://') || basePath.startsWith('files://')) {
      return ResourceSourceType.SANDBOX;
    }
    return ResourceSourceType.LOCAL;
  }

  private ensureTrailingSlash(path: string): string {
    return path.endsWith('/') ? path : path + '/';
  }
}
