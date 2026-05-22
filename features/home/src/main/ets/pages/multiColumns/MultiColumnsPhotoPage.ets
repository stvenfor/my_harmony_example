import { BreakpointConstants, PageHeaderComp, StringConstants } from '@ohos/common'
import { PhotoContent } from './common/PhotoContent'
import { PhotoSideBar } from './common/PhotoSideBar'

/** 场景 A+C：SideBarContainer（图库） */
@Component
export struct MultiColumnsPhotoPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  @State sideBarStatus: boolean = true

  build() {
    NavDestination() {
      Column() {
        PageHeaderComp({
          title: '图库 A+C',
          backAction: (): void => {
            this.pathStack.pop()
          }
        })

        SideBarContainer(SideBarContainerType.AUTO) {
          Column() {
            PhotoSideBar()
              .margin({ top: 8 })
          }
          .backgroundColor($r('sys.color.gray_01'))

          Column() {
            PhotoContent({ sideBarStatus: $sideBarStatus })
          }
        }
        .layoutWeight(1)
        .controlButton({
          left: 24,
          top: (AppStorage.get<number>(StringConstants.TOP_AREA) ?? 0) + 52,
          width: 24,
          height: 24
        })
        .onChange((value: boolean) => {
          this.sideBarStatus = value
        })
      }
      .width('100%')
      .height('100%')
      .padding({ bottom: this.bottomArea })
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
