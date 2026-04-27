import { SearchNotificationModule } from '../view/SearchNotificationModule';
import { FeatureEntryModule } from '../view/FeatureEntryModule';
import { PromotionCarouselModule } from '../view/PromotionCarouselModule';
import { ProductRecommendationModule } from '../view/ProductRecommendationModule';

@Component
export struct HomePage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        SearchNotificationModule()
        FeatureEntryModule()
        PromotionCarouselModule()
        ProductRecommendationModule()
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