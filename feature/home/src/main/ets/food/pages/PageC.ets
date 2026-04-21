import { UserProfileModule } from '../view/UserProfileModule';
import { FeatureEntryModule } from '../view/FeatureEntryModule';
import { PromotionalBannerModule } from '../view/PromotionalBannerModule';
import { ServiceRecommendationModule } from '../view/ServiceRecommendationModule';

@Component
export struct PageC {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        UserProfileModule()
        FeatureEntryModule()
        PromotionalBannerModule()
        ServiceRecommendationModule()
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