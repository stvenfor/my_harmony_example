import { FlutterEntry, FlutterPage, FlutterView } from '@ohos/flutter_ohos';

@Builder
export function SubPageBuilder() {
  FlutterTestPage1()
}

@Component
struct  FlutterTestPage1{
  @State  message: string | Resource | undefined =  'dj';
  private flutterEntry: FlutterEntry | null = null;
  private flutterView?: FlutterView
  pageInfos: NavPathStack = new NavPathStack();


  aboutToAppear() {
    this.flutterEntry = new FlutterEntry(getContext(this), {'route': '/'})
    this.flutterEntry.aboutToAppear()
    this.flutterView = this.flutterEntry.getFlutterView()
  }
  aboutToDisappear() {
    this.flutterEntry?.aboutToDisappear()
  }
  onPageShow() {
    this.flutterEntry?.onPageShow()
  }
  onPageHide() {
    this.flutterEntry?.onPageHide()
  }


  // build() {
  //   NavDestination() {
  //     RelativeContainer() {
  //       Text(this.message)
  //         .fontSize($r('app.float.page_text_font_size'))
  //         .fontWeight(FontWeight.Bold)
  //         .alignRules({
  //           center: { anchor: '__container__', align: VerticalAlign.Center },
  //           middle: { anchor: '__container__', align: HorizontalAlign.Center }
  //         })
  //         .onClick(()=>{
  //           this.pageInfos.pop()
  //         })
  //     }
  //     .height('100%')
  //     .width('100%')
  //   }
  //   .title('PageTwo')
  //   .onReady((context: NavDestinationContext) => {
  //     this.pageInfos = context.pathStack
  //     this.message = context.pathInfo.param as string;
  //   })
  // }

  build() {
    NavDestination() {
      Stack() {
        FlutterPage({ viewId: this.flutterView?.getId() })
        // Column(){
        //   Text('小小')
        //     .fontColor('#333')
        //     .fontSize(36)
        //     .fontWeight(600)
        //     .width(612)
        //     .textAlign(TextAlign.Center)
        // }.layoutWeight(1).alignItems(HorizontalAlign.End).justifyContent(FlexAlign.Center)
        //
        //   }
      }
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .onBackPressed(() => {
      this.pageInfos.pop();
      return true;
    })
  }
}

