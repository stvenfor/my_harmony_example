
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



      }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })

    .title('PageTwo')
  }
}
