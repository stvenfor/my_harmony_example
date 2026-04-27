import { NewsCategoryFilterModule } from '../view/NewsCategoryFilterModule';
import { NewsListModule } from '../view/NewsListModule';

@Component
export struct NewsListPage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        NewsCategoryFilterModule()
        NewsListModule()
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