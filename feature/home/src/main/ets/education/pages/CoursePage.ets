import { CourseCategoryNavigationModule } from '../view/CourseCategoryNavigationModule';
import { LiveCourseRecommendationModule } from '../view/LiveCourseRecommendationModule';
import { CourseListModule } from '../view/CourseListModule';
import { CourseFilterModule } from '../view/CourseFilterModule';

@Component
export struct CoursePage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        CourseCategoryNavigationModule()
        LiveCourseRecommendationModule()
        CourseListModule()
        CourseFilterModule()
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