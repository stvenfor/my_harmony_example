import { BusinessError } from '@kit.BasicServicesKit'
import { webview } from '@kit.ArkWeb'
import { RouteConstants, StringConstants } from '@ohos/common'
import { ArkTSFunModel } from './ProductModel'

const TAG: string = '[PageRedirectionPage]'
const TOAST_DURATION: number = 2000
const NAV_BAR_HEIGHT: number = 56

/**
 * 页面跳转示例（参考 HarmonyOS page-redirection）
 * Web 加载本地 H5 商品列表/详情，底部后退/前进/首页；H5 可跳转原生订单确认页。
 */
@Component
export struct PageRedirectionPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  @State webCanBack: boolean = false
  @State webCanForward: boolean = false
  private controller: webview.WebviewController = new webview.WebviewController()
  private arkTSObj: ArkTSFunModel = {
    jumpOrderConfirm: (detailStr: string): void => this.jumpOrderConfirm(detailStr)
  }

  aboutToAppear(): void {
    webview.WebviewController.setWebDebuggingAccess(true)
  }

  private jumpOrderConfirm(detailStr: string): void {
    const params: Record<string, Object> = { 'detailStr': detailStr }
    this.pathStack.pushPathByName(RouteConstants.PAGE_REDIRECTION_ORDER, params)
  }

  private refreshWebNavState(): void {
    try {
      this.webCanBack = this.controller.accessBackward()
      this.webCanForward = this.controller.accessForward()
    } catch (exception) {
      const error = exception as BusinessError
      console.error(TAG, `accessBackward/Forward failed: ${error.code} ${error.message}`)
    }
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration: TOAST_DURATION })
    } catch (exception) {
      const error = exception as BusinessError
      console.error(TAG, `showToast failed: ${error.code} ${error.message}`)
    }
  }

  build() {
    NavDestination() {
      Column() {
        Web({ src: $rawfile('product_list.html'), controller: this.controller })
          .layoutWeight(1)
          .width('100%')
          .javaScriptProxy({
            object: this.arkTSObj,
            name: 'arkTSFunObj',
            methodList: ['jumpOrderConfirm'],
            controller: this.controller
          })
          .onConfirm(() => {
            this.showToast('功能开发中，敬请期待')
            return false
          })
          .onPageEnd(() => {
            this.refreshWebNavState()
          })

        Row() {
          this.webNavButton($r('sys.symbol.chevron_backward'), this.webCanBack, (): void => {
            try {
              this.controller.backward()
            } catch (exception) {
              const error = exception as BusinessError
              console.error(TAG, `backward failed: ${error.code} ${error.message}`)
            }
          })
          this.webNavButton($r('sys.symbol.chevron_forward'), this.webCanForward, (): void => {
            try {
              this.controller.forward()
            } catch (exception) {
              const error = exception as BusinessError
              console.error(TAG, `forward failed: ${error.code} ${error.message}`)
            }
          })
          this.webNavButton($r('sys.symbol.house'), true, (): void => {
            try {
              while (this.controller.accessBackward()) {
                this.controller.backward()
              }
              this.refreshWebNavState()
            } catch (exception) {
              const error = exception as BusinessError
              console.error(TAG, `home backward failed: ${error.code} ${error.message}`)
            }
          })
        }
        .justifyContent(FlexAlign.SpaceAround)
        .width('100%')
        .height(NAV_BAR_HEIGHT)
        .backgroundColor('#F1F3F5')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')
      .padding({ top: this.topArea, bottom: this.bottomArea })
    }
    .hideTitleBar(true)
    .hideBackButton(true)
    .onBackPressed(() => {
      if (this.webCanBack) {
        try {
          this.controller.backward()
        } catch (exception) {
          const error = exception as BusinessError
          console.error(TAG, `onBackPressed backward failed: ${error.code} ${error.message}`)
        }
        return true
      }
      this.pathStack.pop()
      return true
    })
  }

  @Builder
  private webNavButton(icon: Resource, enabled: boolean, onTap: () => void) {
    Button() {
      SymbolGlyph(icon)
        .fontSize(22)
        .fontColor([enabled ? '#007DFF' : '#CCCCCC', enabled ? '#007DFF' : '#CCCCCC', Color.Transparent])
    }
    .width(48)
    .height(48)
    .backgroundColor('#FFFFFF')
    .borderRadius(24)
    .enabled(enabled)
    .onClick(onTap)
  }
}
