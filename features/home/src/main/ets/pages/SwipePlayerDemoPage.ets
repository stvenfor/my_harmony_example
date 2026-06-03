import { NavItem, StringConstants } from '@ohos/common'

const TAG: string = 'SwipePlayerDemoPage'

interface VideoData {
  readonly id: number
  readonly url: string
  readonly title: string
  readonly author: string
  readonly avatar: Resource
  readonly likes: number
  readonly comments: number
  readonly shares: number
  readonly description: string
  readonly music: string
}

@Component
export struct SwipePlayerDemoPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  
  @State currentIndex: number = 0
  @State isPlaying: boolean[] = []
  @State showControls: boolean = false
  @State isLiked: boolean[] = []
  @State screenBrightness: number = 0.5
  @State volumeLevel: number = 0.5
  @State showBrightness: boolean = false
  @State showVolume: boolean = false
  
  private videoControllers: VideoController[] = []
  private readonly pageBg: string = '#000000'
  
  // 模拟短视频数据
  private readonly videoList: VideoData[] = [
    {
      id: 1,
      url: 'https://www.w3schools.com/html/mov_bbb.mp4',
      title: '美丽的自然风光 🌄',
      author: '自然探索者',
      avatar: $r('sys.symbol.person_crop_circle_fill'),
      likes: 12580,
      comments: 328,
      shares: 156,
      description: '大自然的鬼斧神工，让人叹为观止 #风景 #自然',
      music: '原创音乐 - 自然之声'
    },
    {
      id: 2,
      url: 'https://www.w3schools.com/html/movie.mp4',
      title: '城市夜景延时摄影 🌃',
      author: '摄影师小王',
      avatar: $r('sys.symbol.camera'),
      likes: 8920,
      comments: 245,
      shares: 89,
      description: '用镜头记录城市的夜晚 #摄影 #延时',
      music: 'City Lights - Electronic'
    },
    {
      id: 3,
      url: 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
      title: '美食制作教程 🍜',
      author: '美食达人',
      avatar: $r('sys.symbol.fork_knife'),
      likes: 15600,
      comments: 512,
      shares: 234,
      description: '简单易学的家常菜做法 #美食 #教程',
      music: 'Cooking Time - Happy'
    },
    {
      id: 4,
      url: 'https://www.w3schools.com/html/mov_bbb.mp4',
      title: '萌宠日常记录 🐱',
      author: '铲屎官日记',
      avatar: $r('sys.symbol.pawprint'),
      likes: 23400,
      comments: 876,
      shares: 445,
      description: '我家猫咪的日常搞笑瞬间 #萌宠 #猫咪',
      music: 'Cute Cat - Funny'
    },
    {
      id: 5,
      url: 'https://www.w3schools.com/html/movie.mp4',
      title: '音乐MV精选 🎵',
      author: '音乐分享家',
      avatar: $r('sys.symbol.music_mic'),
      likes: 18900,
      comments: 623,
      shares: 312,
      description: '精选热门音乐MV #音乐 #MV',
      music: 'Top Hits 2026'
    }
  ]

  aboutToAppear(): void {
    // 初始化视频控制器和状态
    this.videoList.forEach((_, index) => {
      this.videoControllers[index] = new VideoController()
      this.isPlaying[index] = false
      this.isLiked[index] = false
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

  private toggleLike(index: number): void {
    this.isLiked[index] = !this.isLiked[index]
    if (this.isLiked[index]) {
      this.showToast('已点赞 ❤️')
    }
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

  private handleDoubleTap(index: number): void {
    this.toggleLike(index)
    // 显示点赞动画（简化版）
    this.showToast('❤️ 双击点赞')
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration: 1500 })
    } catch (error) {
      const err = error as BusinessError
      console.error(`${TAG}: showToast failed`)
    }
  }

  @Builder
  private videoItem(video: VideoData, index: number) {
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
          this.isPlaying[index] = true
        })
        .onPause(() => {
          this.isPlaying[index] = false
        })
        .onFinish(() => {
          this.isPlaying[index] = false
        })
        .onError(() => {
          this.showToast('视频加载失败')
        })

      // 单击/双击区域
      Stack() {
        // 占位，用于捕获手势
      }
      .width('100%')
      .height('100%')
      .gesture(
        GestureGroup(GestureMode.Exclusive,
          TapGesture({ count: 2 })
            .onAction(() => {
              this.handleDoubleTap(index)
            }),
          TapGesture({ count: 1 })
            .onAction(() => {
              this.togglePlayPause(index)
            })
        )
      )

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
          Image(video.avatar)
            .width(48)
            .height(48)
            .borderRadius(24)
            .border({ width: 2, color: Color.White })
          
          SymbolGlyph($r('sys.symbol.plus_circle_fill'))
            .fontSize(20)
            .fontColor([Color.White])
            .margin({ top: -10 })
        }

        Divider().color(Color.White).strokeWidth(1).width(40)

        // 点赞（带颜色变化）
        Column({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.heart'))
            .fontSize(32)
            .fontColor([this.isLiked[index] ? '#FF3B5C' : Color.White])
          Text(this.formatNumber(video.likes + (this.isLiked[index] ? 1 : 0)))
            .fontSize(12)
            .fontColor(Color.White)
        }
        .onClick(() => {
          this.toggleLike(index)
        })

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

      // 底部信息区
      Column({ space: 8 }) {
        Row({ space: 8 }) {
          Text(`@${video.author}`)
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

        Text(video.description)
          .fontSize(14)
          .fontColor(Color.White)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('80%')
          .textAlign(TextAlign.Start)

        // 音乐信息
        Row({ space: 6 }) {
          SymbolGlyph($r('sys.symbol.music_mic'))
            .fontSize(14)
            .fontColor([Color.White])
          Text(video.music)
            .fontSize(12)
            .fontColor(Color.White)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('80%')
      }
      .width('100%')
      .position({ x: 0, y: '100%' })
      .translate({ x: 16, y: -100 })
      .alignItems(HorizontalAlign.Start)

      // 顶部导航
      Row() {
        Text('推荐')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        
        Text('  ·  ')
          .fontSize(17)
          .fontColor('#CCCCCC')
        
        Text('关注')
          .fontSize(17)
          .fontColor('#CCCCCC')
        
        Text('  ·  ')
          .fontSize(17)
          .fontColor('#CCCCCC')
        
        Text('热榜')
          .fontSize(17)
          .fontColor('#CCCCCC')
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .position({ x: 0, y: 0 })
      .translate({ y: this.topArea + 10 })
      .linearGradient({
        angle: 180,
        colors: [['#66000000', 0.0], ['transparent', 1.0]]
      })
      .zIndex(100)

      // 亮度/音量提示
      if (this.showBrightness || this.showVolume) {
        Column({ space: 8 }) {
          SymbolGlyph(this.showBrightness ? $r('sys.symbol.sun_max') : $r('sys.symbol.speaker_wave_3'))
            .fontSize(40)
            .fontColor([Color.White])
          Progress({ 
            value: this.showBrightness ? this.screenBrightness * 100 : this.volumeLevel * 100, 
            total: 100, 
            type: ProgressType.Linear 
          })
            .width(120)
            .height(6)
            .color(Color.White)
            .backgroundColor('#4DFFFFFF')
            .borderRadius(3)
        }
        .width(160)
        .height(120)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#80000000')
        .borderRadius(12)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.pageBg)
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        // Swiper实现上下滑动切换视频
        Swiper() {
          ForEach(this.videoList, (video: VideoData, index: number) => {
            this.videoItem(video, index)
          }, (video: VideoData) => video.id.toString())
        }
        .vertical(true)
        .indicator(false)
        .loop(false)
        .itemSpace(0)
        .onChange((index: number) => {
          console.info(`${TAG}: Switched to video ${index}`)
          this.switchVideo(index)
        })
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
    .title('SwipePlayer示例')
  }
}
