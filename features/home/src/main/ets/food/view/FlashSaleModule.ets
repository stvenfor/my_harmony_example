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
import LazyDataSource from '../util/LazyDataSource';
import {
  DataSource, DataSourceStyleAStyleA
} from '../viewmodel/FlashSaleModuleData';

@Component
export struct FlashSaleModule {
  @State itemModel: DataSourceStyleAStyleA =
    DataSourceStyleAStyleA.getInstance();
  @State lazyDataSource: LazyDataSource<DataSource> =
    this.itemModel.lazyDataSource;
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @State moduleTitle: string = "限时抢购";
  @State moduleRedirectContent: string = "查看更多";
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_SM;
  @Consume('pathStack') pathStack: NavPathStack;

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
      FlashSaleModuleTitleInfo({
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
              VerticalGraphicTextShareItem({
                image: item.getImage(),
                title: item.getTitle(),
                subtitle: item.getSubtitle(),
                priceLabel: item.getPriceLabel(),
                originalPrice: item.getOriginalPrice(),
                tag: item.getTag(),
                stockInfo: item.getStockInfo(),
                limit: item.getLimit()
              })
            }
            .width(CommonConstants.FULL_PERCENT)
            .onClick(() => this.jump("FlashSaleModuleDetail" + index.toString()))
          }, (item: DataSource, index: number) => index + JSON.stringify(item))
        }
        .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
        .columnsTemplate('1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
        .width(CommonConstants.FULL_PERCENT)
      }
    }
    .width('92%')
    .margin({ bottom: 10 })
  }
}

@Component
struct VerticalGraphicTextShareItem {
  @State image: Resource = $r('app.media.recommend1')
  @State title: string = ''
  @State subtitle: string = ''
  @State priceLabel: string = ''
  @State originalPrice: string = ''
  @State tag: string = ''
  @State stockInfo: string = ''
  @State limit: string = ''

  build() {
    Column() {
      Stack({ alignContent: Alignment.TopStart }) {
        Image(this.image)
          .width(CommonConstants.FULL_PERCENT)
          .aspectRatio(Math.random() * 0.4 + 0.8)
          .borderRadius({
            topLeft: $r('sys.float.corner_radius_level8'),
            topRight: $r('sys.float.corner_radius_level8')
          })
        if (this.tag) {
          Text(this.tag)
            .fontSize($r('app.integer.body_text_S'))
            .fontColor($r('app.color.font_on_primary'))
            .backgroundColor($r('app.color.comp_background_emphasize'))
            .padding({
              left: 8,
              right: 8,
              top: 4,
              bottom: 4
            })
            .margin(8)
            .borderRadius($r('sys.float.corner_radius_level4'))
        }
      }

      Column() {
        Text(this.title)
          .fontSize($r('app.integer.subtitle_text_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_primary'))
          .width(CommonConstants.FULL_PERCENT)
          .textAlign(TextAlign.Start)
        Text(this.subtitle)
          .fontSize($r('app.integer.body_text_S'))
          .fontColor($r('app.color.font_secondary'))
          .fontWeight(FontWeight.Regular)
          .width(CommonConstants.FULL_PERCENT)
          .textAlign(TextAlign.Start)
          .margin({ top: 4 })
        Row() {
          Text(this.priceLabel)
            .fontSize($r('app.integer.subtitle_text_M'))
            .fontColor($r('app.color.price_primary_Waterflow_ShoppingList1'))
            .fontWeight(FontWeight.Bold)
          if (this.originalPrice) {
            Text(this.originalPrice)
              .fontSize($r('app.integer.body_text_S'))
              .fontColor($r('app.color.font_tertiary'))
              .fontWeight(FontWeight.Regular)
              .decoration({ type: TextDecorationType.LineThrough, color: $r('app.color.font_tertiary') })
              .margin({ left: 4 })
          }
        }
        .margin({ top: 4 })

        Row() {
          Text(this.stockInfo)
            .fontSize($r('app.integer.body_text_S'))
            .fontColor($r('app.color.font_tertiary'))
            .fontWeight(FontWeight.Regular)
          if (this.limit) {
            Text(this.limit)
              .fontSize($r('app.integer.body_text_S'))
              .fontColor($r('app.color.font_tertiary'))
              .fontWeight(FontWeight.Regular)
              .margin({ left: 8 })
          }
        }
        .margin({ top: 4 })
      }
      .width(CommonConstants.FULL_PERCENT)
      .padding(8)
      .alignItems(HorizontalAlign.Start)
    }
    .width(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.comp_background_primary_trans'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}

@Component
export struct FlashSaleModuleTitleInfo {
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_LG;
  public title: string = '';
  public moduleRedirectContent: string = "查看更多";
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