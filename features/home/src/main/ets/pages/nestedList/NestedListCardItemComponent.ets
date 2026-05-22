import { NestedListConstants } from './NestedListConstants'
import { NestedListCardItem } from './model/NestedListCardItem'
import { NestedListClassifyModel } from './model/NestedListClassifyModel'

@Component
export struct NestedListCardItemComponent {
  classifyModel: NestedListClassifyModel = new NestedListClassifyModel(0, '', [])

  build() {
    Column() {
      Column() {
        Text(this.classifyModel.classifyName)
          .fontSize($r('app.float.nl_title_font_size'))
          .fontColor($r('app.color.nl_service_color'))
          .fontWeight(NestedListConstants.FONT_WEIGHT_500)
          .fontFamily($r('app.string.nl_common_font_family'))
          .lineHeight($r('app.float.nl_common_line_height'))
          .margin({
            left: $r('app.float.nl_common_margin_left'),
            top: $r('app.float.nl_item_margin_bottom')
          })
      }

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.classifyModel.courseList, (item: NestedListCardItem, index: number) => {
          Column() {
            Image(item.icon)
              .width($r('app.float.nl_top_image'))
              .height($r('app.float.nl_top_image'))
            Text(item.name)
              .fontSize($r('app.float.nl_item_font_size'))
              .margin({ top: $r('app.float.nl_text_margin_top') })
          }
          .width(NestedListConstants.ONE_FOURTH)
          .margin({
            top: Math.floor(index / NestedListConstants.ITEM_COUNT) > 0 ? $r('app.float.nl_flex_item_margin') : 0
          })
        }, (item: NestedListCardItem, index: number) => `${index}_${JSON.stringify(item)}`)
      }
      .margin({ top: $r('app.float.nl_item_margin_top') })
      .borderRadius($r('app.float.nl_common_radius'))
      .backgroundColor(Color.White)
      .padding($r('app.float.nl_service_padding'))
    }
    .alignItems(HorizontalAlign.Start)
  }
}
