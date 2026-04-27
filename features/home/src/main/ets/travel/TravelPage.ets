import { PageMap } from './detail/SecondPageBuilder'
import { BreakpointConstants } from './common/BreakpointConstants';
import { CommonConstants } from './common/CommonConstants';
import { HomePage } from './pages/HomePage';
import { OrderPage } from './pages/OrderPage';
import { MyPage } from './pages/MyPage';

@Entry
@Component
export  struct TravelPage {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_SM;

  @Builder
  tabBuilder(title: string, targetIndex: number, icon: Resource) {
    Column() {
      Image(icon)
        .width("24vp")
        .height("24vp")
        .objectFit(ImageFit.Contain)
        .fillColor(this.currentIndex === targetIndex ? ($r('app.color.app_icon_pressed_color')) :
          ($r('app.color.app_icon_color')))
      Text(title)
        .fontSize("10vp")
        .fontColor(this.currentIndex === targetIndex ? ($r('app.color.app_icon_pressed_color')) :
          ($r('app.color.app_icon_color')))
        .textAlign(TextAlign.Center)
        .lineHeight("14vp")
        .fontWeight(500)
    }
    .height(this.breakPoint === BreakpointConstants.BREAKPOINT_LG ? "100vp" : CommonConstants.FULL_PERCENT)
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(targetIndex);
    })
  }

  build() {
    NavDestination() {
      Tabs({
        barPosition: this.breakPoint === BreakpointConstants.BREAKPOINT_LG ? BarPosition.Start :
          BarPosition.End,
        controller: this.tabsController
      }) {
        TabContent() {
          HomePage()
        }.tabBar(this.tabBuilder('首页', 0, $r("app.media.lib_icon_8")))

        TabContent() {
          OrderPage()
        }.tabBar(this.tabBuilder('订单', 1, $r("app.media.lib_icon_173")))

        TabContent() {
          MyPage()
        }.tabBar(this.tabBuilder('我的', 2, $r("app.media.lib_icon_9")))
      }
      .barWidth(this.breakPoint === BreakpointConstants.BREAKPOINT_LG ? "96vp" :
        CommonConstants.FULL_PERCENT)
      .barHeight(this.breakPoint === BreakpointConstants.BREAKPOINT_LG ? CommonConstants.FULL_PERCENT :
        "76vp")
      .barMode(this.breakPoint === BreakpointConstants.BREAKPOINT_LG ? BarMode.Scrollable : BarMode.Fixed,
        { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER })
      .vertical(this.breakPoint === BreakpointConstants.BREAKPOINT_LG)
      .scrollable(false)
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('app.color.page_bg_color'))
    .hideTitleBar(true)
  }
}