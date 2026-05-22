import { window } from '@kit.ArkUI';
import { BreakpointConstants } from '@ohos/common';


@Entry
@Component
export struct MainPage {
  @State message: string = 'Hello World222';
  @StorageLink('topArea') topInset: number = 0;
  @StorageLink('bottomArea') bottomInset: number = 0;
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD;
  @StorageLink('padPortrait') padPortrait: boolean = false;

  private swiperController: SwiperController = new SwiperController();

  private swiperData: string[] = ['Slide 1', 'Slide 2', 'Slide 3', 'Slide 4', 'Slide 5'];
  private gridData: string[] = [
    'Item 1', 'Item 2', 'Item 3', 'Item 4',
    'Item 5', 'Item 6', 'Item 7', 'Item 8',
    'Item 9', 'Item 10', 'Item 11', 'Item 12'
  ];

  getGridColumns(): number {
    if (this.breakPoint === BreakpointConstants.BREAKPOINT_MD) {
      return 2;
    } else if (this.padPortrait) {
      return 3;
    } else {
      return 4;
    }
  }

  build() {
    Scroll() {
      Column() {
        Text(this.message)
          .fontSize($r('app.float.page_text_font_size'))
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.message = 'Welcome99';
          })
          .fontColor(Color.Blue)
          .margin({ bottom: 20 })

        Swiper(this.swiperController) {
          ForEach(this.swiperData, (item: string, index: number) => {
            Column() {
              Text(item)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
            }
            .width('100%')
            .height(150)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.getSwiperColor(index))
            .borderRadius(8)
          }, (item: string, index: number) => `${item}_${index}`)
        }
        .displayCount(1)
        .indicator(true)
        .autoPlay(true)
        .interval(3000)
        .itemSpace(10)
        .height(150)
        .width('100%')
        .margin({ bottom: 20 })

        Grid() {
          ForEach(this.gridData, (item: string, index: number) => {
            GridItem() {
              Column() {
                Text(item)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
              }
              .width('100%')
              .height(120)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
            }
          }, (item: string, index: number) => `${item}_${index}`)
        }
        .columnsTemplate(this.getGridColumns() === 2 ? '1fr 1fr' :
          this.getGridColumns() === 3 ? '1fr 1fr 1fr' : '1fr 1fr 1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)
        .width('100%')
        .padding({ left: 12, right: 12 })
      }
      .width('100%')
      .padding({
        top: this.topInset,
        bottom: this.bottomInset,
        left: 16,
        right: 16
      })
    }
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Vertical)
    .height('100%')
    .backgroundColor(Color.White)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  private getSwiperColor(index: number): Color {
    const colors: Color[] = [Color.Blue, Color.Red, Color.Green, Color.Orange, Color.Pink];
    return colors[index % colors.length];
  }
}
