import { PageHeaderComp, StringConstants } from '@ohos/common'
import {
  HARMONY_UTILS_REEXPORT_DOC_SECTIONS,
  HarmonyUtilsReExportDocSection
} from './harmonyUtilsDoc/HarmonyUtilsReExportDocData'

/**
 * 展示 @ohos/common 从 @pura/harmony-utils 再导出各工具类的说明与示例代码（数据源见 HarmonyUtilsReExportDocData.ets）。
 */
@Component
export struct HarmonyUtilsReExportDocPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0

  build() {
    NavDestination() {
      Column() {
        PageHeaderComp({
          title: 'HarmonyUtils 工具说明',
          backAction: (): void => {
            this.pathStack.pop()
          }
        })

        Text(
          '与 common/Index.ets（约 75–101 行）再导出顺序一致：AppUtil → … → CryptoHelper。示例为参考写法，以当前 @pura/harmony-utils 版本 API 为准。'
        )
          .fontSize(12)
          .fontColor('#99182431')
          .lineHeight(18)
          .padding({ left: 16, right: 16, top: 8, bottom: 4 })
          .width('100%')

        Scroll() {
          Column({ space: 0 }) {
            ForEach(HARMONY_UTILS_REEXPORT_DOC_SECTIONS, (s: HarmonyUtilsReExportDocSection) => {
              Column({ space: 8 }) {
                Text(s.title)
                  .fontSize(17)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#182431')
                  .width('100%')

                Text(s.detail)
                  .fontSize(13)
                  .fontColor('#99182431')
                  .lineHeight(20)
                  .width('100%')

                Text('示例代码')
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#0A59F7')
                  .width('100%')

                Text(s.code)
                  .fontSize(11)
                  .fontColor('#D4D4D4')
                  .fontFamily('monospace')
                  .width('100%')
                  .padding(12)
                  .backgroundColor('#1E1E1E')
                  .borderRadius(8)
                  .copyOption(CopyOptions.LocalDevice)
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
              .padding({
                left: 16,
                right: 16,
                top: 16,
                bottom: 12
              })
              .margin({ bottom: 10 })
              .backgroundColor(Color.White)
              .borderRadius(12)
              .shadow({
                radius: 8,
                color: '#12000000',
                offsetX: 0,
                offsetY: 2
              })
            }, (s: HarmonyUtilsReExportDocSection) => s.title)
          }
          .width('100%')
          .padding({ bottom: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
      }
      .width('100%')
      .height('100%')
      .padding({ top: this.topArea, bottom: this.bottomArea })
      .backgroundColor('#F2F3F5')
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
