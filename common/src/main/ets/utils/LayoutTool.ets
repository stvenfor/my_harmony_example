import { display } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { BreakPointType } from './BreakpointSystem';

const lpx2vpRate = 0.46;

export function paintByPoint(mdSize: number, breakPoint: string): string {
  return new BreakPointType({
    md: mdSize + 'lpx',
    lg: mdSize / 2 + 'lpx',
    xl: mdSize / 3.276 + 'lpx'
  }).getValue(breakPoint)
}

export function paintByPoint2X(mdSize: number, breakPoint: string): string {
  return new BreakPointType({
    md: mdSize + 'lpx',
    lg: mdSize / 2 + 'lpx',
    xl: mdSize / 2 + 'lpx'
  }).getValue(breakPoint)
}

let breakPointSIze = AppStorage.get<string>("breakPoint") || 'md'

export function paintByPoint2XSimple(mdSize: number): string {
  return new BreakPointType({
    md: mdSize + 'lpx',
    lg: mdSize / 2 + 'lpx',
    xl: mdSize / 2 + 'lpx'
  }).getValue(breakPointSIze)
}

export function paintByPointSimple(mdSize: number): string {
  return new BreakPointType({
    md: mdSize + 'lpx',
    lg: mdSize / 2 + 'lpx',
    xl: mdSize / 3.76 + 'lpx'
  }).getValue(breakPointSIze)
}

export const replaceLpx2Vp = (lpxEl: number) => {
  console.log("AppStorage.get('breakPoint')", AppStorage.get('breakPoint'))
  if (AppStorage.get('breakPoint') == BreakpointConstants.BREAKPOINT_MD) {
    // return `${lpxEl.toString()}lpx`
    return px2vp(lpx2px(lpxEl))
  } else {
    return lpxEl * lpx2vpRate;
  }
}

/**
 * 根据主窗口物理宽高计算断点并写入 AppStorage `breakPoint`。
 * 与 EntryAbility 中 windowSizeChange / avoidAreaChange 联动，作为全局唯一断点来源。
 */
export const updateBreakPoint = (windowWidth: number, windowHeight: number): string => {
  let curBp: string = '';
  let type = deviceInfo.deviceType
  console.log('deviceType', type)
  AppStorage.setOrCreate('isPuraX', false)
  AppStorage.setOrCreate('isPuraXHorizontal', false) //true为横屏，false为竖屏默认竖屏
  // 平板
  if (type == 'tablet') {
    curBp = 'xl'
    // curBp = 'md'
    AppStorage.setOrCreate('padPortrait', windowWidth < 1920 ? true : false) // 判断平板是否在竖屏状态
    AppStorage.setOrCreate('breakPoint', curBp)

  } else {
    console.log('windowHeight/windowWidth', windowWidth, windowHeight, windowHeight / windowWidth > 1.5)
    if (type == '2in1') {
      AppStorage.setOrCreate('breakPoint', 'xl')
      return 'xl'
    }
    let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
    if (windowWidthVp < 700) {
      curBp = 'md'
    } else {
      curBp = 'lg'
    }
    if (windowHeight / windowWidth > 1.5 == true) {
      curBp = 'md'
    } else {
      if (windowHeight < 1500) {
        curBp = 'md'
      } else {
        curBp = 'lg'
      }
    }
    let ret: boolean = false;
    ret = display.isFoldable();
    console.log("curBp", curBp, windowWidthVp)
    if (deviceInfo.deviceType == 'phone' && ret == false) {
      AppStorage.setOrCreate('breakPoint', 'md')
    } else {
      // 针对puraX
      if (windowWidth == 2120 && windowHeight == 1320) { //puraX横屏
        AppStorage.setOrCreate('breakPoint', 'lg')
        AppStorage.setOrCreate('isPuraX', true)
        AppStorage.setOrCreate('isPuraXHorizontal', true)
      } else if (windowWidth == 1320 && windowHeight == 2120) { //puraX竖屏
        AppStorage.setOrCreate('breakPoint', 'md')
        AppStorage.setOrCreate('isPuraX', true)
        AppStorage.setOrCreate('isPuraXHorizontal', false)
      } else {
        AppStorage.setOrCreate('breakPoint', curBp)
      }
    }
  }
  console.log('设备类型', curBp)
  return curBp
}
