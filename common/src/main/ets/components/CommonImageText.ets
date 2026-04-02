import { GridModel } from '@ohos/common'

@Component
export struct CommonImageText {
  @Prop item: GridModel

  build() {
    Column() {

      Stack() {
        Image(`${this.item.img}${new Date().getTime()}`)
          .width('100%')
          .height(120)
          // .margin({ left: 20 })
          .objectFit(ImageFit.Cover)
          .onError((err: ImageError) => {
            // 图片无法加载时触发
            console.error(`Failed to do sth. Code: ${err.error?.code}, message: ${err.message}`);
          })

        Row() {
          Text(this.item.title ?? '')
            .fontSize(20)
            .fontColor(Color.Red)
            .margin({ left: 20 })
          Text(this.item.module_kangaroo ?? '')
            .fontSize(20)
            .fontColor(Color.Blue)
            .margin({ left: 20 })
        }
        .height(32)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Start)
        .position({ bottom: 0, left: 0, right: 0 })

      }

      Row() {
        Flex() {
          ForEach(this.item.tips, (item: string) => {
            Text(item)
              .fontSize(12)
              .fontColor(Color.White)
              .margin({ right: 5 })
              .padding({ left: 5, right: 5 })
              .padding({ top: 2, bottom: 2 })
              .border({ width: 1, radius: 5, color: Color.Gray })
              .backgroundColor(Color.Gray)
          })

        }
      }.margin({ top: 10 })

      Row() {
        Text(this.item.sub_title ?? '')
          .fontSize(12)
          .fontColor(Color.Gray)
          .margin({ top: 10 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
  }
}
