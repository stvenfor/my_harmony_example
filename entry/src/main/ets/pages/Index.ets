import { BreakpointConstants, RouteConstants} from '@ohos/common';
import { pagesMapBuilder } from './pagesMap'

@Entry
@Component
struct Index {
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD
  @Provide("pathStack") pathStack: NavPathStack = new NavPathStack()
  // 列表数据
  private listData: Array<string> = ['混合页面', '测试页面', '首页', '我的']
  // 底部展示的数据
  @State bottomData: string = '当前版本：1.0.0\n更新时间：2026-03-25\n开发者：开发团队'

  // Tab 相关配置
  @State currentIndex: number = 0
  private tabItems: Array<TabContentItem> = [
    { title: '首页', icon: '🏠' },
    { title: '我的', icon: '👤' }
  ]

  aboutToAppear(): void {

  }

  build() {
    Stack() {
      Navigation(this.pathStack) {
        Column() {
          Text(`跳过`)

            .width(144)
            .height(72)
            .backgroundColor('rgba(0,0,0,0.5)')
            .borderRadius(12)
            .fontColor('#fff')
            .textAlign(TextAlign.Center)
            .lineHeight(36)
            .fontSize(24)
            .position({ top: 100, right: 24 })
            .onClick(() => {
              this.jumpPage()
            })
            .zIndex(1)
          Column() {
            // Image($r('app.media.launch'))
            //   .width(this.breakPoint === BreakpointConstants.BREAKPOINT_MD ? '100%' : '50%')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .height(this.breakPoint === BreakpointConstants.BREAKPOINT_MD ? 'calc(100% - 290lpx)' :
            'calc(100% - 145lpx)')
          .backgroundColor('#ffffff')

          // Image($r('app.media.logo'))
          //   .width('100%')
          //   .padding({ bottom: 68 })
          //   .position({ bottom: '0lpx' })
          //   .backgroundColor("#ffffff")
        }.width('100%').height('100%')
      }
      .navDestination(pagesMapBuilder.builder)
      .mode(NavigationMode.Stack)
    }

  }

  jumpPage() {
    this.pathStack.replacePath({ name: RouteConstants.MAIN_PAGE })
  }

  // 自定义 TabBar 构建方法
  @Builder
  buildTabBar(title: string, index: number) {
    Column() {
      Text(this.tabItems[index].icon)
        .fontSize(20)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#666666')
        .margin({ bottom: 4 })

      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#666666')
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }


}

// Tab 内容项接口
interface TabContentItem {
  title: string
  icon: string
}
