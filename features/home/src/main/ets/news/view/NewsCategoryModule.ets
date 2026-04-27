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
  DataSource, DataSourceStyleAStyleA
} from '../viewmodel/NewsCategoryModuleData';
import { LoadingStatus } from '../common/CommonEnums';
import { LoadingFailedView } from '../view/LoadingFailedView';
import { BreakpointConstants } from '../common/BreakpointConstants';
import { BreakpointType } from '../util/BreakpointType';
import LazyDataSource from '../util/LazyDataSource';
import { CommonConstants } from '../common/CommonConstants';

@Component
export struct NewsCategoryModule {
  @State titles: string[] = ['财经', '科技', '体育'];
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  @State moduleTitle: string = "新闻专栏";
  @State moduleRedirectContent: string = "查看更多";
  @Consume('pathStack') pathStack: NavPathStack;

  jump(pageName: string = 'EmptyPagePathStack'): void {
    this.pathStack.pushPathByName(pageName, null);
  }

  @Builder
  TabBuilder(index: number, title: string) {
    Text(title)
      .fontSize($r('app.integer.subtitle_text_S'))
      .fontColor(this.currentIndex === index ? $r('app.color.font_emphasize') : $r('app.color.font_secondary'))
      .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Medium)
      .backgroundColor(this.currentIndex === index ? $r('app.color.comp_background_gray') :
        $r('app.color.comp_background_primary_trans'))
      .padding({
        top: 6,
        bottom: 6,
        left: 12,
        right: 12
      })
      .borderRadius($r('sys.float.corner_radius_level8'))
  }

  build() {
    Column() {
      NewsCategoryModuleTitleInfo({
        title: this.moduleTitle,
        moduleRedirectContent: this.moduleRedirectContent,
        onJump: () => {
          this.jump()
        }
      })
      Tabs() {
        TabContent() {
          List_HorizontalGraphicTextFunctionItem2_1()
        }
        .tabBar(this.TabBuilder(0, this.titles[0]))

        TabContent() {
          List_HorizontalGraphicTextFunctionItem2_2()
        }
        .tabBar(this.TabBuilder(1, this.titles[1]))

        TabContent() {
          List_HorizontalGraphicTextFunctionItem2_3()
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
      .backgroundColor($r('app.color.comp_background_primary_trans'))
      .borderRadius($r('sys.float.corner_radius_level8'))
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
    .width('92%')
    .borderRadius($r('sys.float.corner_radius_level8'))
    .margin({ bottom: "10vp" })
  }
}

@Component
export struct List_HorizontalGraphicTextFunctionItem2_1 {
  @State itemModel: DataSourceStyleAStyleA =
    DataSourceStyleAStyleA.getInstance();
  @Prop listDirection: Axis = Axis.Vertical
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @State lazyDataSource: LazyDataSource<DataSource> =
    this.itemModel.lazyDataSource1;
  private spaceArray: string[] = ['12vp', '16vp', '20vp'];
  @Consume('pathStack') pathStack: NavPathStack;
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_SM;

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
            this.spaceArray[2]).getValue(this.breakPoint)
        }) {
          LazyForEach(this.lazyDataSource, (item: DataSource, index: number) => {
            ListItem() {
              HorizontalGraphicTextFunctionItem2({
                icon: item.getIcon(),
                title: item.getTitle(),
                description: item.getDescription()
              })
            }
            .width(CommonConstants.FULL_PERCENT)
            .height('80vp')
            .onClick(() => {
              this.jump("List_HorizontalGraphicTextFunctionItem2_1Detail" + index.toString())
            })
            .borderRadius($r('sys.float.corner_radius_level8'))
            .backgroundColor($r('app.color.comp_background_primary_trans'))
          }, (item: DataSource, index: number) => index + JSON.stringify(item))
        }
        .width('auto')
        .height('auto')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .listDirection(this.listDirection)
        .divider({ "strokeWidth": 1 })
      }
    }
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('app.color.comp_background_primary_trans'))
    .padding(8)
  }
}

