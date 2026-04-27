import { DataSource, DataSourceStyleAStyleA, DataSourceStyleBStyleB } from '../viewmodel/NewsRecommendationModuleData';
import { CommonConstants } from '../common/CommonConstants';
import { BreakpointConstants } from '../common/BreakpointConstants';

@Component
struct PlaylistTypeTag {
  @Prop type: DataSourceStyleBStyleB;

  build() {
    Text(this.type)
      .fontSize(12)
      .fontColor($r('app.color.text_on_accent_News_H_PodcastList'))
      .backgroundColor(this.type === DataSourceStyleBStyleB.AUDIO ? $r('app.color.accent_audio_News_H_PodcastList') :
        $r('app.color.accent_other_News_H_PodcastList'))
      .padding({
        left: 8,
        right: 8,
        top: 4,
        bottom: 4
      })
      .borderRadius({
        topLeft: 12,
        topRight: 0,
        bottomLeft: 0,
        bottomRight: 12
      })
  }
}

@Component
struct PlaylistCard {
  @Prop playlist: DataSourceStyleAStyleA;

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(this.playlist.getCover())
          .width(240)
          .height(120)
          .borderRadius(16)
          .objectFit(ImageFit.Cover)
        PlaylistTypeTag({ type: this.playlist.getType() })
      }
      .width('100%')

      Text(this.playlist.getTitle())
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .margin({ top: 8 })
    }
    .width(240)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct NewsRecommendationModule {
  @State model: DataSource = new DataSource();
  @Consume('pathStack') pathStack: NavPathStack;
  @State moduleTitle: string = "新闻专栏";
  @State moduleRedirectContent: string = "跳转";

  jump(pageName: string = 'EmptyPagePathStack'): void {
    this.pathStack.pushPathByName(pageName, null);
  }

  build() {
    Column() {
      NewsRecommendationModuleTitleInfo({
        title: this.moduleTitle,
        moduleRedirectContent: this.moduleRedirectContent,
        onJump: () => {
          this.jump()
        }
      })
        .width('92%')
      Scroll() {
        Row() {
          ForEach(this.model.getPlaylists(), (playlist: DataSourceStyleAStyleA, index: number) => {
            PlaylistCard({ playlist: playlist })
              .margin({ right: 12 })
          }, (playlist: DataSourceStyleAStyleA) => playlist.getId())
        }
        .height('100%')
        .alignItems(VerticalAlign.Top)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('92%')
      .height(190)
      .onClick(() => {
        this.jump()
      })
    }
    .width('100%')
  }
}

@Component
export struct NewsRecommendationModuleTitleInfo {
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_LG;
  public title: string = '';
  public moduleRedirectContent: string = '';
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