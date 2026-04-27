import { PageMap } from './detail/SecondPageBuilder'
import { BreakpointConstants } from './common/BreakpointConstants';
import { CommonConstants } from './common/CommonConstants';
import { PageA } from './pages/PageA';
import { PageB } from './pages/PageB';
import { PageC } from './pages/PageC';

@Entry
@Component
export struct FoodPage {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController()
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD
  @Consume("pathStack") pathStack: NavPathStack

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
        barPosition: this.breakPoint === BreakpointConstants.BREAKPOINT_LG ? BarPosition.End :
          BarPosition.End,
        controller: this.tabsController
      }) {
        TabContent() {
          PageA()
        }.tabBar(this.tabBuilder('首页', 0, $r("app.media.lib_icon_8")))

        TabContent() {
          PageB()
        }.tabBar(this.tabBuilder('分类', 1, $r("app.media.lib_icon_37")))

        TabContent() {
          PageC()
        }.tabBar(this.tabBuilder('个人中心', 2, $r("app.media.lib_icon_1")))
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