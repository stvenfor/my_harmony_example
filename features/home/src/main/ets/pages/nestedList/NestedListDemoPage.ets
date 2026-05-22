import { PageHeaderComp, StringConstants } from '@ohos/common'
import { NestedListCardItemComponent } from './NestedListCardItemComponent'
import { NestedListConstants } from './NestedListConstants'
import { NestedListViewModel } from './NestedListViewModel'
import { NestedListCardItem } from './model/NestedListCardItem'
import { NestedListClassifyModel } from './model/NestedListClassifyModel'

/**
 * List 嵌套滑动示例（参考 HarmonyOS nested-list）
 * 顶部分类 Tab 与下方内容 List 通过 scrollToIndex 联动。
 */
@Component
export struct NestedListDemoPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  @State currentClassify: number = 0

  private classifyList: NestedListClassifyModel[] = []
  private topData: NestedListCardItem[] = []
  private classifyScroller: Scroller = new Scroller()
  private contentScroller: Scroller = new Scroller()

  aboutToAppear(): void {
    const vm = new NestedListViewModel()
    this.classifyList = vm.getClassifyModelList()
    this.topData = vm.getTopData()
  }

  private classifyChangeAction(startIndex: number, fromClassifyList: boolean): void {
    if (this.currentClassify !== startIndex) {
      this.currentClassify = startIndex
      if (fromClassifyList) {
        this.contentScroller.scrollToIndex(startIndex)
      } else {
        this.classifyScroller.scrollToIndex(startIndex)
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        PageHeaderComp({
          title: '嵌套列表示例',
          backAction: (): void => {
            this.pathStack.pop()
          }
        })

        Scroll() {
          Column() {
            Column() {
              Text($r('app.string.nl_common_service'))
                .fontSize($r('app.float.nl_title_font_size'))
                .fontColor($r('app.color.nl_service_color'))
                .fontWeight(NestedListConstants.FONT_WEIGHT_500)
                .fontFamily($r('app.string.nl_common_font_family'))
                .lineHeight($r('app.float.nl_common_line_height'))
                .margin({ left: $r('app.float.nl_common_margin_left') })

              List() {
                ForEach(this.topData, (item: NestedListCardItem, index: number) => {
                  ListItem() {
                    Column() {
                      Image(item.icon)
                        .width($r('app.float.nl_top_image'))
                        .height($r('app.float.nl_top_image'))
                      Text(item.name)
                        .fontSize($r('app.float.nl_item_font_size'))
                        .margin({ top: $r('app.float.nl_text_margin_top') })
                    }
                  }
                  .margin({ top: $r('app.float.nl_flex_item_margin') })
                  .width(NestedListConstants.ONE_FOURTH)
                }, (item: NestedListCardItem, index: number) => `${index}`)
              }
              .listDirection(Axis.Horizontal)
              .alignListItem(ListItemAlign.Center)
              .lanes(2)
              .scrollBar(BarState.Off)
              .enableScrollInteraction(false)
              .backgroundColor(Color.White)
              .borderRadius($r('app.float.nl_common_radius'))
              .height($r('app.float.nl_service_height'))
              .margin({ top: $r('app.float.nl_common_margin_left') })
              .padding($r('app.float.nl_service_padding'))
            }
            .alignItems(HorizontalAlign.Start)
            .padding($r('app.float.nl_common_padding'))

            Column() {
              List({ scroller: this.classifyScroller }) {
                ForEach(this.classifyList, (item: NestedListClassifyModel, index: number) => {
                  ListItem() {
                    Column() {
                      Text(item.classifyName)
                        .fontSize($r('app.float.nl_common_font_size'))
                        .fontColor(index === this.currentClassify ?
                          $r('app.color.nl_select_title_color') : $r('app.color.nl_title_color'))
                        .fontWeight(index === this.currentClassify ?
                          NestedListConstants.FONT_WEIGHT_500 : FontWeight.Normal)
                        .fontFamily($r('app.string.nl_common_font_family'))
                        .width($r('app.float.nl_item_width'))
                        .textAlign(TextAlign.Center)
                        .lineHeight($r('app.float.nl_classify_line_height'))
                      Divider()
                        .width($r('app.float.nl_item_width'))
                        .color($r('app.color.nl_select_title_color'))
                        .strokeWidth(2)
                        .visibility(index === this.currentClassify ? Visibility.Visible : Visibility.Hidden)
                        .margin({ top: $r('app.float.nl_divider_margin_top') })
                    }
                    .justifyContent(FlexAlign.Center)
                    .width(NestedListConstants.ONE_FOURTH)
                    .height(NestedListConstants.FULL_PERCENT)
                  }
                  .onClick(() => {
                    this.classifyChangeAction(index, true)
                  })
                }, (item: NestedListClassifyModel) => JSON.stringify(item.classifyName))
              }
              .height($r('app.float.nl_top_height'))
              .listDirection(Axis.Horizontal)
              .scrollBar(BarState.Off)
              .padding({
                left: $r('app.float.nl_list_padding'),
                right: $r('app.float.nl_list_padding')
              })

              List({ scroller: this.contentScroller }) {
                ForEach(this.classifyList, (item: NestedListClassifyModel, index: number) => {
                  if (index !== this.classifyList.length - 1) {
                    ListItem() {
                      NestedListCardItemComponent({ classifyModel: item })
                    }
                  } else {
                    ListItem() {
                      NestedListCardItemComponent({ classifyModel: item })
                        .height(NestedListConstants.FULL_PERCENT)
                    }
                  }
                }, (item: NestedListClassifyModel) => JSON.stringify(item.classifyName))
              }
              .nestedScroll({
                scrollForward: NestedScrollMode.PARENT_FIRST,
                scrollBackward: NestedScrollMode.SELF_FIRST
              })
              .height(NestedListConstants.LIST_HEIGHT)
              .onScrollIndex((start: number) => {
                this.classifyChangeAction(start, false)
              })
              .scrollBar(BarState.Off)
              .padding({
                left: $r('app.float.nl_common_padding'),
                right: $r('app.float.nl_common_padding'),
                bottom: $r('app.float.nl_common_padding')
              })
              .edgeEffect(EdgeEffect.None)
            }
            .height(NestedListConstants.FULL_PERCENT)
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.nl_background_color'))
      .padding({
        left: 0,
        right: 0,
        top: this.topArea,
        bottom: this.bottomArea
      })
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
