/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/
import {
  DataSource, Data
} from '../viewmodel/CourseListModuleData';
import { LoadingStatus } from '../common/CommonEnums';
import { LoadingFailedView } from '../view/LoadingFailedView';
import { BreakpointConstants } from '../common/BreakpointConstants';
import { CommonConstants } from '../common/CommonConstants';
import { BreakpointType } from '../util/BreakpointType';
import LazyDataSource from '../util/LazyDataSource';

@Component
export struct CourseListModule {
  @State itemModel: Data =
    Data.getInstance();
  @State lazyDataSource: LazyDataSource<DataSource> =
    this.itemModel.lazyDataSource;
  @State moduleTitle: string = "热门课程";
  @State moduleRedirectContent: string = "查看更多课程";
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @Consume('pathStack') pathStack: NavPathStack;
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_SM;
  private columnNumberArray: number[] = [2, 4, 4];

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
      CourseListModuleTitleInfo({
        title: this.moduleTitle,
        moduleRedirectContent: this.moduleRedirectContent,
        onJump: () => {
          this.jump()
        }
      })
      if (this.loadingStatus === LoadingStatus.FAILED) {
        LoadingFailedView(() => this.loadResources())
      } else if (this.loadingStatus === LoadingStatus.SUCCESS) {
        WaterFlow() {
          LazyForEach(this.lazyDataSource, (item: DataSource, index: number) => {
            FlowItem() {
              VerticalGraphicTextItem({
                image: item.getImage(),
                content: item.getContent(),
                title: item.getTitle()
              })
            }
            .onClick(() => {
              this.jump("CourseListModuleDetail" + index.toString())
            })
            .width(CommonConstants.FULL_PERCENT)
          }, (item: DataSource, index: number) => index + JSON.stringify(item))
        }
        .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
        .cachedCount(4)
        .columnsTemplate(("1fr ").repeat(new BreakpointType(this.columnNumberArray[0], this.columnNumberArray[1],
          this.columnNumberArray[2]).getValue(this.breakPoint)).trim())
        .columnsGap("8vp")
        .rowsGap("8vp")
        .width(CommonConstants.FULL_PERCENT)
      }
    }
    .width('92%')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .margin({ bottom: "10vp" })
  }
}

@Component
export struct VerticalGraphicTextItem {
  @State image: Resource = $r('app.media.noImage')
  @State title: string = '模块名';
  @State content: string = '跳转';

  build() {
    Column() {
      Image(this.image)
        .width(CommonConstants.FULL_PERCENT)
        .aspectRatio(1.78)
      Column({ space: 4 }) {
        Text(this.title)
          .textAlign(TextAlign.Start)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .fontSize(14)
          .width('100%')
        Text(this.content)
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(12)
          .maxLines(2)
          .width(CommonConstants.FULL_PERCENT)
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding(12)
    }
    .width(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.background_card_CourseGuideView'))
    .borderRadius($r('sys.float.corner_radius_level8'))
    .clip(true)
  }
}

@Component
export struct CourseListModuleTitleInfo {
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_LG;
  public title: string = '';
  public moduleRedirectContent: string = "查看更多课程";
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