@Component
export struct List_HorizontalGraphicTextFunctionItem2_2 {
  @State itemModel: DataSourceStyleAStyleA =
    DataSourceStyleAStyleA.getInstance();
  @Prop listDirection: Axis = Axis.Vertical
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @State lazyDataSource: LazyDataSource<DataSource> =
    this.itemModel.lazyDataSource2;
  private spaceArray: string[] = ['12vp', '16vp', '20vp'];
  @Consume('pathStack') pathStack: NavPathStack;
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_SM;

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
            this.spaceArray[2]).getValue(this.breakPoint)
        }) {
          LazyForEach(this.lazyDataSource, (item: DataSource, index: number) => {
            ListItem() {
              HorizontalGraphicTextFunctionItem2({
                icon: item.getIcon(),
                title: item.getTitle(),
                description: item.getDescription()
              })
            }
            .width(CommonConstants.FULL_PERCENT)
            .height('80vp')
            .onClick(() => {
              this.jump("List_HorizontalGraphicTextFunctionItem2_2Detail" + index.toString())
            })
            .borderRadius($r('sys.float.corner_radius_level8'))
            .backgroundColor($r('app.color.comp_background_primary_trans'))
          }, (item: DataSource, index: number) => index + JSON.stringify(item))
        }
        .width('auto')
        .height('auto')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .listDirection(this.listDirection)
        .divider({ "strokeWidth": 1 })
      }
    }
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('app.color.comp_background_primary_trans'))
    .padding(8)
  }
}

@Component
export struct List_HorizontalGraphicTextFunctionItem2_3 {
  @State itemModel: DataSourceStyleAStyleA =
    DataSourceStyleAStyleA.getInstance();
  @Prop listDirection: Axis = Axis.Vertical
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @State lazyDataSource: LazyDataSource<DataSource> =
    this.itemModel.lazyDataSource3;
  private spaceArray: string[] = ['12vp', '16vp', '20vp'];
  @Consume('pathStack') pathStack: NavPathStack;
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_SM;

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
            this.spaceArray[2]).getValue(this.breakPoint)
        }) {
          LazyForEach(this.lazyDataSource, (item: DataSource, index: number) => {
            ListItem() {
              HorizontalGraphicTextFunctionItem2({
                icon: item.getIcon(),
                title: item.getTitle(),
                description: item.getDescription()
              })
            }
            .width(CommonConstants.FULL_PERCENT)
            .height('80vp')
            .onClick(() => {
              this.jump("List_HorizontalGraphicTextFunctionItem2_3Detail" + index.toString())
            })
            .borderRadius($r('sys.float.corner_radius_level8'))
            .backgroundColor($r('app.color.comp_background_primary_trans'))
          }, (item: DataSource, index: number) => index + JSON.stringify(item))
        }
        .width('auto')
        .height('auto')
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .listDirection(this.listDirection)
        .divider({ "strokeWidth": 1 })
      }
    }
    .borderRadius($r('sys.float.corner_radius_level8'))
    .backgroundColor($r('app.color.comp_background_primary_trans'))
    .padding(8)
  }
}

@Component
export struct HorizontalGraphicTextFunctionItem2 {
  @State title: string = '模块名';
  @State description: string = '跳转';
  @State icon: Resource = $r("app.media.ic_public_app");

  build() {
    Row() {
      Column() {
        Text(this.title)
          .width(CommonConstants.FULL_PERCENT)
          .fontColor($r('app.color.font_primary'))
          .fontSize($r('app.integer.subtitle_text_M'))
          .fontWeight(FontWeight.Medium)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
        Text(this.description)
          .fontColor($r('app.color.font_tertiary'))
          .fontSize($r('app.integer.body_text_S'))
          .fontWeight(FontWeight.Regular)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(2)
          .padding({ top: 12 })
      }
      .width('60%')
      .height('80%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 6 })

      Image(this.icon)
        .width('30%')
        .fillColor($r('app.color.comp_emphasize_secondary'))
        .borderRadius($r('sys.float.corner_radius_level8'))
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius($r('sys.float.corner_radius_level8'))
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }
}

@Component
export struct NewsCategoryModuleTitleInfo {
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