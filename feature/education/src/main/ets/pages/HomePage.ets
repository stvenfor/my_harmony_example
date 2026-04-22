import { CoursePromotionCarouselModule } from '../view/CoursePromotionCarouselModule';
import { EducationFeatureEntryModule } from '../view/EducationFeatureEntryModule';
import { RecommendedCoursesModule } from '../view/RecommendedCoursesModule';
import { LearningUpdatesModule } from '../view/LearningUpdatesModule';

@Component
export struct HomePage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        CoursePromotionCarouselModule()
        EducationFeatureEntryModule()
        RecommendedCoursesModule()
        LearningUpdatesModule()
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