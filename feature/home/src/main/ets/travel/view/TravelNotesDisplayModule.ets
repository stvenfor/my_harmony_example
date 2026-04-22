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
import { CommonConstants } from '../common/CommonConstants';
import { BreakpointType } from '../util/BreakpointType';
import LazyDataSource from '../util/LazyDataSource';
import {
  DataSource, Data
} from '../viewmodel/TravelNotesDisplayModuleData';

@Component
export struct TravelNotesDisplayModule {
  @State itemModel: Data =
    Data.getInstance();
  @State lazyDataSource: LazyDataSource<DataSource> =
    this.itemModel.lazyDataSource;
  @State moduleTitle: string = "旅游攻略";
  @State moduleRedirectContent: string = "查看更多攻略";
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @Consume('pathStack') pathStack: NavPathStack;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
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
      TravelNotesDisplayModuleTitleInfo({
        title: this.moduleTitle,
        moduleRedirectContent: this.moduleRedirectContent,
        onJump: () => {
          this.jump()
        }
      })
        .width('92%')
      if (this.loadingStatus === LoadingStatus.FAILED) {
        LoadingFailedView(() => this.loadResources())
      } else if (this.loadingStatus === LoadingStatus.SUCCESS) {
        WaterFlow() {
          LazyForEach(this.lazyDataSource, (item: DataSource, index: number) => {
            FlowItem() {
              VerticalGraphicTextShareItem({
                image: item.getImage(),
                title: item.getTitle(),
                avatar: item.getAvatar(),
                name: item.getName(),
                favorImage: item.getFavorImage(),
                favorCounts: item.getFavorCounts()
              })
            }
            .onClick(() => {
              this.jump("TravelNotesDisplayModuleDetail" + index.toString())
            })
            .width(CommonConstants.FULL_PERCENT)
          }, (item: DataSource, index: number) => index + JSON.stringify(item))
        }
        .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
        .cachedCount(4)
        .columnsTemplate(("1fr ").repeat(new BreakpointType(this.columnNumberArray[0], this.columnNumberArray[1],
          this.columnNumberArray[2]).getValue(this.currentWidthBreakpoint)).trim())
        .columnsGap(8)
        .rowsGap(8)
        .width('92%')
      }
    }
    .width('100%')
    .margin({ bottom: "10vp" })
  }
}

@Component
export struct VerticalGraphicTextShareItem {
  @State image: Resource = $r('app.media.goodsImg')
  @State title: string = '出差多怎么选信用卡'
  @State avatar: Resource = $r('app.media.icon')
  @State name: string = '用户'
  @State favorImage: Resource = $r('app.media.ic_public_favor_black')
  @State favorCounts: number = 123
  @State count: number = 0

  build() {
    Column() {
      Image(this.image)
        .width(CommonConstants.FULL_PERCENT)
        .borderRadius({ topLeft: $r('sys.float.corner_radius_level4'), topRight: $r('sys.float.corner_radius_level4') })
      Text(this.title)
        .width(CommonConstants.FULL_PERCENT)
        .textAlign(TextAlign.Start)
        .padding(6)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.font_primary'))
      Row() {
        Row() {
          Image(this.avatar)
            .height(CommonConstants.FULL_PERCENT)
            .borderRadius($r('sys.float.corner_radius_level12'))
          Text(this.name)
            .height(CommonConstants.FULL_PERCENT)
            .textAlign(TextAlign.Start)
            .padding({ left: 4 })
            .fontSize(12)
            .fontColor($r('app.color.content_sub_title_font_color'))
        }
        .width('70%')
        .height(CommonConstants.FULL_PERCENT)

        Row() {
          Image(this.favorImage)
            .height(CommonConstants.FULL_PERCENT)
            .onClick(() => {
              if (this.count === 0) {
                this.favorCounts++
                this.count++
              }
            })
            .fillColor(this.count === 0 ? $r('app.color.module_icon_color') :
              $r('app.color.favor_active_WaterFlow_VerticalGraphicTextShareItem'))
          Text(`${this.favorCounts}`)
            .height('90%')
            .margin({ left: 4 })
            .fontSize(12)
            .fontColor($r('app.color.content_sub_title_font_color'))
        }
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(25)
      .padding(6)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .backgroundColor($r('app.color.background_primary'))
    .borderRadius($r('sys.float.corner_radius_level4'))
  }
}

@Component
export struct TravelNotesDisplayModuleTitleInfo {
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  public title: string = '';
  public moduleRedirectContent: string = "查看更多攻略";
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