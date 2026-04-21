import { pagesMapBuilder } from './pagesMap'


@Entry
@Component
struct Index {
  @State message: string = 'Hello World---0000000';
  @Provide("pathStack") pathStack: NavPathStack = new NavPathStack()

  // 列表数据
  private listData: Array<string> = ['FlutterTestPage', 'PageTwo', '测试页面 1', '测试页面 2', '测试页面 3']

  // 底部展示的数据
  @State bottomData: string = '当前版本：1.0.0\n更新时间：2026-03-25\n开发者：开发团队'


  build() {
    Navigation(this.pathStack) {
      Column() {
        // 上半部分：ListView
        List({ space: 10 }) {
          ForEach(this.listData, (item: string, index: number) => {
            ListItem() {
              Text(item)
                .fontSize($r('app.float.page_text_font_size'))
                .fontWeight(FontWeight.Medium)
                .padding(20)
                .backgroundColor('#f5f5f5')
                .borderRadius(8)
                .margin({ left: 16, right: 16 })
                .onClick(() => {
                  if (item === 'FlutterTestPage') {
                    let params : Record<string, Object> = { "route": "/home"}
                    this.pathStack.pushPathByName('FlutterTestPage', params)
                  } else if (item === 'PageTwo') {
                    this.pathStack.pushPathByName('PageTwo', null)
                  } else {
                    // 其他页面可以根据需要添加
                    console.info(`Clicked: ${item}`)
                  }
                })
            }
          }, (item: string, index: number) => `${item}_${index}`)
        }
        .layoutWeight(1) // 占据剩余空间
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
    .navDestination(pagesMapBuilder.builder)
    .mode(NavigationMode.Stack)
    .title('Home')
  }
}
