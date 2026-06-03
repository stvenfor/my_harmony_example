import { display } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { StringConstants } from '../constants/StringConstants';

export enum DeviceLayoutMode {
  PHONE = 'phone',
  FOLDABLE_COMPACT = 'foldableCompact',
  FOLDABLE_EXPANDED = 'foldableExpanded',
  TABLET_PORTRAIT = 'tabletPortrait',
  TABLET_LANDSCAPE = 'tabletLandscape',
  TWO_IN_ONE = '2in1'
}

export interface AdaptiveProfile {
  deviceType: string
  breakPoint: string
  layoutMode: DeviceLayoutMode
  windowWidthVp: number
  isFoldable: boolean
  isExpandedFoldable: boolean
  isTablet: boolean
  isTwoInOne: boolean
  isLandscape: boolean
  isWideLayout: boolean
  isPadPortrait: boolean
}

function getWindowWidthVp(windowWidth: number): number {
  const density: number = display.getDefaultDisplaySync().densityPixels;
  return windowWidth / density;
}

function getFoldableState(): boolean {
  try {
    return display.isFoldable();
  } catch (err) {
    return false;
  }
}

export function buildAdaptiveProfile(windowWidth: number, windowHeight: number, breakPoint: string): AdaptiveProfile {
  const type: string = deviceInfo.deviceType;
  const windowWidthVp: number = getWindowWidthVp(windowWidth);
  const isFoldable: boolean = getFoldableState();
  const isTablet: boolean = type === 'tablet';
  const isTwoInOne: boolean = type === '2in1';
  const isLandscape: boolean = windowWidth >= windowHeight;
  const isWideLayout: boolean =
    breakPoint === BreakpointConstants.BREAKPOINT_LG ||
      breakPoint === BreakpointConstants.BREAKPOINT_XL ||
      isTwoInOne;
  const isExpandedFoldable: boolean = type === 'phone' && isFoldable && isWideLayout;
  const isPadPortrait: boolean = isTablet && !isLandscape;

  let layoutMode: DeviceLayoutMode = DeviceLayoutMode.PHONE;
  if (isTwoInOne) {
    layoutMode = DeviceLayoutMode.TWO_IN_ONE;
  } else if (isTablet) {
    layoutMode = isPadPortrait ? DeviceLayoutMode.TABLET_PORTRAIT : DeviceLayoutMode.TABLET_LANDSCAPE;
  } else if (isFoldable) {
    layoutMode = isExpandedFoldable ? DeviceLayoutMode.FOLDABLE_EXPANDED : DeviceLayoutMode.FOLDABLE_COMPACT;
  }

  return {
    deviceType: type,
    breakPoint,
    layoutMode,
    windowWidthVp,
    isFoldable,
    isExpandedFoldable,
    isTablet,
    isTwoInOne,
    isLandscape,
    isWideLayout,
    isPadPortrait
  };
}

export function syncAdaptiveProfile(windowWidth: number, windowHeight: number, breakPoint: string): AdaptiveProfile {
  const profile: AdaptiveProfile = buildAdaptiveProfile(windowWidth, windowHeight, breakPoint);
  AppStorage.setOrCreate(StringConstants.ADAPTIVE_PROFILE, profile);
  AppStorage.setOrCreate(StringConstants.DEVICE_LAYOUT_MODE, profile.layoutMode);
  AppStorage.setOrCreate(StringConstants.IS_WIDE_LAYOUT, profile.isWideLayout);
  AppStorage.setOrCreate(StringConstants.IS_FOLDABLE, profile.isFoldable);
  AppStorage.setOrCreate(StringConstants.IS_EXPANDED_FOLDABLE, profile.isExpandedFoldable);
  AppStorage.setOrCreate('padPortrait', profile.isPadPortrait);
  return profile;
}
