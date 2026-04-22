import { BreakpointConstants } from '../common/BreakpointConstants';
import { CommonConstants } from '../common/CommonConstants';

@Component
export struct LatestColumnUpdateModule {
  @State image: Resource = $r('app.media.noImage');
  @State mainText: string = ['科技行业迎来新变革', '全球经济形势分析'];
  @State subText: string = ['人工智能技术突破', '市场波动下的投资策略'];
  @State commentCount: number = 42;
  @State mediaSource: string = ['科技日报', '财经周刊'];
  @State publishTime: string = ['2023-10-25 14:30', '2023-10-24 09:15'];
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;

  build() {
    Row() {
      Column() {
        Text(this.mainText)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .padding({ bottom: 4 })
          .width(CommonConstants.FULL_PERCENT)
        Row() {
          Row({ space: 4 }) {
            Image($r('app.media.ic_public_comments'))
              .width(16)
              .height(16)
            Text(this.commentCount.toString())
              .fontSize(12)
              .fontColor($r('app.color.text_secondary_News_HorizontalGraphicTextItem'))
          }
          .margin({ right: 8 })

          Text(this.mediaSource)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary_News_HorizontalGraphicTextItem'))
            .margin({ right: 8 })
          Text(this.publishTime)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary_News_HorizontalGraphicTextItem'))
        }
        .width(CommonConstants.FULL_PERCENT)
        .alignItems(VerticalAlign.Center)
      }
      .padding({ right: 6 })
      .width('65%')
      .height('90%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceBetween)

      Image(this.image)
        .borderRadius($r('sys.float.corner_radius_level6'))
        .height('90%')
        .width('35%')
    }
    .height(90)
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.background_primary_News_HorizontalGraphicTextItem'))
    .padding({ left: 8, right: 8 })
  }
}