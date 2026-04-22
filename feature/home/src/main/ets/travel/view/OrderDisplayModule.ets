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
import {
  DataSource, Data
} from '../viewmodel/OrderDisplayModuleData';

@Component
export struct OrderDisplayModule {
  @State titles: string[] = ['全部订单', '待支付', '进行中', '已完成'];
  @State currentIndex: number = 0;

  @Builder
  TabBuilder(index: number, title: string) {
    Column() {
      Text(title)
        .width(CommonConstants.FULL_PERCENT)
        .height('95%')
        .fontSize($r('app.integer.subtitle_text_S'))
        .fontColor(this.currentIndex === index ? $r('app.color.font_emphasize') : $r('app.color.font_secondary'))
        .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Medium)
        .backgroundColor(this.currentIndex === index ? $r('app.color.comp_background_primary_trans') :
          $r('app.color.comp_background_primary_trans'))
        .textAlign(TextAlign.Center)
      if (this.currentIndex === index) {
        Line()
          .width('20%')
          .height(2)
          .backgroundColor($r('app.color.comp_background_emphasize'))
      }
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor($r('app.color.comp_background_primary_trans'))
  }

  build() {
    Column() {
      Text("订单")
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .backgroundColor($r('app.color.comp_background_primary_trans'))
        .textAlign(TextAlign.Center)
        .padding({ top: 10, bottom: 10 })
      Tabs() {
        TabContent() {
          List_Orders()
        }
        .tabBar(this.TabBuilder(0, this.titles[0]))

        TabContent() {
        }
        .tabBar(this.TabBuilder(1, this.titles[1]))

        TabContent() {
        }
        .tabBar(this.TabBuilder(2, this.titles[2]))
      }
      .width('auto')
      .height('auto')
      .scrollable(true)
      .barPosition(BarPosition.Start)
      .vertical(false)
      .barWidth(CommonConstants.FULL_PERCENT)
      .barHeight(40)
      .barBackgroundColor($r('app.color.tabs_background_Tab_List_OrderList'))
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
    .width('100%')
    .height('100%')
    .margin({ bottom: "10vp" })
  }
}

@Component
export struct List_Orders {
  @State itemModel: Data =
    Data.getInstance();
  @Prop listDirection: Axis = Axis.Vertical
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @State lazyDataSource: LazyDataSource<DataSource> =
    this.itemModel.lazyDataSource;
  private spaceArray: string[] = ['0vp', '16vp', '20vp'];
  private lanesArray: number[] = [1, 3, 4];
  @Consume('pathStack') pathStack: NavPathStack;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;

  jump(pageName: string = 'EmptyPagePathStack'): void {
    this.pathStack.pushPathByName(pageName, null);
  }

  aboutToAppear() {
    this.loadResources();
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
              SimpleOrderInformationDisplayModule({
                price: item.getPrice(),
                title: item.getTitle(),
                orderTime: item.getOrderTime(),
                orderStatus: item.getOrderStatus()
              })
            }
            .width('100%')
            .backgroundColor($r('app.color.comp_background_gray'))
            .onClick(() => {
              this.jump("List_OrdersDetail" + index.toString())
            })
          }, (item: DataSource, index: number) => index + JSON.stringify(item))
        }
        .width('100%')
        .height('90%')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .margin({ top: 8 })
        .listDirection(this.listDirection)
        .lanes(new BreakpointType(this.lanesArray[0], this.lanesArray[1],
          this.lanesArray[2]).getValue(this.currentWidthBreakpoint), "12vp")
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Component
export struct SimpleOrderInformationDisplayModule {
  @State price: string = "1,049";
  @State orderStatus: string = "已完成";
  @State title: string = "宝山万达店";
  @State orderTime: string = "2025-02-16 19:24:56";
  @State function1Text: string = "查看详情";
  @State function2Text: string = "开具发票";
  @Consume('pathStack') pathStack: NavPathStack;

  jump(pageName: string = 'EmptyPagePathStack'): void {
    this.pathStack.pushPathByName(pageName, null);
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Column() {
          Text(this.title)
            .fontColor($r('app.color.font_primary'))
            .fontSize($r('app.integer.subtitle_text_M'))
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .width(CommonConstants.FULL_PERCENT)

        Row() {
          Text(this.orderTime)
            .fontColor($r('app.color.font_tertiary'))
            .fontSize($r('app.integer.body_text_S'))
            .fontWeight('Regular')
          Row() {
            Text('¥')
              .fontColor($r('app.color.font_primary'))
              .fontSize($r('app.integer.body_text_S'))
              .fontWeight('Regular')
              .alignSelf(ItemAlign.End)
              .margin({ bottom: 2 })
            Text(this.price)
              .fontColor($r('app.color.font_primary'))
              .fontSize($r('app.integer.subtitle_text_L'))
              .fontWeight(FontWeight.Bold)
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 16 })

        Row() {
          Blank()
          Button(this.function1Text)
            .height(32)
            .borderRadius($r('sys.float.corner_radius_level4'))
            .controlSize(ControlSize.SMALL)
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor(Color.Transparent)
            .border({ width: 1, color: $r('app.color.comp_background_secondary'), style: BorderStyle.Solid })
            .margin({ right: 12 })
            .padding({ left: 12, right: 12 })
            .onClick(() => {
              this.jump()
            })
          Button(this.function2Text)
            .height(32)
            .borderRadius($r('sys.float.corner_radius_level4'))
            .controlSize(ControlSize.SMALL)
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor(Color.Transparent)
            .border({ width: 1, color: $r('app.color.comp_background_secondary'), style: BorderStyle.Solid })
            .padding({ left: 12, right: 12 })
            .onClick(() => {
              this.jump()
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .padding({
        top: 16,
        bottom: 16,
        left: 16,
        right: 16
      })

      Text(this.orderStatus)
        .fontColor($r('app.color.font_emphasize'))
        .fontSize($r('app.integer.body_text_S'))
        .fontWeight('Regular')
        .backgroundColor($r('app.color.comp_emphasize_secondary'))
        .borderRadius({
          topRight: $r('sys.float.corner_radius_level8'),
          bottomLeft: $r('sys.float.corner_radius_level8')
        })
        .padding({
          left: 8,
          right: 8,
          top: 4,
          bottom: 4
        })
        .margin({ top: 0, right: 0 })
    }
    .width('92%')
    .margin({ bottom: 8 })
    .backgroundColor($r('app.color.comp_background_primary_trans'))
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}