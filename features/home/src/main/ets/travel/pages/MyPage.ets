import { UserProfileModule } from '../view/UserProfileModule';
import { OrderManagementModule } from '../view/OrderManagementModule';
import { FunctionEntryModule } from '../view/FunctionEntryModule';
import { TravelAdRecommendationModule } from '../view/TravelAdRecommendationModule';

@Component
export struct MyPage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        UserProfileModule()
        OrderManagementModule()
        FunctionEntryModule()
        TravelAdRecommendationModule()
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .height("100%")
    .width('100%')
    .align(Alignment.Top)
    .backgroundColor($r('app.color.page_bg_color'))
  }
}