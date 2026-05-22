import { NestedListCardItem } from './model/NestedListCardItem'
import { NestedListClassifyModel } from './model/NestedListClassifyModel'

const ICON: ResourceStr = $r('app.media.ic_nl_gallery_discover')

export class NestedListViewModel {
  getTopData(): NestedListCardItem[] {
    return [
      new NestedListCardItem(ICON, $r('app.string.nl_check_in')),
      new NestedListCardItem(ICON, $r('app.string.nl_refund')),
      new NestedListCardItem(ICON, $r('app.string.nl_food')),
      new NestedListCardItem(ICON, $r('app.string.nl_ticket')),
      new NestedListCardItem(ICON, $r('app.string.nl_Travel')),
      new NestedListCardItem(ICON, $r('app.string.nl_itinerary')),
      new NestedListCardItem(ICON, $r('app.string.nl_order'))
    ]
  }

  getClassifyModelList(): NestedListClassifyModel[] {
    return [
      new NestedListClassifyModel(1, $r('app.string.nl_trip'), [
        new NestedListCardItem(ICON, $r('app.string.nl_reservation')),
        new NestedListCardItem(ICON, $r('app.string.nl_itinerary')),
        new NestedListCardItem(ICON, $r('app.string.nl_order')),
        new NestedListCardItem(ICON, $r('app.string.nl_Retrofit')),
        new NestedListCardItem(ICON, $r('app.string.nl_purchase')),
        new NestedListCardItem(ICON, $r('app.string.nl_light')),
        new NestedListCardItem(ICON, $r('app.string.nl_lounge')),
        new NestedListCardItem(ICON, $r('app.string.nl_running')),
        new NestedListCardItem(ICON, $r('app.string.nl_gift')),
        new NestedListCardItem(ICON, $r('app.string.nl_fund')),
        new NestedListCardItem(ICON, $r('app.string.nl_invoice')),
        new NestedListCardItem(ICON, $r('app.string.nl_pass')),
        new NestedListCardItem(ICON, $r('app.string.nl_Baggage')),
        new NestedListCardItem(ICON, $r('app.string.nl_feed'))
      ]),
      new NestedListClassifyModel(2, $r('app.string.nl_Tourism'), [
        new NestedListCardItem(ICON, $r('app.string.nl_Subway')),
        new NestedListCardItem(ICON, $r('app.string.nl_transfer')),
        new NestedListCardItem(ICON, $r('app.string.nl_tourism'))
      ]),
      new NestedListClassifyModel(3, $r('app.string.nl_entertainment'), [
        new NestedListCardItem(ICON, $r('app.string.nl_family')),
        new NestedListCardItem(ICON, $r('app.string.nl_redemption')),
        new NestedListCardItem(ICON, $r('app.string.nl_complement')),
        new NestedListCardItem(ICON, $r('app.string.nl_paradise')),
        new NestedListCardItem(ICON, $r('app.string.nl_Points')),
        new NestedListCardItem(ICON, $r('app.string.nl_calculator'))
      ]),
      new NestedListClassifyModel(4, $r('app.string.nl_assistant'), [
        new NestedListCardItem(ICON, $r('app.string.nl_network')),
        new NestedListCardItem(ICON, $r('app.string.nl_Corporate')),
        new NestedListCardItem(ICON, $r('app.string.nl_guide')),
        new NestedListCardItem(ICON, $r('app.string.nl_ride')),
        new NestedListCardItem(ICON, $r('app.string.nl_more')),
        new NestedListCardItem(ICON, $r('app.string.nl_account'))
      ])
    ]
  }
}
