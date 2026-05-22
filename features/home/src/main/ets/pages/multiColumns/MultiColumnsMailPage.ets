import { BreakpointConstants, PageHeaderComp, StringConstants } from '@ohos/common'
import { MailNavigation } from './common/MailNavigation'
import { MailSideBar } from './common/MailSideBar'

/** 场景 A+B+C：SideBarContainer + Navigation */
@Component
export struct MultiColumnsMailPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  @State isFold: boolean = false
  @State sideBarWidth: number = 304

  private isWide(): boolean {
    return this.breakPoint === BreakpointConstants.BREAKPOINT_LG ||
      this.breakPoint === BreakpointConstants.BREAKPOINT_XL
  }

  build() {
    NavDestination() {
      Column({ space: 0 }) {
        PageHeaderComp({
          title: '邮箱 A+B+C',
          backAction: (): void => {
            this.pathStack.pop()
          }
        })

        SideBarContainer(SideBarContainerType.AUTO) {
          Column() {
            MailSideBar()
          }
          .width('100%')
          .height('100%')
          .backgroundColor($r('sys.color.gray_01'))

          Column() {
            Stack() {
              MailNavigation()
                .margin({ top: 8 })
              if (this.isFold && !this.isWide()) {
                Column()
                  .width('100%')
                  .height('100%')
                  .backgroundColor('#33000000')
              }
            }
          }
          .width('100%')
          .height('100%')
        }
        .layoutWeight(1)
        .showSideBar(this.isWide())
        .sideBarWidth(this.sideBarWidth)
        .minSideBarWidth(240)
        .minContentWidth(this.breakPoint === BreakpointConstants.BREAKPOINT_SM ? 360 : 600)
        .controlButton({
          left: 24,
          top: (AppStorage.get<number>(StringConstants.TOP_AREA) ?? 0) + 62,
          width: 24,
          height: 24
        })
        .onChange((value: boolean) => {
          this.isFold = value
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
