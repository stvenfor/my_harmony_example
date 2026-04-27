import { DataSource, DataSourceStyleAStyleA, DataSourceStyleBStyleB } from '../viewmodel/CategoryNavigationModuleData';
import { LoadingStatus } from '../common/CommonEnums';
import { LoadingFailedView } from '../view/LoadingFailedView';
import LazyDataSource from '../util/LazyDataSource';

@Component
export struct CategoryNavigationModule {
  @State dataModel: DataSource = DataSource.getInstance();
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @State lazyDataSource: LazyDataSource<DataSourceStyleAStyleA> = this.dataModel.lazyDataSource;
  @State selectedIndex: number = 0;
  @State selectedTopIndex: number = 0;
  @State selectedSubIndex: number = 0;
  private scrollerForList: Scroller = new Scroller();
  @Consume('pathStack') pathStack: NavPathStack;

  aboutToAppear() {
    this.loadResources();
  }

  loadResources(): void {
    this.loadingStatus = LoadingStatus.LOADING;
    this.dataModel.getResources().then(() => {
      this.loadingStatus = LoadingStatus.SUCCESS;
    }).catch(() => {
      this.loadingStatus = LoadingStatus.FAILED;
    });
  }

  @Builder
  CategoryTitle(title: string) {
    Text(title)
      .fontSize('14fp')
      .fontWeight(FontWeight.Medium)
      .width('100%')
      .padding('12vp')
      .backgroundColor($r('app.color.background_primary_MultiInfo_GoodSelection3'))
  }

