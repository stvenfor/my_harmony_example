import {
  PageHeaderComp,
  ResourceSourceType,
  SpineAnimationManager,
  SpineResourceConfig,
  StringConstants
} from '@ohos/common';
import { AnimatorOptions } from '@kit.ArkUI';

enum LoadMode {
  JSON = 'JSON本地',
  NETWORK = '网络加载',
  SKEL = 'SKEL二进制'
}

@Entry
@Component
export struct SpecialAnimation {
  @State currentMode: LoadMode = LoadMode.JSON;
  @State isLoading: boolean = false;
  @State statusText: string = '';
  @State availableAnimations: Array<string> = [];
  @State currentAnimation: string = '';
  @Consume('pathStack') pathStack: NavPathStack;
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(
    new RenderingContextSettings(true)
  );
  private spineManager: SpineAnimationManager = new SpineAnimationManager();

  aboutToDisappear() {
    this.spineManager.dispose();
  }

  build() {
    NavDestination() {
      Column() {
        PageHeaderComp({
          title: '基础示例',
          backAction: () => {
            this.pathStack.pop();
          }
        })
        Row() {
          Text('Spine动画加载示例')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#f5f5f5')

        Row({ space: 10 }) {
          Button(LoadMode.JSON)
            .type(ButtonType.Normal)
            .backgroundColor(this.currentMode === LoadMode.JSON ? '#007DFF' : '#E5E5E5')
            .fontColor(this.currentMode === LoadMode.JSON ? '#FFFFFF' : '#333333')
            .onClick(() => {
              this.switchMode(LoadMode.JSON);
            })

          Button(LoadMode.NETWORK)
            .type(ButtonType.Normal)
            .backgroundColor(this.currentMode === LoadMode.NETWORK ? '#007DFF' : '#E5E5E5')
            .fontColor(this.currentMode === LoadMode.NETWORK ? '#FFFFFF' : '#333333')
            .onClick(() => {
              this.switchMode(LoadMode.NETWORK);
            })

          Button(LoadMode.SKEL)
            .type(ButtonType.Normal)
            .backgroundColor(this.currentMode === LoadMode.SKEL ? '#007DFF' : '#E5E5E5')
            .fontColor(this.currentMode === LoadMode.SKEL ? '#FFFFFF' : '#333333')
            .onClick(() => {
              this.switchMode(LoadMode.SKEL);
            })
        }
        .width('100%')
        .padding({
          left: 10,
          right: 10,
          top: 5,
          bottom: 5
        })

        if (this.statusText) {
          Text(this.statusText)
            .fontSize(14)
            .fontColor(this.isLoading ? '#FF9500' : '#007DFF')
            .margin({ top: 5 })
        }

        Canvas(this.canvasContext)
          .width('100%')
          .layoutWeight(1)
          .backgroundColor('#ccc')
          .onReady(() => {
            this.loadCurrentMode();
          })

        if (this.availableAnimations.length > 0) {
          Scroll() {
            Row({ space: 8 }) {
              ForEach(this.availableAnimations, (anim: string) => {
                Button(anim)
                  .fontSize(12)
                  .height(36)
                  .backgroundColor(this.currentAnimation === anim ? '#007DFF' : '#F0F0F0')
                  .fontColor(this.currentAnimation === anim ? '#FFFFFF' : '#333333')
                  .onClick(() => {
                    this.playAnimation(anim);
                  })
              })
            }
            .padding(10)
          }
          .width('100%')
          .height(80)
        }

        Row({ space: 10 }) {
          Button('播放')
            .enabled(!this.isLoading && this.spineManager.isAnimationLoaded())
            .onClick(() => {
              this.spineManager.play();
              this.statusText = '播放中';
            })

          Button('暂停')
            .enabled(!this.isLoading && this.spineManager.isAnimationLoaded())
            .onClick(() => {
              this.spineManager.pause();
              this.statusText = '已暂停';
            })

          Button('清空')
            .enabled(!this.isLoading && this.spineManager.isAnimationLoaded())
            .onClick(() => {
              this.spineManager.clearAnimations();
              this.statusText = '已清空';
            })
        }
        .width('100%')
        .padding(10)
      }
      .width('100%')
      .height('100%').padding({ top: this.topArea, bottom: this.bottomArea })
    }.hideTitleBar(true).hideBackButton(true)

  }

  async switchMode(mode: LoadMode) {
    if (this.isLoading || this.currentMode === mode) {
      return;
    }

    this.currentMode = mode;
    this.spineManager.dispose();
    await this.loadCurrentMode();
  }

  async loadCurrentMode() {
    switch (this.currentMode) {
      case LoadMode.JSON:
        await this.loadJsonExample();
        break;
      case LoadMode.NETWORK:
        await this.loadNetworkExample();
        break;
      case LoadMode.SKEL:
        await this.loadSkelExample();
        break;
    }
  }

  async loadJsonExample() {
    this.isLoading = true;
    this.statusText = '正在加载本地 JSON 资源...';
    this.availableAnimations = [];
    this.currentAnimation = '';

    const config: SpineResourceConfig = {
      basePath: 'animation/',
      skeletonFile: 'spineboy-ess.json',
      atlasFile: 'spineboy.atlas',
      isBinary: false,
      sourceType: ResourceSourceType.LOCAL
    };

    try {
      await this.spineManager.loadAnimation(
        config,
        this.canvasContext,
        { duration: 20000, autoPlay: true },
        { triangleRendering: true },
        {
          onSuccess: (skeleton, animationState) => {
            console.info('JSON 加载成功');
            this.availableAnimations = this.spineManager.getAvailableAnimations();
            this.currentAnimation = 'walk';
            this.statusText = `本地 JSON 加载完成 (${this.availableAnimations.length}个动画)`;

            this.spineManager.startAnimation(
              (options: AnimatorOptions) => this.getUIContext().createAnimator(options)
            );

            this.spineManager.setAnimation(0, 'walk', true);
          },
          onError: (error) => {
            console.error('JSON 加载失败:', error);
            this.statusText = '加载失败: ' + error.message;
          }
        }
      );
    } catch (error) {
      console.error('加载异常:', error);
      this.statusText = '加载异常';
    } finally {
      this.isLoading = false;
    }
  }

  async loadNetworkExample() {
    this.isLoading = true;
    this.statusText = '正在从网络下载资源...';
    this.availableAnimations = [];
    this.currentAnimation = '';

    const config: SpineResourceConfig = {
      basePath: 'https://esotericsoftware.com/files/examples/4.0/spineboy/export/',
      skeletonFile: 'spineboy-ess.json',
      atlasFile: 'spineboy.atlas',
      isBinary: false,
      sourceType: ResourceSourceType.NETWORK
    };

    try {
      await this.spineManager.loadAnimation(
        config,
        this.canvasContext,
        { duration: 20000, autoPlay: false },
        { triangleRendering: true },
        {
          onNetworkStart: () => {
            console.info('开始网络请求');
            this.statusText = '连接服务器...';
          },
          onNetworkComplete: () => {
            console.info('下载完成');
            this.statusText = '解析动画数据...';
          },
          onSuccess: (skeleton, animationState) => {
            console.info('网络加载成功');
            this.availableAnimations = this.spineManager.getAvailableAnimations();
            this.currentAnimation = 'idle';
            this.statusText = `网络加载完成 (${this.availableAnimations.length}个动画)`;

            this.spineManager.startAnimation(
              (options: AnimatorOptions) => this.getUIContext().createAnimator(options),
              { autoPlay: true }
            );

            this.spineManager.setAnimation(0, 'idle', true);
          },
          onError: (error) => {
            console.error('网络加载失败:', error);
            this.statusText = '网络加载失败，请检查网络';
          }
        }
      );
    } catch (error) {
      console.error('网络加载异常:', error);
      this.statusText = '网络异常';
    } finally {
      this.isLoading = false;
    }
  }

  async loadSkelExample() {
    this.isLoading = true;
    this.statusText = '正在加载 SKEL 二进制资源...';
    this.availableAnimations = [];
    this.currentAnimation = '';

    const config: SpineResourceConfig = {
      basePath: 'animation/',
      skeletonFile: 'spineboy-pro.skel',
      atlasFile: 'spineboy.atlas',
      isBinary: true,
      sourceType: ResourceSourceType.LOCAL
    };

    // const config: SpineResourceConfig = {
    //   basePath: 'animation7/',
    //   skeletonFile: 'celestial-circus-pro.skel',
    //   atlasFile: 'celestial-circus.atlas',
    //   isBinary: true,
    //   sourceType: ResourceSourceType.LOCAL
    // };

    // const config: SpineResourceConfig = {
    //   basePath: 'animation7/',
    //   skeletonFile: 'mix-and-match-pro.skel',
    //   atlasFile: 'mix-and-match.atlas',
    //   isBinary: true,
    //   sourceType: ResourceSourceType.LOCAL
    // };

    try {
      await this.spineManager.loadAnimation(
        config,
        this.canvasContext,
        { duration: 20000, autoPlay: true },
        { triangleRendering: true },
        {
          onSuccess: (skeleton, animationState) => {
            console.info('SKEL 二进制加载成功');
            this.availableAnimations = this.spineManager.getAvailableAnimations();
            this.currentAnimation = 'walk';
            this.statusText = `SKEL 二进制加载完成 (${this.availableAnimations.length}个动画，性能优化)`;

            this.spineManager.startAnimation(
              (options: AnimatorOptions) => this.getUIContext().createAnimator(options)
            );

            this.spineManager.setAnimation(0, 'walk', true);
          },
          onError: (error) => {
            console.error('SKEL 加载失败:', error);
            this.statusText = 'SKEL 加载失败';
          }
        }
      );
    } catch (error) {
      console.error('SKEL 加载异常:', error);
      this.statusText = 'SKEL 异常: ' + (error as Error).message;
    } finally {
      this.isLoading = false;
    }
  }

  playAnimation(animationName: string) {
    if (!this.spineManager.isAnimationLoaded()) {
      return;
    }

    this.currentAnimation = animationName;
    this.spineManager.setAnimation(0, animationName, true);
    this.statusText = `播放: ${animationName}`;
  }
}

