import { ShoppingCartModule } from '../view/ShoppingCartModule';
import { ProductRecommendationModuleStyleA } from '../view/ProductRecommendationModuleStyleA';

@Component
export struct ShoppingCartPage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        ShoppingCartModule()
        ProductRecommendationModuleStyleA()
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