import { PageHeaderComp, RouteConstants } from '@ohos/common';

@Component
export struct SamplesPage {
  data: Array<string> = ['mccharts', 'api-test', 'mccharts', 'mccharts',];
  @State message: string = 'Hello World';
  @Consume pathStack: NavPathStack

  build() {
    NavDestination() {
      Column() {
        PageHeaderComp({
          title: 'Samples',
          backAction: () => {
            this.pathStack.pop()
          }
        })
        Grid() {
          ForEach(this.data, (item: string, index: number) => {
            GridItem() {
              Text(item)
            }
            .onClick(async () => {
              if (item === 'api-test') {
                this.pathStack.pushPathByName(RouteConstants.API_TEST_COMMON_PAGE,null)
              }
            })
          }, (item: string, index: number) => `${item}_${index}`)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)

      }.width('100%').height('100%')

    }
    .hideTitleBar(true)
    .hideBackButton( true)
  }
}
