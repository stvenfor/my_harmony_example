import { DataSource, Data } from '../viewmodel/ActiveTabContentModuleData';
import { CommonConstants } from '../common/CommonConstants';
import { BreakpointConstants } from '../common/BreakpointConstants';

@Component
struct VerticalExamItem {
  @Prop item: DataSource;
  @Consume('pathStack') pathStack: NavPathStack;

  jump(pageName: string = 'EmptyPagePathStack'): void {
    this.pathStack.pushPathByName(pageName, null);
  }

  build() {
    Row() {
      Column() {
        Text(`${this.item.getSchoolYear()} • ${this.item.getGradeInfo()}`)
          .fontSize(12)
          .fontColor($r('app.color.font_secondary_List_VerticalExamItem'))
          .width('100%')
          .margin({ top: 8, bottom: 8 })
        Text(this.item.getTitle())
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.font_primary_List_VerticalExamItem'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })
          .width('100%')
      }
      .width('90%')

      Image($r('app.media.ic_right_arrow_filled'))
        .width(16)
        .height(16)
        .onClick(() => {
          this.jump();
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16 })
    .backgroundColor($r('app.color.background_card_List_VerticalExamItem'))
    .width('100%')
  }
}

@Component
export struct ActiveTabContentModule {
  @State model: Data = new Data();
  @State moduleTitle: string = "考试真题";
  @State moduleRedirectContent: string = '';
  @Consume('pathStack') pathStack: NavPathStack;

  jump(pageName: string = 'EmptyPagePathStack'): void {
    this.pathStack.pushPathByName(pageName, null);
  }

  build() {
    Column() {
      ActiveTabContentModuleTitleInfo({
        title: this.moduleTitle,
        moduleRedirectContent: this.moduleRedirectContent,
        onJump: () => {
          this.jump()
        }
      }).width('92%')
      List() {
        ForEach(this.model.getTextbooks(), (item: DataSource) => {
          ListItem() {
            VerticalExamItem({ item: item })
          }
        }, (item: DataSource) => item.getId())
      }
      .width('100%')
      .divider({ strokeWidth: 0 })
    }
    .width('100%')
    .backgroundColor($r('app.color.background_page_List_VerticalExamItem'))
    .margin({ bottom: 8 })
  }
}

@Component
export struct ActiveTabContentModuleTitleInfo {
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