import { OrderTypeFilterModule } from '../view/OrderTypeFilterModule';
import { OrderDisplayModule } from '../view/OrderDisplayModule';

@Component
export struct OrderPage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        OrderTypeFilterModule()
        OrderDisplayModule()
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