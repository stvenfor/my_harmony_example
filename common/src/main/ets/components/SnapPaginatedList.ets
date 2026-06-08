import { PaginatedListResult, PaginatedListStatus } from "../model/PaginatedListModel"
import { SnapListScrollUtil } from "../utils/SnapListScrollUtil"

/**
 * 通用分页列表容器：下拉刷新、上拉加载、空态/无更多/失败、可选 item 吸附对齐。
 * 业务维护 @Link items，在 onRefresh/onLoadMore 内请求并写入数组，返回 hasMore。
 */
@Component
export struct SnapPaginatedList {
  @Link items: ESObject[]
  @Link status: PaginatedListStatus
  @Link currentIndex: number

  /** 下拉刷新：业务清空/重写 items 后返回 hasMore */
  onRefresh: () => Promise<PaginatedListResult> = async (): Promise<PaginatedListResult> => {
    const empty: PaginatedListResult = { hasMore: false }
    return empty
  }
  /** 上拉加载：业务 append items 后返回 hasMore */
  onLoadMore: () => Promise<PaginatedListResult> = async (): Promise<PaginatedListResult> => {
    const empty: PaginatedListResult = { hasMore: false }
    return empty
  }
  /** 稳定 key，分页 append 时必传，避免 ForEach 错位 */
  itemKeyFn: (item: ESObject, index: number) => string = (_item: ESObject, index: number): string => {
    return `${index}`
  }

  @BuilderParam itemBuilder: (item: ESObject, index: number, isActive: boolean) => void = this.defaultItemBuilder
  @BuilderParam emptyBuilder: () => void = this.defaultEmptyBuilder
  @BuilderParam footerBuilder: () => void = this.defaultFooterBuilder
  @BuilderParam initialLoadingBuilder: () => void = this.defaultInitialLoadingBuilder
  @BuilderParam errorBuilder: () => void = this.defaultErrorBuilder

  @Prop enableSnap: boolean = false
  @Prop listSpace: number = 16
  @Prop skipFirstReachEnd: boolean = true
  @Prop emptyText: string = '没有找到相关内容'
  @Prop noMoreText: string = '暂时没有更多了'
  @Prop errorText: string = '加载失败，请重试'
  @Prop showScrollBar: boolean = false
  @Prop autoLoadOnAppear: boolean = true
  @Prop enabledRefresh: boolean = true
  @Prop enabledLoadMore: boolean = true

  @State refreshing: boolean = false
  scroller: Scroller = new Scroller()
  @State startIndex: number = 0
  @State focusIndex: number = 0
  private isScrollProcessing: boolean = false
  private isFirstReachEnd: boolean = true
  private loadMoreLock: boolean = false

  aboutToAppear(): void {
    if (this.autoLoadOnAppear) {
      void this.runInitialLoad()
    }
  }

  /** 首屏/错误重试 */
  reload(): void {
    void this.runInitialLoad()
  }

  private resolveStatus(hasMore: boolean): PaginatedListStatus {
    if (this.items.length === 0) {
      return PaginatedListStatus.Empty
    }
    if (!hasMore) {
      return PaginatedListStatus.NoMore
    }
    return PaginatedListStatus.Idle
  }

  private async runInitialLoad(): Promise<void> {
    this.status = PaginatedListStatus.InitialLoading
    try {
      const res: PaginatedListResult = await this.onRefresh()
      this.currentIndex = 0
      this.focusIndex = 0
      this.isFirstReachEnd = true
      this.status = this.resolveStatus(res.hasMore)
    } catch (_e) {
      this.status = PaginatedListStatus.Error
    }
  }

  private async handleRefresh(): Promise<void> {
    if (this.refreshing || !this.enabledRefresh) {
      return
    }
    this.refreshing = true
    this.status = PaginatedListStatus.Refreshing
    this.isFirstReachEnd = true
    try {
      const res: PaginatedListResult = await this.onRefresh()
      this.currentIndex = 0
      this.focusIndex = 0
      this.status = this.resolveStatus(res.hasMore)
    } catch (_e) {
      if (this.items.length === 0) {
        this.status = PaginatedListStatus.Error
      } else {
        this.status = PaginatedListStatus.Idle
      }
    } finally {
      this.refreshing = false
    }
  }

  private async handleLoadMore(): Promise<void> {
    if (!this.enabledLoadMore || this.loadMoreLock ||
      this.status === PaginatedListStatus.NoMore ||
      this.status === PaginatedListStatus.Empty ||
      this.status === PaginatedListStatus.InitialLoading) {
      return
    }
    this.loadMoreLock = true
    this.status = PaginatedListStatus.LoadingMore
    try {
      const res: PaginatedListResult = await this.onLoadMore()
      this.status = this.resolveStatus(res.hasMore)
    } catch (_e) {
      this.status = this.items.length === 0 ? PaginatedListStatus.Error : PaginatedListStatus.Idle
    } finally {
      this.loadMoreLock = false
    }
  }

