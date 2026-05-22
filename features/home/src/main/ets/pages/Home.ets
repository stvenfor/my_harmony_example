import { BreakpointConstants, NavItem, RouteConstants, StringConstants } from '@ohos/common'

/** 首页入口项：routeId 与原先列表字符串完全一致，保证跳转分支不变 */
interface HomeMenuItem {
  readonly routeId: string
  readonly subtitle: string
  readonly icon: Resource
}

@Preview
@Component
export struct Home {
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  @State bottomData: string = '当前版本：1.0.0\n更新时间：2026-03-25\n开发者：开发团队'

  private readonly accentColor: string = '#0A59F7'
  private readonly cardBg: string = '#FFFFFF'
  private readonly pageBg: string = '#F2F3F5'

  private readonly menuItems: HomeMenuItem[] = [
    { routeId: '混合页面', subtitle: 'Flutter 混合栈', icon: $r('sys.symbol.arrow_left_arrow_right') },
    { routeId: '测试页面', subtitle: '资源引用示例', icon: $r('sys.symbol.checkmark_circle') },
    { routeId: '收起展开', subtitle: '富文本折叠', icon: $r('sys.symbol.repeat_1') },
    { routeId: 'SpineAnimation', subtitle: '骨骼动画', icon: $r('sys.symbol.play_arrow_triangle_2_circlepath') },
    { routeId: 'Food', subtitle: '餐饮场景', icon: $r('sys.symbol.heart_badge_plus') },
    { routeId: 'News', subtitle: '资讯流', icon: $r('sys.symbol.search_things') },
    { routeId: 'Education', subtitle: '学习模块', icon: $r('sys.symbol.ohos_folder_badge_plus') },
    { routeId: 'Shop', subtitle: '电商场景', icon: $r('sys.symbol.ellipsis_message') },
    { routeId: 'Travel', subtitle: '出行内容', icon: $r('sys.symbol.arrow_down_circle_badge_vip_circle_filled') },
    { routeId: 'SAMPLES_PAGE', subtitle: '组件样例', icon: $r('sys.symbol.repeat') },
    { routeId: 'McChartsSamples', subtitle: '图表 / 网络数据', icon: $r('sys.symbol.ohos_wifi') },
    {
      routeId: '视频播放示例',
      subtitle: 'CommonVideoPlayer 演示',
      icon: $r('sys.symbol.play_arrow_triangle_2_circlepath')
    },
    {
      routeId: '弹窗队列演示',
      subtitle: 'PopupDialogQueueManager',
      icon: $r('sys.symbol.star')
    },
    {
      routeId: 'HarmonyUtils 说明',
      subtitle: 'common 再导出工具示例',
      icon: $r('sys.symbol.doc_text')
    },
    {
      routeId: '页面跳转示例',
      subtitle: 'H5 与 ArkTS 互跳（page-redirection）',
      icon: $r('sys.symbol.arrow_left_arrow_right')
    },
    {
      routeId: '分栏控件示例',
      subtitle: '响应式 A+B+C / A+C / B+C',
      icon: $r('sys.symbol.square_grid_2x2')
    },
    {
      routeId: '嵌套列表示例',
      subtitle: '双 List 联动滚动（nested-list）',
      icon: $r('sys.symbol.repeat')
    }
  ]


  aboutToAppear(): void {
    //打印顶部和底部安全区域的尺寸
    console.info(`topArea: ${this.topArea}`)
    console.info(`bottomArea: ${this.bottomArea}`)
  }

