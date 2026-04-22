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
import { DataSource, Data } from '../viewmodel/PromotionCarouselModuleData';
import { LoadingStatus } from '../common/CommonEnums';
import LazyDataSource from '../util/LazyDataSource';
import { LoadingFailedView } from '../view/LoadingFailedView';
import { BreakpointType } from '../util/BreakpointType';
import { BreakpointConstants } from '../common/BreakpointConstants';
import { CommonConstants } from '../common/CommonConstants';

@Component
export struct PromotionCarouselModule {
  @State itemModel: Data =
    Data.getInstance();
  @State lazyDataSource: LazyDataSource<DataSource> =
    this.itemModel.lazyDataSource;
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  private displayCountArray: number[] = [1, 2, 3];
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
        if (this.loadingStatus === LoadingStatus.FAILED) {
          LoadingFailedView(() => this.loadResources())
        }
        if (this.loadingStatus === LoadingStatus.SUCCESS) {
          Swiper() {
            LazyForEach(this.lazyDataSource, (item: DataSource, index: number) => {
              PureImageItem({
                image: item.getImage()
              }).onClick(() => {
                this.jump("PromotionCarouselModuleDetail" + index.toString())
              })
            }, (item: DataSource) => JSON.stringify(item))
          }
          .displayCount(new BreakpointType(this.displayCountArray[0], this.displayCountArray[1],
            this.displayCountArray[2]).getValue(this.currentWidthBreakpoint))
          .indicator(false)
          .height("150vp")
          .width(CommonConstants.FULL_PERCENT)
          .itemSpace(4)
        }
      }
      .height('auto')
      .width("92%")
      .borderRadius($r('sys.float.corner_radius_level4'))
      .margin({ bottom: "10vp" })
    }
    .width("100%")
  }
}

@Component
export struct PureImageItem {
  @State image: Resource = $r('app.media.noImage')

  build() {
    Column() {
      Image(this.image)
        .borderRadius($r('sys.float.corner_radius_level4'))
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .borderRadius($r('sys.float.corner_radius_level4'))
  }
}