  /** 滑动停止后将 focusIndex 对应 item 吸附到 List 顶部（与 aceShow 一致） */
  private requestSafeAlign(): void {
    if (!this.enableSnap || this.isScrollProcessing) {
      return
    }
    this.isScrollProcessing = true
    Promise.resolve().then(() => {
      try {
        const rect = this.scroller.getItemRect(this.focusIndex)
        if (Math.abs(rect.y) > 1) {
          this.scroller.scrollToIndex(this.focusIndex, true, ScrollAlign.START)
        }
        this.currentIndex = this.focusIndex
      } finally {
        setTimeout((): void => {
          this.isScrollProcessing = false
        }, 200)
      }
    })
  }

  private isItemActive(index: number): boolean {
    if (!this.enableSnap) {
      return true
    }
    return this.currentIndex === index
  }

  @Builder
  defaultItemBuilder(_item: ESObject, _index: number, _isActive: boolean) {
  }

  @Builder
  defaultEmptyBuilder() {
    Column() {
      Image($r('app.media.cases_qrcode_img'))
        .width(140)
        .height(140)
        .margin({ bottom: 20 })
      Text(this.emptyText)
        .fontSize(14)
        .fontColor('#999999')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  defaultInitialLoadingBuilder() {
    Row() {
      LoadingProgress().height(32).width(48)
      Text('加载中')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ left: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  defaultFooterBuilder() {
    if (this.status === PaginatedListStatus.LoadingMore) {
      Row() {
        LoadingProgress().height(32).width(48)
        Text('加载中')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ left: 8 })
      }
      .width('100%')
      .height(64)
      .justifyContent(FlexAlign.Center)
    } else if (this.status === PaginatedListStatus.NoMore) {
      Row() {
        Text(this.noMoreText)
          .fontSize(12)
          .fontColor('#666666')
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(64)
      .justifyContent(FlexAlign.Center)
    }
  }

  @Builder
  defaultErrorBuilder() {
    Column() {
      Text(this.errorText)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 16 })
      Button('重试')
        .fontSize(14)
        .height(36)
        .onClick((): void => {
          this.reload()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  refreshHeaderBuilder() {
    Row() {
      LoadingProgress()
        .width(20)
        .height(20)
      Text('刷新中')
        .fontSize(12)
        .fontColor('#666666')
        .margin({ left: 8 })
    }
    .justifyContent(FlexAlign.Center)
    .height(50)
    .width('100%')
  }

  @Builder
  listContentBuilder() {
    List({ space: this.listSpace, scroller: this.scroller }) {
      ForEach(this.items, (item: ESObject, index: number) => {
        ListItem() {
          this.itemBuilder(item, index, this.isItemActive(index))
        }
      }, (item: ESObject, index: number) => this.itemKeyFn(item, index))

      if (this.status === PaginatedListStatus.LoadingMore ||
        this.status === PaginatedListStatus.NoMore) {
        ListItem() {
          this.footerBuilder()
        }
      }
    }
    .width('100%')
    .height('100%')
    .scrollBar(this.showScrollBar ? BarState.Auto : BarState.Off)
    .onScrollIndex((start: number, _end: number, _center: number) => {
      this.startIndex = start
    })
    .onWillScroll((scroll: number) => {
      if (!this.enableSnap) {
        return
      }
      const newIndex: number =
        SnapListScrollUtil.updateFocusIndexByScroll(this.scroller, scroll, this.focusIndex, this.startIndex)
      if (this.focusIndex !== newIndex) {
        this.focusIndex = newIndex
      }
    })
    .onDidScroll((_scrollOffset: number, state: ScrollState) => {
      if (this.enableSnap && state === ScrollState.Idle) {
        this.requestSafeAlign()
      }
    })
    .onScrollStop((): void => {
      if (this.enableSnap) {
        this.requestSafeAlign()
      }
    })
    .onReachEnd((): void => {
      if (this.skipFirstReachEnd && this.isFirstReachEnd) {
        this.isFirstReachEnd = false
        return
      }
      void this.handleLoadMore()
    })
  }

  @Builder
  refreshBodyBuilder() {
    if (this.status === PaginatedListStatus.Empty) {
      this.emptyBuilder()
    } else if (this.status === PaginatedListStatus.Error && this.items.length === 0) {
      this.errorBuilder()
    } else {
      this.listContentBuilder()
    }
  }

  build() {
    Column() {
      if (this.status === PaginatedListStatus.InitialLoading) {
        this.initialLoadingBuilder()
      } else {
        Refresh({ refreshing: $$this.refreshing, builder: this.refreshHeaderBuilder }) {
          this.refreshBodyBuilder()
        }
        .enabled(this.enabledRefresh && !this.refreshing)
        .width('100%')
        .height('100%')
        .onStateChange(async (state: RefreshStatus): Promise<void> => {
          if (state === RefreshStatus.Refresh) {
            await this.handleRefresh()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