  @Builder
  GiftBoxItemComponent(itemId: string, title: string, description: string, price: number,
    image: Resource, labels: string[], membershipPrice?: number) {
    Column() {
      Row() {
        Image(image)
          .width('30%')
          .aspectRatio(1)
          .borderRadius(8)
        Column() {
          Text(title)
            .fontSize('12fp')
            .fontWeight(700)
            .margin({ top: '2vp', bottom: '2vp' })
            .width('100%')
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
          Text(description)
            .fontSize('10fp')
            .fontColor($r('app.color.font_secondary_MultiInfo_GoodSelection3'))
            .margin({ bottom: '2vp' })
            .width('100%')
          Row() {
            ForEach(labels, (label: string) => {
              Text(label)
                .fontSize('10fp')
                .fontColor($r('sys.color.font_emphasize'))
                .backgroundColor('#ffffffff')
                .borderColor($r('app.color.icon_sub_emphasize'))
                .borderWidth(1)
                .borderRadius($r('sys.float.corner_radius_level6'))
                .padding({
                  left: '2vp',
                  right: '2vp',
                  top: '1vp',
                  bottom: '1vp'
                })
                .borderRadius(2)
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Row() {
            Text('¥')
              .fontSize('13fp')
              .fontColor($r('app.color.font_primary'))
            Text(price.toString())
              .fontSize('16fp')
              .fontColor($r('app.color.font_primary'))
            if (membershipPrice) {
              Text('¥' + membershipPrice + '会员价')
                .fontSize('11fp')
                .fontColor($r('app.color.font_tertiary_MultiInfo_GoodSelection3'))
                .margin({ left: '4vp' })
            }
            Blank()
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              Image($r('sys.media.ohos_ic_public_add'))
                .width(16)
                .height(16)
            }
            .height('18vp')
            .backgroundColor(Color.Transparent)
          }
          .margin({ top: '8vp' })
          .width('100%')
          .alignItems(VerticalAlign.Bottom)
        }
        .layoutWeight(1)
        .padding({ left: '8vp' })
      }
      .width('100%')
      .backgroundColor($r('app.color.background_primary_MultiInfo_GoodSelection3'))
      .alignItems(VerticalAlign.Top)

      Row() {
        Divider()
          .color($r('sys.color.comp_divider'))
          .width('70%')
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ top: '6vp' })
    }
  }

  @Builder
  SubMenuBar() {
    Row() {
      Scroll() {
        Row() {
          ForEach(DataSource.SUB_MENU1, (item: string, index: number) => {
            Text(item)
              .fontSize('12fp')
              .fontColor(this.selectedSubIndex === index ? $r('sys.color.font_emphasize') :
                $r('app.color.font_secondary_MultiInfo_GoodSelection3'))
              .backgroundColor(this.selectedSubIndex === index ? $r('sys.color.ohos_id_color_click_effect') :
                $r('app.color.background_secondary_MultiInfo_GoodSelection3'))
              .padding({
                left: '8vp',
                right: '8vp',
                top: '4vp',
                bottom: '4vp'
              })
              .margin({ right: '8vp' })
              .borderRadius(4)
              .onClick(() => {
                this.selectedSubIndex = index;
              })
          })
        }
        .backgroundColor($r('app.color.background_primary_MultiInfo_GoodSelection3'))
      }
      .height(24)
      .width('85%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .margin({ left: 12, right: 5 })

      Button({ type: ButtonType.Circle }) {
        Image($r('sys.media.ohos_ic_public_add'))
          .width('15vp')
          .height('15vp')
      }
      .width('20vp')
      .height('20vp')
      .backgroundColor($r('app.color.background_primary_MultiInfo_GoodSelection3'))
    }
    .margin({ top: "8vp" })
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Column() {
      if (this.loadingStatus === LoadingStatus.FAILED) {
        LoadingFailedView(() => this.loadResources())
      }
      if (this.loadingStatus === LoadingStatus.SUCCESS) {
        Column() {
          Scroll() {
            Row() {
              ForEach(DataSource.CATEGORIES, (category: string, index: number) => {
                Column() {
                  Stack() {
                    Row()
                      .width('48vp')
                      .height('48vp')
                      .borderRadius(8)
                      .backgroundColor($r('app.color.background_primary_MultiInfo_GoodSelection3'))
                    Image(DataSource.TOP_ICONS[index % DataSource.TOP_ICONS.length])
                      .width('32vp')
                      .height('32vp')
                      .objectFit(ImageFit.Contain)
                  }
                  .margin({ bottom: '4vp' })

                  Text(category)
                    .fontSize($r('app.integer.subtitle_text_S'))
                    .fontColor(this.selectedTopIndex === index ? $r('sys.color.font_emphasize') :
                      $r('app.color.font_secondary_MultiInfo_GoodSelection3'))
                    .fontWeight(this.selectedTopIndex === index ? FontWeight.Medium : FontWeight.Regular)
                }
                .margin({ right: '20vp' })
                .onClick(() => {
                  this.selectedTopIndex = index;
                })
              })
            }
          }
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Horizontal)
          .height('88vp')
          .backgroundColor($r('app.color.background_tertiary_MultiInfo_GoodSelection3'))
          .padding({ left: '12vp' })

          Row() {
            Column() {
              LazyForEach(this.lazyDataSource, (group: DataSourceStyleAStyleA, groupIndex: number) => {
                Row() {
                  if (this.selectedIndex === groupIndex) {
                    Divider()
                      .vertical(true)
                      .strokeWidth(3)
                      .color($r('app.color.background_emphasize'))
                      .height('16vp')
                  }
                  Text(group.getTitle())
                    .fontSize('14fp')
                    .fontColor(this.selectedIndex === groupIndex ? $r('sys.color.font_emphasize') :
                      $r('app.color.font_secondary_MultiInfo_GoodSelection3'))
                    .fontWeight(this.selectedIndex === groupIndex ? FontWeight.Medium : FontWeight.Regular)
                    .width('100%')
                    .textAlign(TextAlign.Center)
                }
                .width('100%')
                .height('44vp')
                .backgroundColor($r('app.color.background_primary_MultiInfo_GoodSelection3'))
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.selectedIndex = groupIndex;
                  this.scrollerForList.scrollToIndex(groupIndex);
                })
              }, (group: DataSourceStyleAStyleA, index: number) => index.toString() + group.getTitle())
            }
            .width('23%')
            .height('90%')
            .backgroundColor($r('app.color.background_primary_MultiInfo_GoodSelection3'))

            Divider()
              .vertical(true)
              .height('100%')
              .color($r('sys.color.comp_divider'))
              .strokeWidth(1.2)
              .opacity(0.6)
            Column() {
              this.SubMenuBar()
              List({ scroller: this.scrollerForList }) {
                LazyForEach(this.lazyDataSource, (group: DataSourceStyleAStyleA, groupIndex: number) => {
                  ListItemGroup({ header: this.CategoryTitle(group.getTitle()) }) {
                    ForEach(group.getItems(), (item: DataSourceStyleBStyleB, itemIndex: number) => {
                      ListItem() {
                        this.GiftBoxItemComponent(
                          item.getId(),
                          item.getTitle(),
                          item.getDescription(),
                          item.getPrice(),
                          item.getImage(),
                          item.getLabels(),
                          item.getMembershipPrice()
                        )
                      }
                    })
                  }
                }, (group: DataSourceStyleAStyleA, index: number) => index.toString() + group.getTitle())
              }
              .layoutWeight(1)
              .backgroundColor($r('app.color.background_primary_MultiInfo_GoodSelection3'))
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
              .padding({ left: '12vp', right: '12vp' })
              .onScrollIndex((firstIndex: number) => {
                this.selectedIndex = firstIndex;
              })
              .onClick(() => this.pathStack.pushPathByName('DetailedPagePathStack', null))
            }
            .width('77%')
            .alignItems(HorizontalAlign.Start)
          }
          .height('100%')
          .justifyContent(FlexAlign.Start)
          .backgroundColor($r('app.color.background_primary_MultiInfo_GoodSelection3'))
        }
        .width('100%')
      }
    }
  }
}