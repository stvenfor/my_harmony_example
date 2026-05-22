import { BreakpointConstants, PageHeaderComp, StringConstants } from '@ohos/common'
import { MainItem } from './common/SettingItem'
import { WlanItem } from './common/WlanItem'

/** 场景 B+C：Navigation 分栏（设置） */
@Component
export struct MultiColumnsSettingsPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  @Provide('pathInfo') pathInfo: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    if (this.breakPoint !== BreakpointConstants.BREAKPOINT_SM) {
      this.pathInfo.pushPath({ name: 'wlanItem' })
    }
  }

  @Builder
  settingsRouter(name: string) {
    if (name === 'wlanItem') {
      WlanItem()
    }
  }

  @Builder
  customDivider() {
    Divider()
      .strokeWidth(1)
      .color($r('sys.color.ohos_id_color_list_separator'))
      .margin({ left: 8, right: 8 })
  }

  build() {
    NavDestination() {
      Column() {
        PageHeaderComp({
          title: '设置 B+C',
          backAction: (): void => {
            this.pathStack.pop()
          }
        })

        Navigation(this.pathInfo) {
          List({ space: 10 }) {
            ListItem() {
              Search({ placeholder: $r('app.string.search') })
                .backgroundColor($r('sys.color.white'))
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })

            ListItem() {
              MainItem({ isUserItem: true, src: $r('app.media.ic_mine_normal') })
                .backgroundColor($r('sys.color.white'))
                .borderRadius(20)
                .padding({ top: 12, bottom: 12 })
            }

            ListItem() {
              Column() {
                MainItem({
                  itemDesc: $r('app.string.WLAN'),
                  src: $r('app.media.wlan'),
                  itemStatusDesc: $r('app.string.closed')
                })
                  .onClick(() => {
                    this.pathInfo.pushPath({ name: 'wlanItem' })
                  })
                this.customDivider()
                MainItem({
                  itemDesc: $r('app.string.bluetooth'),
                  src: $r('app.media.blueTooth'),
                  itemStatusDesc: $r('app.string.closed')
                })
                this.customDivider()
                MainItem({ itemDesc: $r('app.string.mobileData'), src: $r('app.media.mobileData') })
                this.customDivider()
                MainItem({
                  itemDesc: $r('app.string.moreConnections'),
                  src: $r('app.media.ic_settings_more_connections')
                })
              }
              .width('100%')
              .borderRadius(24)
              .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
              .padding({ top: 4, bottom: 4 })
            }

            ListItem() {
              Column() {
                MainItem({ itemDesc: $r('app.string.desktopAndWallpaper'), src: $r('app.media.desk') })
                this.customDivider()
                MainItem({ itemDesc: $r('app.string.displayAndBrightness'), src: $r('app.media.displayAndBrightness') })
              }
              .width('100%')
              .borderRadius(24)
              .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
              .padding({ top: 4, bottom: 4 })
            }

            ListItem() {
              Column() {
                MainItem({ itemDesc: $r('app.string.soundAndVibration'), src: $r('app.media.volume') })
                this.customDivider()
                MainItem({ itemDesc: $r('app.string.notice'), src: $r('app.media.notify') })
                this.customDivider()
                MainItem({ itemDesc: $r('app.string.storage'), src: $r('app.media.storage') })
                this.customDivider()
                MainItem({ itemDesc: $r('app.string.safe'), src: $r('app.media.security') })
                this.customDivider()
                MainItem({ itemDesc: $r('app.string.privacy'), src: $r('app.media.privacy') })
              }
              .width('100%')
              .borderRadius(24)
              .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
              .padding({ top: 4, bottom: 4 })
            }

            ListItem() {
              Column() {
                MainItem({ itemDesc: $r('app.string.userAccounts'), src: $r('app.media.userAccounts') })
                this.customDivider()
                MainItem({ itemDesc: $r('app.string.system'), src: $r('app.media.system') })
                this.customDivider()
                MainItem({ itemDesc: $r('app.string.aboutDevice'), src: $r('app.media.aboutDevice') })
              }
              .width('100%')
              .borderRadius(24)
              .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
              .padding(4)
            }
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .padding({ left: 12, right: 12 })
        }
        .layoutWeight(1)
        .width('100%')
        .navBarWidth(293)
        .title($r('app.string.settings'))
        .backgroundColor($r('sys.color.background_secondary'))
        .navDestination(this.settingsRouter)
      }
      .width('100%')
      .height('100%')
      .padding({
        top: this.topArea,
        bottom: this.bottomArea
      })
      .backgroundColor($r('sys.color.background_secondary'))
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
