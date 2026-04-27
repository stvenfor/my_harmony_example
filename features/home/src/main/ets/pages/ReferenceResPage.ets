
import { RichTextExpand } from './RichTextExpand';
import { TextExpand } from './TextExpand';
import { BreakpointConstants, PageHeaderComp, RouteConstants, StringConstants } from '@ohos/common';


@Component
export struct  ReferenceResPage{
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD
  @Consume("pathStack") pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  uiContext = this.getUIContext()

  build() {
    NavDestination() {
      Column({ space: 15 }) {
        PageHeaderComp({
          title: '引用资源',
          backAction: () => {
            this.pathStack.pop();
          }
        })
        Row() {
          Text($r('app.string.home_Title'))
            .margin({ top: 68 })
            .fontSize(26)
            .fontWeight(700)



        }
        .width('100%')

        Column({ space: 15 }) {
          Button($r('app.string.home_Title'), { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
            .width('100%')
            .onClick(() => {

            })

          Button($r('app.string.home_Title_plain'),
            { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
            .width('100%')
            .onClick(() => {

            })
        }
      }
      .padding({ top: this.topArea, bottom: this.bottomArea })
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }.hideTitleBar( true)
    .hideBackButton( true)

  }
}

