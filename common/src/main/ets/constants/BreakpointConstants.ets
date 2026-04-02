export class BreakpointConstants {
  /**
   * Breakpoints that represent small device types.
   */
  static readonly BREAKPOINT_SM: string = 'sm';
  /**
   * Breakpoints that represent middle device types.
   */
  static readonly BREAKPOINT_MD: string = 'md';
  /**
   * Breakpoints that represent large device types.
   */
  static readonly BREAKPOINT_LG: string = 'lg';
  /**
   * Breakpoints that represent large device types.
   */
  static readonly BREAKPOINT_XL: string = 'xl';
  /**
   * Current breakpoints that to query the device types.
   */
  static readonly CURRENT_BREAKPOINT: string = 'currentBreakpoint';
  /**
   * Range of the small device width.
   */
  static readonly RANGE_SM: string = '(320vp<=width<520vp)';
  /**
   * Range of the middle device width.
   */
  static readonly RANGE_MD: string = '(520vp<=width<840vp)';
  /**
   * Range of the large device width.
   */
  static readonly RANGE_LG: string = '(840vp<=width)';
  /**
   * Range of the largePlus device width.
   */
  static readonly RANGE_XL: string = '(1700vp<=width<=2720vp)';
  static readonly BREAKPOINT_VALUE: Array<string> = ['320vp', '600vp', '840vp'];
  /**
   * The break point value.
   */
  static readonly BREAKPOINT_VALUE_NUMBER: Array<number> = [320, 600, 840];
}