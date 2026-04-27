import { BreakpointConstants, RouteConstants } from '@ohos/common'

@Component
export struct Home {
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD
  @Consume("pathStack") pathStack: NavPathStack
  // 底部展示的数据
  @State bottomData: string = '当前版本：1.0.0\n更新时间：2026-03-25\n开发者：开发团队'
  // 列表数据
  private listData: Array<string> = ['混合页面', '测试页面', '收起展开', 'SpineAnimation', 'Food','News','Education','Shop','Travel','SAMPLES_PAGE','McChartsSamples']

  aboutToAppear(): void {

  }

  build() {
    Column() {
      Grid() {
        ForEach(this.listData, (item: string, index: number) => {
          GridItem() {
            Text(item)
              .fontSize($r('app.float.page_text_font_size'))
              .fontWeight(FontWeight.Medium)
              .padding(20)
              .backgroundColor('#f5f5f5')
              .borderRadius(8)
              .margin({
                left: 8,
                right: 8,
                top: 8,
                bottom: 8
              })
              .onClick(() => {
                if (item === '混合页面') {
                  let params: Record<string, Object> = { "route": "/EvaluateEntry" }
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
                }else if (item === 'Food') {
                  this.pathStack.pushPathByName(RouteConstants.FOOD_PAGE, null)
                  console.info(`Clicked: ${item}`)
                }else if (item === 'Shop') {
                  this.pathStack.pushPathByName(RouteConstants.SHOP_PAGE, null)
                  console.info(`Clicked: ${item}`)
                }else if (item === 'News') {
                  this.pathStack.pushPathByName(RouteConstants.NEWS_PAGE, null)
                  console.info(`Clicked: ${item}`)
                }else if (item === 'Travel') {
                  this.pathStack.pushPathByName(RouteConstants.TRAVEL_PAGE, null)
                  console.info(`Clicked: ${item}`)
                }else if (item === 'Education') {
                  this.pathStack.pushPathByName(RouteConstants.EDUCATION_PAGE, null)
                  console.info(`Clicked: ${item}`)
                }else if(item === 'SAMPLES_PAGE'){
                  this.pathStack.pushPathByName(RouteConstants.SAMPLES_PAGE, null)
                } else if(item === 'McChartsSamples'){
                  this.pathStack.pushPathByName(RouteConstants.MC_CHARTS_SAMPLES_PAGE, null)
                }

              })
          }
        }, (item: string, index: number) => `${item}_${index}`)
      }
      .columnsTemplate(this.getColumnsTemplate())
      .rowsGap(10)
      .columnsGap(10)
      .layoutWeight(1)
      .width('100%')
      .padding({ top: 16, bottom: 16 })

      // 分隔线
      Divider()
        .color('#e0e0e0')
        .strokeWidth(1)

      // 下半部分：数据展示区域
      Column() {
        Text('应用信息')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 16 })

        Text(this.bottomData)
          .fontSize(14)
          .lineHeight(24)
          .fontColor('#666666')
          .width('90%')
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#fafafa')
    }
    .width('100%')
    .height('100%')
  }

  // 获取断点信息
  getColumnsTemplate(): string {
    // 根据断点返回列数模板字符串
    switch (this.breakPoint) {
      case BreakpointConstants.BREAKPOINT_SM:
        return '1fr 1fr' // 手机：2 列
      case BreakpointConstants.BREAKPOINT_MD:
        return '1fr 1fr 1fr' // 平板竖屏：3 列
      case BreakpointConstants.BREAKPOINT_LG:
      case BreakpointConstants.BREAKPOINT_XL:
        return '1fr 1fr 1fr 1fr' // 平板横屏：4 列
      default:
        return '1fr 1fr'
    }
  }
}

