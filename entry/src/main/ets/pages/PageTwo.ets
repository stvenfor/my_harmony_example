
@Component
export struct PageTwo {
  @State message: string = '第二页------';
  @Consume("pathStack") pathStack: NavPathStack
  // 列表数据
  private listData: Array<string> = ['FlutterTestPage']

  aboutToAppear(): void {

  }

  build() {
    NavDestination() {

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
                    let params : Record<string, Object> = { "route": "/EvaluateEntry"}
                    this.pathStack.pushPathByName('FlutterTestPage', params)
                  } else if (item === 'PageTwo') {
                    // this.pathStack.pushPathByName('PageTwo', null)
                    let params : Record<string, Object> = { "route": "/EvaluateEntry"}
                    this.pathStack.pushPathByName('FlutterTestPage', params)
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

      }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })

    .title('PageTwo')
  }
}
