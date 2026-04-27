import { UserProfileModule } from '../view/UserProfileModule';
import { LearningProgressModule } from '../view/LearningProgressModule';
import { FunctionEntryModule } from '../view/FunctionEntryModule';
import { PersonalizedCourseRecommendationModule } from '../view/PersonalizedCourseRecommendationModule';

@Component
export struct MyPage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        UserProfileModule()
        LearningProgressModule()
        FunctionEntryModule()
        PersonalizedCourseRecommendationModule()
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