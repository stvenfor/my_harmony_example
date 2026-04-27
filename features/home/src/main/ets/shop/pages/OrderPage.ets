import { OrderStatusFilterModule } from '../view/OrderStatusFilterModule';
import { OrderListModule } from '../view/OrderListModule';
import { ProductRecommendationModuleStyleB } from '../view/ProductRecommendationModuleStyleB';

@Component
export struct OrderPage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        OrderStatusFilterModule()
        OrderListModule()
        ProductRecommendationModuleStyleB()
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