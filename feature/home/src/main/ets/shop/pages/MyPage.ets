import { UserProfileModule } from '../view/UserProfileModule';
import { FeatureEntryModuleStyleA } from '../view/FeatureEntryModuleStyleA';
import { CouponDisplayModule } from '../view/CouponDisplayModule';
import { ProductRecommendationModuleStyleC } from '../view/ProductRecommendationModuleStyleC';

@Component
export struct MyPage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        UserProfileModule()
        FeatureEntryModuleStyleA()
        CouponDisplayModule()
        ProductRecommendationModuleStyleC()
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