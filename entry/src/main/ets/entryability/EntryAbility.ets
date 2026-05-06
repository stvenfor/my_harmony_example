import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { display, window } from '@kit.ArkUI';
import { ExclusiveAppComponent, FlutterManager } from '@ohos/flutter_ohos';
import { BreakpointConstants, StringConstants, updateBreakPoint } from '@ohos/common';
import { deviceInfo } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility implements ExclusiveAppComponent<UIAbility>{
  /**
   * 根据当前窗口尺寸与安全区刷新断点（写入 AppStorage breakPoint）及顶/底占位高度。
   * updateBreakPoint 内部已对 breakPoint 做 setOrCreate，子页 @StorageLink('breakPoint') 可实时联动。
   * 顶栏占位仅取状态栏（TYPE_SYSTEM.topRect）与刘海（TYPE_CUTOUT.topRect），不包含底部导航栏；底栏为手势指示区。
   */
  private syncBreakpointAndSafeInsets(windowClass: window.Window, width: number, height: number): void {
    const bottomPx: number =
      windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height
    AppStorage.setOrCreate(StringConstants.BOTTOM_AREA, px2vp(bottomPx))

    const statusBarTopPx: number =
      windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height
    const cutoutTopPx: number =
      windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT).topRect.height
    const topInsetVp: number = Math.max(px2vp(statusBarTopPx), px2vp(cutoutTopPx))

    const bp: string = updateBreakPoint(width, height)
    const topExtraVp: number = bp === BreakpointConstants.BREAKPOINT_XL ? 20 : 0
    AppStorage.setOrCreate(StringConstants.TOP_AREA, topInsetVp + topExtraVp)
  }

  detachFromFlutterEngine(): void {
    // throw new Error('Method not implemented.');
  }

  getAppComponent(): UIAbility {
    return this;
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // AppUtil.init(this.context);

    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    this.init()
  }

  init() {
    FlutterManager.getInstance().pushUIAbility(this)
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
    FlutterManager.getInstance().popUIAbility(this)
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {


    windowStage.getMainWindow().then((windowClass) => {
      try {
        //判断是否是pad,强制竖屏
        if (deviceInfo.deviceType == 'phone') {
          // 手机维持竖屏显示
          let orientation = window.Orientation.AUTO_ROTATION_PORTRAIT_RESTRICTED;
          let promise = windowClass.setPreferredOrientation(orientation);
          promise.then(() => {
            console.info('Succeeded in setting the window orientation.');
          }).catch((err: BusinessError) => {
            console.error(`Failed to set the window orientation. Cause code: ${err.code}, message: ${err.message}`);
          });
        }
      } catch (exception) {
        console.error(`Failed to set window orientation. Cause code: ${exception.code}, message: ${exception.message}`);
      }
      // 获取窗口尺寸，存入AppStorage
      AppStorage.setOrCreate('winWidth', windowClass.getWindowProperties().windowRect.width);
      AppStorage.setOrCreate('winHeight', windowClass.getWindowProperties().windowRect.height);
      // 监听窗口尺寸变化
      windowClass.on('windowSizeChange', (windowSize) => {
        AppStorage.setOrCreate('winWidth', windowSize.width);
        AppStorage.setOrCreate('winHeight', windowSize.height);
        console.log('宽高', String(windowSize.width), String(windowSize.height))
      });

    });

    try {
      let windowClass: window.Window = windowStage.getMainWindowSync()
      AppStorage.setOrCreate('windowClass', windowClass)

      let type = deviceInfo.deviceType
      if (type == '2in1') {
        try {
          let windowLimits: window.WindowLimits = {
            maxWidth: 3000,
            maxHeight: 1800,
            minWidth: 2000,
            minHeight: 1200
          };
          let promise = windowClass.setWindowLimits(windowLimits);
          promise.then((data) => {
            console.info('Succeeded in changing the window limits. Cause:' + JSON.stringify(data));
          }).catch((err: BusinessError) => {
            console.error(`Failed to change the window limits. Cause code: ${err.code}, message: ${err.message}`);
          });
        } catch (exception) {
          console.error(`Failed to change the window limits. Cause code: ${exception.code}, message: ${exception.message}`);
        }
      }


      // 设置窗口全屏
      windowClass.setWindowLayoutFullScreen(true)

      const initRect = windowClass.getWindowProperties().windowRect
      this.syncBreakpointAndSafeInsets(windowClass, initRect.width, initRect.height)

      windowClass.on('windowSizeChange', (windowSize: window.Size) => {
        console.log('windowSizeChange', windowSize.width, windowSize.height)
        this.syncBreakpointAndSafeInsets(windowClass, windowSize.width, windowSize.height)
      })
      windowClass.on('avoidAreaChange', () => {
        const rect = windowClass.getWindowProperties().windowRect
        this.syncBreakpointAndSafeInsets(windowClass, rect.width, rect.height)
      })
    } catch (exception) {

    }

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });

    FlutterManager.getInstance().pushWindowStage(this, windowStage)
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    FlutterManager.getInstance().popWindowStage(this)
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  onWindowStageRestore(windowStage: window.WindowStage): void {
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync()
      AppStorage.setOrCreate('windowClass', windowClass)

      let type = deviceInfo.deviceType
      if (type == '2in1') {
        try {
          let windowLimits: window.WindowLimits = {
            maxWidth: 3000,
            maxHeight: 1800,
            minWidth: 2000,
            minHeight: 1200
          };
          let promise = windowClass.setWindowLimits(windowLimits);
          promise.then((data) => {
            console.info('Succeeded in changing the window limits. Cause:' + JSON.stringify(data));
          }).catch((err: BusinessError) => {
            console.error(`Failed to change the window limits. Cause code: ${err.code}, message: ${err.message}`);
          });
        } catch (exception) {
          console.error(`Failed to change the window limits. Cause code: ${exception.code}, message: ${exception.message}`);
        }
      }


      // 设置窗口全屏
      windowClass.setWindowLayoutFullScreen(true)

      const initRectRestore = windowClass.getWindowProperties().windowRect
      this.syncBreakpointAndSafeInsets(windowClass, initRectRestore.width, initRectRestore.height)

      windowClass.on('windowSizeChange', (windowSize: window.Size) => {
        console.log('windowSizeChange', windowSize.width, windowSize.height)
        this.syncBreakpointAndSafeInsets(windowClass, windowSize.width, windowSize.height)
      })
      windowClass.on('avoidAreaChange', () => {
        const rect = windowClass.getWindowProperties().windowRect
        this.syncBreakpointAndSafeInsets(windowClass, rect.width, rect.height)
      })
    } catch (exception) {
      // Logger.error(`Failed to obtain the main window. Cause code: ${exception.code}, message: ${exception.message}`);
    }
  }
}