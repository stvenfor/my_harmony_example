// import { BreakpointConstants, BreakpointSystem } from '@ohos/common';
import { BreakpointConstants } from '@ohos/common';
import { Home } from '@ohos/home';
import { Mine } from '@ohos/mine';

@Component
export struct MainPage {
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD
  @Consume("pathStack") pathStack: NavPathStack
  // 底部展示的数据
  @State bottomData: string = '当前版本：1.0.0\n更新时间：2026-03-25\n开发者：开发团队'
  // Tab 相关配置
  @State currentIndex: number = 0
  // 列表数据
  private listData: Array<string> = ['混合页面', '测试页面', '首页', '我的']
  private tabItems: Array<TabContentItem> = [
    { title: '首页', icon: '🏠' },
    { title: '我的', icon: '👤' }
  ]

  aboutToAppear(): void {

  }

  build() {
    Stack() {
      NavDestination() {
        Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
          // Tab 1：首页
          TabContent() {
            Home()
          }
          .tabBar(this.buildTabBar('首页', 0))

          // Tab 2：我的
          TabContent() {
            Mine()
          }
          .tabBar(this.buildTabBar('我的', 1))
        }
        .layoutWeight(1)
        .width('100%')
        .barHeight(56)
        .onChange((index: number) => {
          this.currentIndex = index
        })
      }.hideTitleBar(true).hideBackButton( true)
    }

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
