import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { FlutterManager } from '@ohos/flutter_ohos';
import { BreakpointSystem } from '@ohos/common';
import { deviceInfo } from '@kit.BasicServicesKit';
import {  updateBreakPoint } from '@ohos/common';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private breakpointSystem: BreakpointSystem = new BreakpointSystem()

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {

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
    this.breakpointSystem.register()
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

      let topRect = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT).topRect
      let bottomRect = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect
      // 缓存window窗口对象
      AppStorage.setOrCreate('windowClass', windowClass);
      AppStorage.setOrCreate('bottomAreaRectHeight', bottomRect.height);
      let breakpoint: string = updateBreakPoint(windowClass.getWindowProperties().windowRect.width,
        windowClass.getWindowProperties().windowRect.height);

      windowClass.on('windowSizeChange', (windowSize: window.Size) => {
        console.log('windowSizeChange', windowSize.width, windowSize.height)
        breakpoint = updateBreakPoint(windowSize.width, windowSize.height);
        AppStorage.setOrCreate('topAreaRectHeight', topRect.height + (breakpoint == 'xl' ? 20 : 0));
      })
      AppStorage.setOrCreate('topAreaRectHeight', topRect.height + (breakpoint == 'xl' ? 20 : 0));
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

      let topRect = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT).topRect
      let bottomRect = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect
      // 缓存window窗口对象
      AppStorage.setOrCreate('windowClass', windowClass);
      AppStorage.setOrCreate('bottomAreaRectHeight', bottomRect.height);
      let breakpoint: string = updateBreakPoint(windowClass.getWindowProperties().windowRect.width,
        windowClass.getWindowProperties().windowRect.height);

      windowClass.on('windowSizeChange', (windowSize: window.Size) => {
        console.log('windowSizeChange', windowSize.width, windowSize.height)
        breakpoint = updateBreakPoint(windowSize.width, windowSize.height);
        AppStorage.setOrCreate('topAreaRectHeight', topRect.height + (breakpoint == 'xl' ? 20 : 0));
      })
      AppStorage.setOrCreate('topAreaRectHeight', topRect.height + (breakpoint == 'xl' ? 20 : 0));
    } catch (exception) {
      // Logger.error(`Failed to obtain the main window. Cause code: ${exception.code}, message: ${exception.message}`);
    }
  }
}