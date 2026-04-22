import {
  Data, DataSource
} from '../viewmodel/ColumnRecommendationModuleData';
import { LoadingStatus } from '../common/CommonEnums';
import { LoadingFailedView } from '../view/LoadingFailedView';
import { BreakpointConstants } from '../common/BreakpointConstants';
import { BreakpointType } from '../util/BreakpointType';
import LazyDataSource from '../util/LazyDataSource';
import { CommonConstants } from '../common/CommonConstants';

@Component
export struct ColumnRecommendationModule {
  @State itemModel: Data =
    Data.getInstance();
  @Prop listDirection: Axis = Axis.Vertical
  @State moduleTitle: string = "编辑精选专栏";
  @State moduleRedirectContent: string = "查看更多专栏";
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @State lazyDataSource: LazyDataSource<DataSource> =
    this.itemModel.lazyDataSource;
  private spaceArray: string[] = ['8vp', '6vp', '10vp'];
  private lanesArray: number[] = [1, 2, 3];
  @Consume('pathStack') pathStack: NavPathStack;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;

  aboutToAppear() {
    this.loadResources();
  }

  jump(pageName: string = 'EmptyPagePathStack'): void {
    this.pathStack.pushPathByName(pageName, null);
  }

  loadResources(): void {
    this.loadingStatus = LoadingStatus.LOADING;
    this.itemModel.getResources().then(() => {
      this.loadingStatus = LoadingStatus.SUCCESS;
    }).catch(() => {
      this.loadingStatus = LoadingStatus.FAILED;
    });
  }

  build() {
    Column() {
      Column() {
        ColumnRecommendationModuleTitleInfo({
          title: this.moduleTitle,
          moduleRedirectContent: this.moduleRedirectContent,
          onJump: () => {
            this.jump()
          }
        })
        if (this.loadingStatus === LoadingStatus.FAILED) {
          LoadingFailedView(() => this.loadResources())
        }
        if (this.loadingStatus === LoadingStatus.SUCCESS) {
          List({
            space: new BreakpointType(this.spaceArray[0], this.spaceArray[1],
              this.spaceArray[2]).getValue(this.currentWidthBreakpoint)
          }) {
            LazyForEach(this.lazyDataSource, (item: DataSource, index: number) => {
              ListItem() {
                News_VerticalNovelInfoItem({
                  image: item.getImage(),
                  mainText: item.getMainText(),
                  descriptionText: item.getDescriptionText(),
                  tagTextList: item.getTagTextList(),
                  tagTextColorList: item.getTagTextColorList()
                })
              }
              .width('100%')
              .height("120")
              .borderRadius($r('sys.float.corner_radius_level8'))
              .backgroundColor($r('app.color.module_item_bg_color'))
              .onClick(() => {
                this.jump("ColumnRecommendationModuleDetail" + index.toString())
              })
            }, (item: DataSource, index: number) => index + JSON.stringify(item))
          }
          .width('auto')
          .height('auto')
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
          .listDirection(this.listDirection)
          .lanes(new BreakpointType(this.lanesArray[0], this.lanesArray[1],
            this.lanesArray[2]).getValue(this.currentWidthBreakpoint), "12vp")
        }
      }
      .borderRadius($r('sys.float.corner_radius_level8'))
      .margin({ bottom: "10vp" })
      .align(Alignment.Center)
      .width('92%')
    }
    .width("100%")
  }
}

@Component
export struct News_VerticalNovelInfoItem {
  @State image: Resource = $r('app.media.noImage');
  @State mainText: string = '主标题文本';
  @State subText: string = '子标题文本';
  @State descriptionText: string = '这是一个描述文本，用于展示一些详细信息。';
  @State tagTextList: string[] = ['标签1', '标签2', '标签3', "标签4"];
  @State tagTextColorList: Color[] = [Color.Brown, Color.Green, Color.Gray, Color.Blue];
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;

  build() {
    Column() {
      Row() {
        /**
         * TODO:
         * please modify it according to the actual situation.
         * directly modify {@link List_HorizontalGraphicTextDisplayItemModel#IMAGES}
         * or refactor method {@code getResources()} to implement your custom code logic.
         * @see List_HorizontalGraphicTextDisplayItemModel#getResources()
         */
        Image(this.image)
          .margin({ left: 8, right: 8 })
          .borderRadius($r('sys.float.corner_radius_level8'))
          .height('90%')
          .width('25%')
        Column() {
          /**
           * TODO:
           * please modify it according to the actual situation.
           * directly modify {@link List_HorizontalGraphicTextDisplayItemModel#MAIN_TEXT}
           * or refactor method {@code getResources()} to implement your custom code logic.
           * @see List_HorizontalGraphicTextDisplayItemModel#getResources()
           */
          Text(this.mainText)
            .fontSize($r('app.integer.subtitle_text_M'))
            .fontColor($r('app.color.content_font_color'))
            .fontWeight(FontWeight.Bold)
            .padding({ bottom: 2 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .height('20%')
            .width(CommonConstants.FULL_PERCENT)
          /**
           * TODO:
           * please modify it according to the actual situation.
           * directly modify {@link List_HorizontalGraphicTextDisplayItemModel#SUB_TEXT}
           * or refactor method {@code getResources()} to implement your custom code logic.
           * @see List_HorizontalGraphicTextDisplayItemModel#getResources()
           */
          Text(this.descriptionText)
            .fontSize($r('app.integer.caption_text_L'))
            .fontColor($r('app.color.description_font_color_News_VerticalNovelInfoListItem'))
            .padding({ bottom: 4 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .height('40%')
            .width(CommonConstants.FULL_PERCENT)
          List() {
            ForEach(this.tagTextList, (item: string, index: number) => {
              ListItem() {
                Row() {
                  Text(item)
                    .height(18)
                    .textAlign(TextAlign.Center)
                    .fontSize($r('app.integer.caption_text_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.tag_font_color_News_VerticalNovelInfoListItem'))
                    .borderRadius($r('sys.float.corner_radius_level2'))
                    .padding({ left: 3, right: 3 })
                  if (index < this.tagTextList.length - 1) {
                    Divider()
                      .vertical(true)
                      .height(14)
                      .width(1.5)
                      .margin({ left: 5, right: 5 })
                      .color($r('sys.color.comp_divider'))
                  }
                }
              }
            })
          }
          .height('20%')
          .scrollBar(BarState.Off)
          .listDirection(Axis.Horizontal)
        }
        .padding({ right: 8 })
        .width('70%')
        .height('80%')
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .borderRadius($r('sys.float.corner_radius_level8'))
      .backgroundColor($r('app.color.comp_background_primary_trans'))
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .margin({ bottom: "8px" })
  }
}

@Component
export struct ColumnRecommendationModuleTitleInfo {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  public title: string = '';
  public moduleRedirectContent: string = "查看更多专栏";
  @Consume('pathStack') pathStack: NavPathStack;
  public onJump?: () => void;

  jump(): void {
    this.pathStack.pushPathByName('EmptyPagePathStack', null);
  }

  build() {
    if (this.title.length) {
      Row() {
        Text(this.title)
          .fontSize($r('app.integer.subtitle_text_L'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.font_primary'))
        Text(this.moduleRedirectContent)
          .fontColor($r('app.color.font_secondary'))
          .fontSize($r('app.integer.body_text_S'))
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            if (this.onJump) {
              this.onJump()
            } else {
              this.jump()
            }
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height("44vp")
      .justifyContent(FlexAlign.SpaceBetween)
      .borderRadius($r('sys.float.corner_radius_level8'))
    }
  }
}