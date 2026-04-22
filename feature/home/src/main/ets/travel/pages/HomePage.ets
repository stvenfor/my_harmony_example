import { TourismPromotionModule } from '../view/TourismPromotionModule';
import { BookingEntryModule } from '../view/BookingEntryModule';
import { LocalRecommendationModule } from '../view/LocalRecommendationModule';
import { LimitedTimeDealsModule } from '../view/LimitedTimeDealsModule';
import { TravelNotesDisplayModule } from '../view/TravelNotesDisplayModule';

@Component
export struct HomePage {
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        TourismPromotionModule()
        BookingEntryModule()
        LocalRecommendationModule()
        LimitedTimeDealsModule()
        TravelNotesDisplayModule()
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