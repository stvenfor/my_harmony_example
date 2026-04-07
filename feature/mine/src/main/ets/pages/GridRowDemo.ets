import { BreakpointConstants, CommonGrid, CommonImageText, GridModel, RawfileUtil } from '@ohos/common';
@Entry
@Component
export struct GridRowDemo {
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD
  @StorageLink('padPortrait') padPortrait: boolean = false
  // @Consume("pathStack") pathStack: NavPathStack
  @State gridData: Array<GridModel> = []
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    this.handleData()
  }

  async handleData() {
    try {
      const gridData = await RawfileUtil.getRawJson<Array<GridModel>>('grid.json');
      if (gridData && Array.isArray(gridData)) {
        this.gridData = gridData;
      } else {
        console.warn('handleData: invalid grid data format');
      }
    } catch (e) {
      console.error(`handleData failed: ${JSON.stringify(e)}`);
    }
  }

  @Builder
  renderCardItem(item: ESObject) {

    CommonImageText({ item: item,onItemClick:()=>{

    } })

  }

  build() {
    NavDestination() {
      Row() {
        Column() {
          Text(this.message)
            .fontSize($r('app.float.page_text_font_size'))
            .fontWeight(FontWeight.Bold)
            .onClick(() => {
              this.message = 'Welcome';
            })
          CommonGrid({
            isLazy: false,
            data: this.gridData,
            renderCardItem: this.renderCardItem,
            gridColumn: this.breakPoint == BreakpointConstants.BREAKPOINT_MD ? 2 : this.padPortrait ? 3 : 4
          })

        }
        .width('100%').padding({ left: 10, right: 10 })
      }
      .height('100%')
    }.hideTitleBar(true).hideBackButton( true)
  }
}