  /**
   * 集中处理导航，分支条件与参数与原实现一致
   */
  private handleMenuClick(item: string): void {
    if (item === '混合页面') {
      const params: Record<string, Object> = { 'route': '/PartnerMain' }
      this.pathStack.pushPathByName(RouteConstants.FLUTTER_TEST_PAGE, params)
    } else if (item === '测试页面') {
      this.pathStack.pushPathByName(RouteConstants.REFERENCE_RES_PAGE, null)
    } else if (item === 'MainPage') {
      this.pathStack.pushPathByName('MainPage', null)
      console.info(`Clicked: ${item}`)
    } else if (item === '收起展开') {
      this.pathStack.pushPathByName(RouteConstants.GRAPHICS, null)
      console.info(`Clicked: ${item}`)
    } else if (item === 'SpineAnimation') {
      this.pathStack.pushPathByName(RouteConstants.SPINE_ANIMATION, null)
      console.info(`Clicked: ${item}`)
    } else if (item === 'Food') {
      this.pathStack.pushPathByName(RouteConstants.FOOD_PAGE, null)
      console.info(`Clicked: ${item}`)
    } else if (item === 'Shop') {
      this.pathStack.pushPathByName(RouteConstants.SHOP_PAGE, null)
      console.info(`Clicked: ${item}`)
    } else if (item === 'News') {
      this.pathStack.pushPathByName(RouteConstants.NEWS_PAGE, null)
      console.info(`Clicked: ${item}`)
    } else if (item === 'Travel') {
      this.pathStack.pushPathByName(RouteConstants.TRAVEL_PAGE, null)
      console.info(`Clicked: ${item}`)
    } else if (item === 'Education') {
      this.pathStack.pushPathByName(RouteConstants.EDUCATION_PAGE, null)
      console.info(`Clicked: ${item}`)
    } else if (item === 'SAMPLES_PAGE') {
      this.pathStack.pushPathByName(RouteConstants.SAMPLES_PAGE, null)
    } else if (item === 'McChartsSamples') {
      this.pathStack.pushPathByName(RouteConstants.MC_CHARTS_SAMPLES_PAGE, null)
    } else if (item === '视频播放示例') {
      this.pathStack.pushPathByName(RouteConstants.COMMON_VIDEO_PLAYER_DEMO, null)
    } else if (item === '弹窗队列演示') {
      this.pathStack.pushPathByName(RouteConstants.POPUP_DIALOG_QUEUE_DEMO, null)
    } else if (item === 'HarmonyUtils 说明') {
      this.pathStack.pushPathByName(RouteConstants.HARMONY_UTILS_REEXPORT_DOC, null)
    } else if (item === '页面跳转示例') {
      this.pathStack.pushPathByName(RouteConstants.PAGE_REDIRECTION, null)
    } else if (item === '分栏控件示例') {
      this.pathStack.pushPathByName(RouteConstants.MULTI_COLUMNS_DEMO, null)
    } else if (item === '嵌套列表示例') {
      this.pathStack.pushPathByName(RouteConstants.NESTED_LIST_DEMO, null)
    }
  }

  @Builder
  private menuCard(item: HomeMenuItem) {
    Row({ space: 14 }) {
      Column() {
        SymbolGlyph(item.icon)
          .fontSize(26)
          .renderingStrategy(SymbolRenderingStrategy.SINGLE)
          .fontColor([this.accentColor, this.accentColor, Color.White])
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#E8F0FE')
      .borderRadius(14)

      Column({ space: 4 }) {
        Text(item.routeId)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(item.subtitle)
          .fontSize(12)
          .fontColor('#99182431')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.ic_public_arrow_right'))
        .width(18)
        .height(18)
        .fillColor('#66182431')
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .backgroundColor(this.cardBg)
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: '#14000000',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      this.handleMenuClick(item.routeId)
    })
  }

  build() {
    Column() {
      // 导航栏
      NavItem({showBack: false, title: '首页功能入口'})

      // 顶部标题区：突出「网络 / 在线能力」提示
      Column({ space: 8 }) {
        Row({ space: 10 }) {
          SymbolGlyph($r('sys.symbol.ohos_wifi'))
            .fontSize(28)
            .renderingStrategy(SymbolRenderingStrategy.SINGLE)
            .fontColor([this.accentColor, this.accentColor, Color.White])
          Column({ space: 4 }) {
            Text('功能入口')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#182431')
            Text('本地与网络场景演示，点击下方卡片进入对应页面')
              .fontSize(13)
              .fontColor('#99182431')
              .maxLines(2)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 12 })

      Scroll() {
        Grid() {
          ForEach(this.menuItems, (item: HomeMenuItem) => {
            GridItem() {
              this.menuCard(item)
            }
          }, (item: HomeMenuItem) => item.routeId)
        }
        .columnsTemplate(this.getColumnsTemplate())
        .rowsGap(12)
        .columnsGap(12)
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      Divider()
        .color('#33000000')
        .strokeWidth(0.5)

      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Image($r('app.media.ic_public_app'))
            .width(22)
            .height(22)
          Text('应用信息')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
        }
        .width('100%')

        Text(this.bottomData)
          .fontSize(14)
          .lineHeight(22)
          .fontColor('#66182431')
          .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 24 })
      .backgroundColor('#FAFBFC')
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.topArea, bottom: this.bottomArea })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(this.pageBg)
  }

  getColumnsTemplate(): string {
    switch (this.breakPoint) {
      case BreakpointConstants.BREAKPOINT_SM:
      case BreakpointConstants.BREAKPOINT_MD:
        return '1fr 1fr'
      case BreakpointConstants.BREAKPOINT_LG:
        return '1fr 1fr 1fr'
      case BreakpointConstants.BREAKPOINT_XL:
        return '1fr 1fr 1fr 1fr'
      default:
        return '1fr 1fr'
    }
  }
}
