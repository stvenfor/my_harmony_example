import { NewsCategoryModule } from '../view/NewsCategoryModule';
import { ColumnRecommendationModule } from '../view/ColumnRecommendationModule';
import { PopularColumnModule } from '../view/PopularColumnModule';
import { LatestColumnUpdateModule } from '../view/LatestColumnUpdateModule';

@Component
export struct ColumnPage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        NewsCategoryModule()
        ColumnRecommendationModule()
        PopularColumnModule()
        LatestColumnUpdateModule()
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