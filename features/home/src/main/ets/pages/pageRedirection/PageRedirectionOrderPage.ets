import { BusinessError } from '@kit.BasicServicesKit'
import { PageHeaderComp, RouteConstants, StringConstants } from '@ohos/common'
import ProductModel from './ProductModel'

const TAG: string = '[PageRedirectionOrderPage]'
const TOAST_DURATION: number = 2000

/** 订单确认页（由 H5 详情「立即购买」跳转，展示 H5 传入的商品参数） */
@Component
export struct PageRedirectionOrderPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  @State productDetail: ProductModel = {
    id: 0,
    name: '',
    img: 'imgs/ic_1.png',
    price: 0,
    sku: ''
  }

  build() {
    NavDestination() {
      Column({ space: 12 }) {
        PageHeaderComp({
          title: '确认订单',
          backAction: (): void => {
            this.pathStack.pop()
          }
        })

        Column({ space: 12 }) {
          Row({ space: 12 }) {
            SymbolGlyph($r('sys.symbol.local_fill'))
              .fontSize(22)
              .fontColor(['#007DFF', '#007DFF', Color.Transparent])
            Column({ space: 4 }) {
              Row({ space: 12 }) {
                Text('张三')
                  .fontSize(16)
                  .fontColor('#182431')
                Text('138****8888')
                  .fontSize(16)
                  .fontColor('#182431')
              }
              Text('北京市朝阳区某某街道 1 号')
                .fontSize(14)
                .fontColor('#99182431')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)

          Column({ space: 12 }) {
            Row({ space: 8 }) {
              SymbolGlyph($r('sys.symbol.person_crop_circle_fill'))
                .fontSize(20)
                .fontColor(['#007DFF', '#007DFF', Color.Transparent])
              Text('自营')
                .fontSize(16)
                .fontColor('#182431')
            }
            .width('100%')

            Divider().color('#F2F3F5')

            Row({ space: 12 }) {
              Image($rawfile(this.productDetail.img))
                .width(88)
                .height(88)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
              Column({ space: 6 }) {
                Text(this.productDetail.name)
                  .fontSize(15)
                  .fontColor('#182431')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                if (this.productDetail.sku) {
                  Text(this.productDetail.sku)
                    .fontSize(13)
                    .fontColor('#99182431')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column() {
                Text(`¥${this.productDetail.price}`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#E84026')
                Text('x1')
                  .fontSize(13)
                  .fontColor('#99182431')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.End)
            }
            .alignItems(VerticalAlign.Top)
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
        }
        .layoutWeight(1)
        .width('100%')

        Row() {
          Row() {
            Text('合计 ¥')
              .fontSize(14)
              .fontColor('#E84026')
            Text(`${this.productDetail.price}`)
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .fontColor('#E84026')
          }
          Button('提交订单')
            .width('50%')
            .height(44)
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#007DFF')
            .borderRadius(22)
            .onClick(() => {
              try {
                this.getUIContext().getPromptAction().showToast({
                  message: '功能开发中，敬请期待',
                  duration: TOAST_DURATION
                })
              } catch (exception) {
                const error = exception as BusinessError
                console.error(TAG, `showToast failed: ${error.code} ${error.message}`)
              }
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 4, right: 4 })
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
        top: this.topArea,
        bottom: this.bottomArea
      })
      .backgroundColor('#F2F3F5')
    }
    .hideTitleBar(true)
    .hideBackButton(true)
    .onReady(() => {
      this.initParams()
    })
  }

  private initParams(): void {
    const array = this.pathStack.getParamByName(RouteConstants.PAGE_REDIRECTION_ORDER) as Array<Record<string, Object>>
    const params: Record<string, Object> = array.length > 0 ? array[0] : {}
    const detailStr = params['detailStr'] as string
    if (detailStr && detailStr.length > 0) {
      try {
        this.productDetail = JSON.parse(detailStr) as ProductModel
      } catch (e) {
        console.error(TAG, `parse detailStr failed: ${JSON.stringify(e)}`)
      }
    }
  }
}
