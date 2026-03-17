import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World------------';
  pageInfos: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageInfos) {
      RelativeContainer() {
        Text(this.message)
          .id('HelloWorld')
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onClick(() => {
            this.pageInfos.pushPathByName('FlutterTestPage1', "FlutterTestPage1")
            // this.pageInfos.pushPathByName('pageTwo', "Page Two");
          })
      }
      .height('100%')
      .width('100%')
    }
    .mode(NavigationMode.Stack) // 自适应模式
    .title('Home')
  }
}