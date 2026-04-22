import { SearchBarModule } from '../view/SearchBarModule';
import { HotSearchListModule } from '../view/HotSearchListModule';
import { HotEventTimelineModule } from '../view/HotEventTimelineModule';
import { NewsRecommendationModule } from '../view/NewsRecommendationModule';
import { NewsRecommendationModuleStyleA } from '../view/NewsRecommendationModuleStyleA';

@Component
export struct HomePage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        SearchBarModule()
        HotSearchListModule()
        HotEventTimelineModule()
        NewsRecommendationModule()
        NewsRecommendationModuleStyleA()
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