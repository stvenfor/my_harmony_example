import { CommonVideoPlayer, PageHeaderComp, StringConstants } from '@ohos/common';

/**
 * 使用 common 模块 CommonVideoPlayer 的网络视频演示页
 */
@Component
export struct CommonVideoPlayerDemoPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  /** 公开可访问的演示 MP4（与 CommonVideoPlayer 文件头示例一致） */
  @State videoUrl: string =
    'https://sf1-cdn-tos.huoshanstatic.com/obj/media-fe/xgplayer_doc_video/mp4/xgplayer-demo-360p.mp4'

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        PageHeaderComp({
          title: '视频播放示例',
          backAction: (): void => {
            this.pathStack.pop()
          }
        })

        Text('CommonVideoPlayer：进度拖动、倍速、音量与全屏由组件内置控制条提供。')
          .fontSize(13)
          .fontColor('#99182431')
          .width('100%')
          .padding({ left: 4, right: 4 })

        CommonVideoPlayer({
          src: this.videoUrl,
          autoPlay: true,
          loop: false,
          layoutHeightVp: 220,
          surfaceKey: 'home_common_video_demo',
          showControls: true
        })
        .width('100%')

        Blank().layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
        top: this.topArea,
        bottom: this.bottomArea
      })
    }
    .hideTitleBar(true)
    .hideBackButton(true)
  }
}
