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
import { LoadingStatus } from '../common/CommonEnums';
import { LoadingFailedView } from '../view/LoadingFailedView';
import { BreakpointConstants } from '../common/BreakpointConstants';
import { BreakpointType } from '../util/BreakpointType';
import LazyDataSource from '../util/LazyDataSource';
import { CommonConstants } from '../common/CommonConstants';
import { DataSource, Data } from '../viewmodel/HotEventTimelineModuleData';

@Component
export struct HotEventTimelineModule {
  @State itemModel: Data =
    Data.getInstance();
  @Prop listDirection: Axis = Axis.Vertical
  @State moduleTitle: string = "热点时间轴";
  @State moduleRedirectContent: string = "查看更多";
  @State times: string[] = []
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @State lazyDataSource: LazyDataSource<DataSource> =
    this.itemModel.lazyDataSource;
  private spaceArray: string[] = ['8vp', '6vp', '10vp'];
  private lanesArray: number[] = [1, 2, 3];
  @Consume('pathStack') pathStack: NavPathStack;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;

  aboutToAppear() {
    this.loadResources();
    for (let index = 0; index < this.lazyDataSource.getDataList().length; index++) {
      this.times.push(this.lazyDataSource.getDataList()[index].getTime())
    }
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
      NewsHotEventTimelineModuleTitleInfo({
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
        List() {
          LazyForEach(this.lazyDataSource, (item: DataSource, index: number) => {
            ListItem() {
              Row() {
                Stack() {
                  Divider()
                    .width(2)
                    .height(CommonConstants.FULL_PERCENT)
                    .backgroundColor($r('app.color.divider_primary_List_XinLangNews'))
                  Text()
                    .width(6)
                    .height(6)
                    .borderRadius(3)
                    .backgroundColor(index === 0 ? $r('app.color.brand_primary_List_XinLangNews') :
                      $r('app.color.page_bg_color'))
                    .borderWidth(1)
                    .borderColor($r('app.color.brand_primary_List_XinLangNews'))
                    .position({ top: 3, left: '41%' })
                }
                .width('10%')

                Column({
                  space: new BreakpointType(this.spaceArray[0], this.spaceArray[1],
                    this.spaceArray[2]).getValue(this.currentWidthBreakpoint)
                }) {
                  Text(this.times[index])
                    .fontSize($r('app.integer.caption_text_M'))
                    .fontColor(index === 0 ? $r('app.color.font_tertiary_red_List_XinLangNews') :
                      $r('app.color.font_tertiary_List_XinLangNews'))
                    .fontWeight(FontWeight.Medium)
                  HorizontalGraphicTextNewsItem({
                    image: item.getImage(),
                    descriptionText: item.getDescriptionText()
                  })
                }
                .width('90%')
                .alignItems(HorizontalAlign.Start)
                .padding({ bottom: 8 })
              }
              .width('auto')
              .height('auto')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .height(108)
            .borderRadius($r('sys.float.corner_radius_level4'))
            .onClick(() => {
              this.jump("HotEventTimelineModuleDetail" + index.toString())
            })
          }, (item: DataSource, index: number) => index + JSON.stringify(item))
        }
        .width('auto')
        .height('auto')
        .listDirection(this.listDirection)
        .lanes(new BreakpointType(this.lanesArray[0], this.lanesArray[1],
          this.lanesArray[2]).getValue(this.currentWidthBreakpoint), "12vp")
      }
    }
    .width('92%')
    .height('auto')
    .alignItems(HorizontalAlign.End)
    .margin({ bottom: "10vp" })
  }
}

@Component
export struct HorizontalGraphicTextNewsItem {
  @State image: Resource = $r('app.media.noImage');
  @State descriptionText: string = '这是一个描述文本，用于展示一些详细信息。';

  build() {
    Row() {
      Text(this.descriptionText)
        .width('65%')
        .height('80%')
        .fontSize($r('app.integer.body_text_S'))
        .fontColor($r('app.color.font_primary'))
        .fontWeight(FontWeight.Regular)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Image(this.image)
        .width('30%')
        .height(CommonConstants.FULL_PERCENT)
        .borderRadius($r('sys.float.corner_radius_level4'))
    }
    .height(80)
    .width(CommonConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius($r('sys.float.corner_radius_level4'))
    .backgroundColor($r('app.color.comp_background_primary'))
    .padding(6)
  }
}

@Component
export struct NewsHotEventTimelineModuleTitleInfo {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  public title: string = '';
  public moduleRedirectContent: string = "查看更多";
  @Consume('pathStack') pathStack: NavPathStack;

  jump(pageName: string = 'EmptyPagePathStack'): void {
    this.pathStack.pushPathByName(pageName, null);
  }

  public onJump?: () => void;

  build() {
    if (this.title.length) {
      Row() {
        Text(this.title)
          .fontSize($r('app.integer.subtitle_text_M'))
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