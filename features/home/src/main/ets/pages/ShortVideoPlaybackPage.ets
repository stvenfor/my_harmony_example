import { NavItem, StringConstants } from '@ohos/common'

const TAG: string = 'ShortVideoPlaybackPage'

interface VideoItem {
  readonly id: number
  readonly url: string
  readonly cover: Resource
  readonly title: string
  readonly author: string
  readonly likes: number
  readonly comments: number
  readonly shares: number
}

@Component
export struct ShortVideoPlaybackPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  
  @State currentIndex: number = 0
  @State isPlaying: boolean[] = []
  @State showControls: boolean = false
  @State currentProgress: number = 0
  @State videoDuration: number = 0
  
  private videoControllers: VideoController[] = []
  private readonly pageBg: string = '#000000'
  
  // 模拟短视频数据（使用网络视频URL）
  private readonly videoList: VideoItem[] = [
    {
      id: 1,
      url: 'https://www.w3schools.com/html/mov_bbb.mp4',
      cover: $r('sys.symbol.film'),
      title: '美丽的自然风光',
      author: '@自然探索者',
      likes: 12580,
      comments: 328,
      shares: 156
    },
    {
      id: 2,
      url: 'https://www.w3schools.com/html/movie.mp4',
      cover: $r('sys.symbol.play_circle'),
      title: '城市夜景延时摄影',
      author: '@摄影师小王',
      likes: 8920,
      comments: 245,
      shares: 89
    },
    {
      id: 3,
      url: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      cover: $r('sys.symbol.camera'),
      title: '美食制作教程',
      author: '@美食达人',
      likes: 15600,
      comments: 512,
      shares: 234
    },
    {
      id: 4,
      url: 'https://www.w3schools.com/html/mov_bbb.mp4',
      cover: $r('sys.symbol.star'),
      title: '萌宠日常记录',
      author: '@铲屎官日记',
      likes: 23400,
      comments: 876,
      shares: 445
    },
    {
      id: 5,
      url: 'https://www.w3schools.com/html/movie.mp4',
      cover: $r('sys.symbol.music_mic'),
      title: '音乐MV精选',
      author: '@音乐分享家',
      likes: 18900,
      comments: 623,
      shares: 312
    }
  ]

  aboutToAppear(): void {
    // 初始化视频控制器和播放状态
    this.videoList.forEach((_, index) => {
      this.videoControllers[index] = new VideoController()
      this.isPlaying[index] = false
    })
    
    // 自动播放第一个视频
    setTimeout(() => {
      if (this.videoControllers[0]) {
        this.videoControllers[0].start()
        this.isPlaying[0] = true
      }
    }, 500)
    
    console.info(`${TAG}: Page appeared with ${this.videoList.length} videos`)
  }

  aboutToDisappear(): void {
    // 停止所有视频播放
    this.videoControllers.forEach(controller => {
      try {
        controller.stop()
      } catch (error) {
        console.error(`${TAG}: stop video failed`)
      }
    })
  }

  private formatNumber(num: number): string {
    if (num >= 10000) {
      return `${(num / 10000).toFixed(1)}w`
    }
    return num.toString()
  }

  private togglePlayPause(index: number): void {
    if (!this.videoControllers[index]) return
    
    if (this.isPlaying[index]) {
      this.videoControllers[index].pause()
      this.isPlaying[index] = false
    } else {
      this.videoControllers[index].start()
      this.isPlaying[index] = true
    }
    
    this.showControls = true
    setTimeout(() => {
      this.showControls = false
    }, 3000)
  }

  private switchVideo(index: number): void {
    // 暂停当前视频
    if (this.videoControllers[this.currentIndex]) {
      this.videoControllers[this.currentIndex].pause()
      this.isPlaying[this.currentIndex] = false
    }
    
    // 切换到新视频
    this.currentIndex = index
    
    // 播放新视频
    setTimeout(() => {
      if (this.videoControllers[index]) {
        this.videoControllers[index].start()
        this.isPlaying[index] = true
      }
    }, 300)
  }

  @Builder
  private videoItem(video: VideoItem, index: number) {
    Stack({ alignContent: Alignment.Center }) {
      // 视频播放器
      Video({
        src: video.url,
        previewUri: '',
        controller: this.videoControllers[index]
      })
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Contain)
        .autoPlay(false)
        .controls(false)
        .loop(true)
        .onStart(() => {
          console.info(`${TAG}: Video ${index} started`)
          this.isPlaying[index] = true
        })
        .onPause(() => {
          console.info(`${TAG}: Video ${index} paused`)
          this.isPlaying[index] = false
        })
        .onFinish(() => {
          console.info(`${TAG}: Video ${index} finished`)
          this.isPlaying[index] = false
        })
        .onError(() => {
          console.error(`${TAG}: Video ${index} error`)
          this.showToast('视频加载失败')
        })
        .onPrepared((e) => {
          this.videoDuration = e.duration
          console.info(`${TAG}: Video ${index} prepared, duration: ${e.duration}`)
        })
        .onUpdate((e) => {
          this.currentProgress = e.time
        })

      // 点击区域 - 暂停/播放
      Column()
        .width('100%')
        .height('100%')
        .onClick(() => {
          this.togglePlayPause(index)
        })

      // 播放/暂停图标
      if (!this.isPlaying[index]) {
        SymbolGlyph($r('sys.symbol.play_fill'))
          .fontSize(60)
          .fontColor([Color.White])
          .opacity(0.8)
      }

      // 右侧操作栏
      Column({ space: 20 }) {
        // 头像
        Column() {
          Image($r('app.media.ic_public_app'))
            .width(48)
            .height(48)
            .borderRadius(24)
            .border({ width: 2, color: Color.White })
          
          SymbolGlyph($r('sys.symbol.plus_circle'))
            .fontSize(20)
            .fontColor([Color.White])
            .margin({ top: -10 })
        }

        Divider().color(Color.White).strokeWidth(1).width(40)

        // 点赞
        Column({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.heart'))
            .fontSize(32)
            .fontColor([Color.White])
          Text(this.formatNumber(video.likes))
            .fontSize(12)
            .fontColor(Color.White)
        }

        // 评论
        Column({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.message'))
            .fontSize(32)
            .fontColor([Color.White])
          Text(this.formatNumber(video.comments))
            .fontSize(12)
            .fontColor(Color.White)
        }

        // 分享
        Column({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.arrowshape_turn_up_right'))
            .fontSize(32)
            .fontColor([Color.White])
          Text(this.formatNumber(video.shares))
            .fontSize(12)
            .fontColor(Color.White)
        }
      }
      .width(60)
      .position({ x: '100%', y: '50%' })
      .translate({ x: -70, y: '-50%' })
      .alignItems(HorizontalAlign.Center)

      // 底部信息
      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Text(video.author)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          
          Button('关注')
            .height(28)
            .fontSize(12)
            .borderRadius(14)
            .backgroundColor('#FF3B5C')
            .fontColor(Color.White)
            .padding({ left: 12, right: 12 })
        }
        .width('100%')

        Text(video.title)
          .fontSize(14)
          .fontColor(Color.White)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('80%')
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .position({ x: 0, y: '100%' })
      .translate({ x: 16, y: -120 })
      .alignItems(HorizontalAlign.Start)

      // 进度条
      if (this.showControls && this.videoDuration > 0) {
        Progress({ value: this.currentProgress, total: this.videoDuration, type: ProgressType.Linear })
          .width('100%')
          .height(3)
          .color(Color.White)
          .backgroundColor('#4DFFFFFF')
          .position({ x: 0, y: '100%' })
          .translate({ y: -50 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.pageBg)
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration: 2000 })
    } catch (error) {
      const err = error as BusinessError
      console.error(`${TAG}: showToast failed. Code: ${err.code}, message: ${err.message}`)
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        // Swiper实现上下滑动切换视频
        Swiper() {
          ForEach(this.videoList, (video: VideoItem, index: number) => {
            this.videoItem(video, index)
          }, (video: VideoItem) => video.id.toString())
        }
        .vertical(true)
        .indicator(false)
        .loop(false)
        .itemSpace(0)
        .onChange((index: number) => {
          console.info(`${TAG}: Switched to video ${index}`)
          this.switchVideo(index)
        })

        // 顶部导航
        Row() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontColor([Color.White])
            .onClick(() => {
              this.pathStack.pop()
            })

          Text('推荐')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(24)
            .fontColor([Color.White])
        }
        .width('100%')
        .height(44)
        .padding({ left: 16, right: 16 })
        .linearGradient({
          angle: 180,
          colors: [['#66000000', 0.0], ['transparent', 1.0]]
        })
        .zIndex(100)
      }
      .width('100%')
      .height('100%')
      .padding({ top: this.topArea, bottom: this.bottomArea })
      .backgroundColor(this.pageBg)
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .title('短视频播放')
  }
}
