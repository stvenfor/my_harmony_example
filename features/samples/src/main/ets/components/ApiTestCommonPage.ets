import { PageHeaderComp } from "@ohos/common"
import { ArticleList } from '../model/LearnHarmonyEntity';
import { LearnHarmonyEntityVM } from "../viewmodel/LearnHarmonyEntityVM"

@Component
export struct ApiTestCommonPage {

  @Consume pathStack: NavPathStack
  @State learnHarmonyEntityVM: LearnHarmonyEntityVM = new LearnHarmonyEntityVM()

  aboutToAppear(): void {
    this.learnHarmonyEntityVM.loadData();
  }

  build() {
    NavDestination() {
      Column(){
        PageHeaderComp({
          title: "鸿蒙学习资源",
          backAction: () => {
            this.pathStack.pop()
          }
        })

        if (this.learnHarmonyEntityVM.error.length > 0) {
          Column() {
            Text(this.learnHarmonyEntityVM.error)
              .fontSize(16)
              .fontColor('#ff4d4f')
            Button('重试')
              .type(ButtonType.Normal)
              .onClick(() => {
                this.learnHarmonyEntityVM.loadData()
              })
              .margin({ top: 12 })
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
        } else if (this.learnHarmonyEntityVM.data !== null && this.learnHarmonyEntityVM.error.length === 0) {
          Scroll() {
            Column() {
              if (this.learnHarmonyEntityVM.data.links) {
                SectionCard({
                  title: this.learnHarmonyEntityVM.data.links.name || '链接',
                  articles: this.learnHarmonyEntityVM.data.links.articleList || []
                })
              }

              if (this.learnHarmonyEntityVM.data.open_sources) {
                SectionCard({
                  title: this.learnHarmonyEntityVM.data.open_sources.name || '开源项目',
                  articles: this.learnHarmonyEntityVM.data.open_sources.articleList || []
                })
              }

              if (this.learnHarmonyEntityVM.data.tools) {
                SectionCard({
                  title: this.learnHarmonyEntityVM.data.tools.name || '工具',
                  articles: this.learnHarmonyEntityVM.data.tools.articleList || []
                })
              }
            }
            .width('100%')
            .padding(12)
          }
          .width('100%')
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f5f5f5')
    }.hideTitleBar(true)
    .hideBackButton(true)
  }
}

@Component
struct SectionCard {
  @Prop title: string = ''
  @Prop articles: ArticleList[] = []

  build() {
    Column() {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 12 })

      ForEach(this.articles, (article: ArticleList) => {
        ArticleItem({ article: article })
      }, (article: ArticleList, index: number) =>
        `${article.id ?? index}_${article.link ?? ''}_${article.title ?? ''}`)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({
      radius: 4,
      color: '#0f000000',
      offsetX: 0,
      offsetY: 2
    })
  }
}

@Component
struct ArticleItem {
  @Prop article: ArticleList

  build() {
    Row() {
      Column() {
        Text(this.article.title || '无标题')
          .fontSize(15)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        if (this.article.author || this.article.niceDate) {
          Row() {
            if (this.article.author) {
              Text(this.article.author)
                .fontSize(12)
                .fontColor('#999999')
            }
            if (this.article.niceDate) {
              Text(this.article.niceDate)
                .fontSize(12)
                .fontColor('#cccccc')
                .margin({ left: 12 })
            }
          }
          .margin({ top: 6 })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.article.collect !== undefined) {
        Image(this.article.collect ? $r('app.media.ic_public_comments') : $r('app.media.ic_public_comments'))
          .width(20)
          .height(20)
          .fillColor(this.article.collect ? '#ff6b6b' : '#999999')
      }
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
    .onClick(() => {
      if (this.article.link) {
        // 可以添加跳转逻辑
      }
    })
  }
}
