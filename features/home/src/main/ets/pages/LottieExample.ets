import { common } from '@kit.AbilityKit'
import {
  LottieController,
  LottieManager,
  LottiePlayConfig,
  LottieResourceConfig,
  LottieResourceSource,
  LottieView,
  PageHeaderComp,
  StringConstants
} from '@ohos/common'

/**
 * Lottie 示例：仅依赖 @ohos/common（lottie 三方库只在 common 声明）。
 * 资源：entry rawfile/common/lottie/guild_animation.json（path 同 entry ets 路径）
 */
@Component
export struct LottieExamplePage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0

  private smallController: LottieController = new LottieController()
  private largeController: LottieController = new LottieController()
  private hostContext?: common.UIAbilityContext = undefined

  private guildResource(): LottieResourceConfig {
    const res: LottieResourceConfig = {
      source: LottieResourceSource.ENTRY_PATH,
      entryPath: LottieManager.entryLottiePath('guild_animation.json')
    }
    return res
  }

  private playConfig(instanceName: string): LottiePlayConfig {
    const play: LottiePlayConfig = {
      loop: true,
      autoplay: true,
      contentMode: 'Contain',
      destroyOnDisappear: false,
      instanceName: instanceName
    }
    return play
  }

  aboutToAppear(): void {
    this.hostContext = getContext(this) as common.UIAbilityContext
  }

  build() {
    NavDestination() {
      Column({ space: 16 }) {
        PageHeaderComp({
          title: 'Lottie 示例',
          backAction: (): void => {
            this.pathStack.pop()
          }
        })

        Text(`path: ${LottieManager.entryLottiePath('guild_animation.json')}`)
          .fontSize(12)
          .fontColor('#666666')

        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text('120×120')
              .fontSize(12)
              .fontColor('#666666')
            LottieView({
              resource: this.guildResource(),
              play: this.playConfig('demo-guild-small'),
              lottieSize: { width: 120, height: 120 },
              uiContext: this.hostContext,
              controller: this.smallController
            })
          }

          Column({ space: 4 }) {
            Text('240×240')
              .fontSize(12)
              .fontColor('#666666')
            LottieView({
              resource: this.guildResource(),
              play: this.playConfig('demo-guild-large'),
              lottieSize: { width: 240, height: 240 },
              uiContext: this.hostContext,
              controller: this.largeController
            })
          }
        }

        Row({ space: 12 }) {
          Button('播放')
            .onClick((): void => {
              this.smallController.play()
              this.largeController.play()
            })
          Button('暂停')
            .onClick((): void => {
              this.smallController.pause()
              this.largeController.pause()
            })
        }
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
        top: this.topArea,
        bottom: this.bottomArea
      })
      .alignItems(HorizontalAlign.Start)
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
