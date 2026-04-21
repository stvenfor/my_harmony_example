import { SearchNotificationModule } from '../view/SearchNotificationModule';
import { MultiFunctionEntryModule } from '../view/MultiFunctionEntryModule';
import { PromotionCarouselModule } from '../view/PromotionCarouselModule';
import { PopularProductRecommendationModule } from '../view/PopularProductRecommendationModule';
import { FlashSaleModule } from '../view/FlashSaleModule';

@Component
export struct PageA {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        SearchNotificationModule()
        MultiFunctionEntryModule()
        PromotionCarouselModule()
        PopularProductRecommendationModule()
        FlashSaleModule()
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