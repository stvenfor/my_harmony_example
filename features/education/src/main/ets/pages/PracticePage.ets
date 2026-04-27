import { ActiveTabContentModule } from "../view/ActiveTabContentModule";
import { PracticeModeSelectionModule } from "../view/PracticeModeSelectionModule";
import { RecommendationModule } from "../view/RecommendationModule";

@Component
export struct PracticePage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        PracticeModeSelectionModule()
        ActiveTabContentModule()
        RecommendationModule()
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