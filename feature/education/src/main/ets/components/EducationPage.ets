import { BreakpointConstants } from "@ohos/common";
import { CommonConstants } from "../common/CommonConstants";
import { CoursePage } from "../pages/CoursePage";
import { HomePage } from "../pages/HomePage";
import { MyPage } from "../pages/MyPage";
import { PracticePage } from "../pages/PracticePage";

@Entry
@Component
export  struct EducationPage {
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
    .height(CommonConstants.FULL_PERCENT)
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
        barPosition:
          BarPosition.End,
        controller: this.tabsController
      }) {
        TabContent() {
          HomePage()
        }.tabBar(this.tabBuilder('首页', 0, $r("app.media.lib_icon_8")))

        TabContent() {
          CoursePage()
        }.tabBar(this.tabBuilder('课程', 1, $r("app.media.lib_icon_112")))

        TabContent() {
          PracticePage()
        }.tabBar(this.tabBuilder('练习', 2, $r("app.media.lib_icon_7")))

        TabContent() {
          MyPage()
        }.tabBar(this.tabBuilder('我的', 3, $r("app.media.lib_icon_9")))
      }
      .barWidth(
        CommonConstants.FULL_PERCENT)
      .barHeight(
        "76vp")
      .barMode( BarMode.Fixed,
        { nonScrollableLayoutStyle: LayoutStyle.ALWAYS_CENTER })
      .vertical(false)
      .scrollable(false)
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('app.color.page_bg_color'))
    .hideTitleBar(true)
  }
}