import { BreakpointConstants, PageHeaderComp, RouteConstants, StringConstants } from '@ohos/common'

interface MultiColumnsScenario {
  readonly title: string
  readonly subtitle: string
  readonly route: string
}

/**
 * 分栏控件示例入口（参考 HarmonyOS multi-columns）
 * A+B+C / A+C / B+C 三种响应式分栏场景。
 */
@Component
export struct MultiColumnsDemoPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0

  private readonly scenarios: MultiColumnsScenario[] = [
    {
      title: 'A+B+C',
      subtitle: 'SideBarContainer + Navigation（邮箱）',
      route: RouteConstants.MULTI_COLUMNS_MAIL
    },
    {
      title: 'A+C',
      subtitle: 'SideBarContainer（图库）',
      route: RouteConstants.MULTI_COLUMNS_PHOTO
    },
    {
      title: 'B+C',
      subtitle: 'Navigation 分栏（设置）',
      route: RouteConstants.MULTI_COLUMNS_SETTINGS
    }
  ]

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        PageHeaderComp({
          title: '分栏控件示例',
          backAction: (): void => {
            this.pathStack.pop()
          }
        })

        Text('拖动窗口或切换设备宽度，观察 sm / md / lg 下分栏与侧栏的响应式变化。')
          .fontSize(13)
          .fontColor('#99182431')
          .width('100%')
          .padding({ left: 4, right: 4 })

        List({ space: 12 }) {
          ForEach(this.scenarios, (item: MultiColumnsScenario) => {
            ListItem() {
              Column({ space: 6 }) {
                Text(item.title)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#182431')
                Text(item.subtitle)
                  .fontSize(13)
                  .fontColor('#99182431')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(12)
              .onClick(() => {
                this.pathStack.pushPathByName(item.route, null)
              })
            }
          }, (item: MultiColumnsScenario) => item.route)
        }
        .layoutWeight(1)
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
        top: this.topArea,
        bottom: this.bottomArea
      })
      .backgroundColor('#F2F3F5')
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
