/**
 * 列表吸附滚动辅助（aceShow 式 snap 焦点计算）。
 */
export class SnapListScrollUtil {
  /**
   * 根据 onWillScroll 增量更新吸附焦点下标。
   * @param scroller List 的 Scroller
   * @param scroll 滑动增量，>0 向下滚，<0 向上滚
   * @param focusIndex 当前焦点项
   * @param startIndex onScrollIndex 首项下标
   */
  static updateFocusIndexByScroll(scroller: Scroller, scroll: number, focusIndex: number,
    startIndex: number): number {
    if (scroll === 0) {
      return focusIndex
    }
    try {
      if (scroll > 0) {
        if (startIndex > focusIndex) {
          return startIndex
        }
        const rect = scroller.getItemRect(focusIndex)
        if (rect.y + rect.height / 2 < 0) {
          return focusIndex + 1
        }
      } else {
        if (startIndex < focusIndex) {
          return startIndex
        }
        const rect = scroller.getItemRect(focusIndex)
        if (rect.y > rect.height / 2) {
          return Math.max(0, focusIndex - 1)
        }
      }
    } catch (_e) {
      return scroll > 0 ? Math.max(focusIndex, startIndex) : Math.min(focusIndex, startIndex)
    }
    return focusIndex
  }
}
