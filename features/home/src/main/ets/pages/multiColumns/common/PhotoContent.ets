import { BreakpointConstants, BreakPointType, StringConstants } from '@ohos/common'
import { mcGetBottom, mcGetLeft, mcGetRight, mcGetTop } from '../MultiColumnsSafeArea'
/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { LengthMetrics } from '@kit.ArkUI';
import { photoType } from '../model/MultiColumnsDataType';

@Component
export struct PhotoContent {
  @State photoList: photoType[] = [
    new photoType($r('app.string.picture'), 1234, $r('app.media.P1')),
    new photoType($r('app.string.video'), 12, $r('app.media.P2')),
    new photoType($r('app.string.collect'), 7, $r('app.media.P3')),
    new photoType($r('app.string.newAlbum'), 11, $r('app.media.P4')),
    new photoType($r('app.string.avatar'), 223, $r('app.media.P5')),
    new photoType($r('app.string.address'), 125, $r('app.media.P6')),
    new photoType($r('app.string.category'), 234, $r('app.media.P7')),
    new photoType($r('app.string.pictureType'), 22, $r('app.media.P8'))
  ];
  @State columnsTemplate: string = '1fr 1fr 1fr';
  @Link @Watch('onStateChange') sideBarStatus: boolean;
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD;

  aboutToAppear() {
    this.columnsTemplate = this.breakPoint === BreakpointConstants.BREAKPOINT_SM ? '1fr 1fr 1fr 1fr' : '1fr 1fr 1fr';
  }

  onStateChange() {
    this.getUIContext().animateTo({ duration: 300 }, () => {
      if (this.sideBarStatus === true && this.breakPoint !== BreakpointConstants.BREAKPOINT_SM) {
        this.columnsTemplate = '1fr 1fr 1fr';
      } else {
        this.columnsTemplate = '1fr 1fr 1fr 1fr';
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.album'))
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ left: this.sideBarStatus ? 0 : 36 })
        Blank()
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontColor([$r('sys.color.icon_primary')])
            .fontSize($r('sys.float.Title_M'))
        }
        .height(40)
        .aspectRatio(1)
        .backgroundColor($r('sys.color.comp_background_tertiary'))

        Blank()
          .width(16)
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
            .fontColor([$r('sys.color.icon_primary')])
            .fontSize($r('sys.float.Title_M'))
        }
        .height(40)
        .aspectRatio(1)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .width('100%')
      .height(56)

      Grid() {
        ForEach(this.photoList, (item: photoType) => {
          GridItem() {
            Column() {
              Image(item.src)
                .width('100%')
                .aspectRatio(1)
                .borderRadius(12)
              Column() {
                Text(item.name)
                  .fontSize(14)
                  .fontWeight(FontWeight.Regular)
                  .margin({ top: 8 })
                Text(item.count.toString())
                  .fontSize(12)
                  .fontWeight(FontWeight.Regular)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .padding({ left: 8, right: 8 })
            }
          }
        })
      }
      .scrollBar(BarState.Off)
      .columnsTemplate(this.columnsTemplate)
      .columnsGap(22)
      .rowsGap(17)
      .margin({ top: 7 })
      .padding({
        bottom: AppStorage.get<number>(StringConstants.BOTTOM_AREA) as number + 48
      })
    }
    .padding({
      right: this.getUIContext().px2vp(mcGetRight()),
      left: this.columnsTemplate === '1fr 1fr 1fr 1fr' ? this.getUIContext().px2vp(mcGetLeft()) : 0
    })
    .margin({
      left: 24,
      right: 18,
      top: AppStorage.get<number>(StringConstants.TOP_AREA)
    })
  }
}