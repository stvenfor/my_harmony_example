import { PageHeaderComp, PaginatedListResult, PaginatedListStatus, SnapPaginatedList, StringConstants } from '@ohos/common'

interface FeedItem {
  id: string
  title: string
}

/**
 * SnapPaginatedList 示例：下拉刷新、上拉加载、可选吸附。
 */
@Component
export struct CommonRefreshListPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0

  @State items: ESObject[] = []
  @State listStatus: PaginatedListStatus = PaginatedListStatus.InitialLoading
  @State currentIndex: number = 0
  private loadedCount: number = 0
  private static readonly PAGE_SIZE: number = 20
  private static readonly MAX_ITEMS: number = 60

  private delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => {
      setTimeout(resolve, ms)
    })
  }

  private buildMockRows(start: number, count: number): FeedItem[] {
    const rows: FeedItem[] = []
    for (let i = 0; i < count; i++) {
      const seq: number = start + i + 1
      rows.push({ id: `item-${seq}`, title: `示例条目 ${seq}` })
    }
    return rows
  }

  private async fetchPage(reset: boolean): Promise<PaginatedListResult> {
    await this.delay(400)
    const start: number = reset ? 0 : this.loadedCount
    const remain: number = CommonRefreshListPage.MAX_ITEMS - start
    const count: number = Math.min(CommonRefreshListPage.PAGE_SIZE, remain)
    const rows: FeedItem[] = this.buildMockRows(start, count)
    if (reset) {
      this.items = rows as ESObject[]
    } else {
      rows.forEach((row: FeedItem) => {
        this.items.push(row as ESObject)
      })
    }
    this.loadedCount = this.items.length
    const result: PaginatedListResult = { hasMore: this.loadedCount < CommonRefreshListPage.MAX_ITEMS }
    return result
  }

  @Builder
  FeedRow(item: ESObject, index: number, isActive: boolean) {
    Row() {
      Text((item as FeedItem).title)
        .fontSize(16)
        .fontWeight(isActive ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(isActive ? '#0A59F7' : '#182431')
    }
    .width('100%')
    .height(72)
    .padding({ left: 16, right: 16 })
    .backgroundColor(isActive ? '#E8F0FE' : '#FFFFFF')
    .borderRadius(8)
  }

  build() {
    NavDestination() {
      Column() {
        PageHeaderComp({
          title: '分页列表示例',
          backAction: (): void => {
            this.pathStack.pop()
          }
        })

        SnapPaginatedList({
          items: $items,
          status: $listStatus,
          currentIndex: $currentIndex,
          enableSnap: false,
          enabledRefresh: true,
          enabledLoadMore: true,
          onRefresh: (): Promise<PaginatedListResult> => this.fetchPage(true),
          onLoadMore: (): Promise<PaginatedListResult> => this.fetchPage(false),
          itemKeyFn: (item: ESObject, _index: number): string => {
            return (item as FeedItem).id
          },
          itemBuilder: (item: ESObject, index: number, isActive: boolean) => {
            this.FeedRow(item, index, isActive)
          }
        })
          .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
        top: this.topArea,
        bottom: this.bottomArea
      })
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
