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
import { OperateTabs } from '../model/MultiColumnsDataType';

@Component
export struct MailContent {
  @StorageLink('breakPoint') breakPoint: string = BreakpointConstants.BREAKPOINT_MD;
  @State buttonList: OperateTabs[] = [
    new OperateTabs($r('app.media.reply'), $r('app.string.reply')),
    new OperateTabs($r('app.media.replyAll'), $r('app.string.replyAll')),
    new OperateTabs($r('app.media.forward'), $r('app.string.send')),
    new OperateTabs($r('app.media.ic_public_delete'), $r('app.string.delete')),
    new OperateTabs($r('app.media.more'), $r('app.string.more'))
  ];

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            if (this.breakPoint === BreakpointConstants.BREAKPOINT_SM) {
              Row()
                .width(24)
                .height(24)
            } else {
              Image($r('app.media.ic_expand'))
                .width(24)
                .height(24)
            }
            Text('HHHxx UXD')
              .fontSize(20)
              .lineHeight(23)
              .margin({ left: 21 })
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .height(56)

          Row() {
            Text($r('app.string.recUser'))
              .fontSize(14)
              .fontWeight(FontWeight.Regular)
            Text($r('app.string.mailDesc'))
              .padding({ left: 12 })
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Blank()
            Image($r('app.media.right_expend_grey'))
              .width(24)
              .height(12)
              .opacity(0.8)
              .rotate({ angle: 90 })
          }
          .width('100%')
          .height(48)

          Text('PostMaster')
            .fontSize(20)
            .fontColor('#040404')
            .lineHeight(23)
          Text('09:42')
            .margin({ top: 2 })
            .fontColor('#1818a')
            .opacity(0.6)

          Scroll() {
            Column() {
              Text($r('app.string.textData'))
                .fontSize(16)
                .fontWeight(FontWeight.Regular)
                .lineHeight(25)
              Text($r('app.string.bodyTextPartOne'))
                .fontSize(16)
                .fontWeight(FontWeight.Regular)
                .lineHeight(25)
              Text('')
                .lineHeight(25)
              Image($r('app.media.orange'))
                .width('100%')
                .height(166)
                .borderRadius(10)
              Text('')
                .lineHeight(25)
              Text($r('app.string.bodyTextPartTwo'))
                .fontSize(16)
                .fontWeight(FontWeight.Regular)
                .lineHeight(25)
              Text($r('app.string.bodyTextPartThree'))
                .fontSize(16)
                .fontWeight(FontWeight.Regular)
                .lineHeight(25)
                .padding({ right: 20 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .margin({ top: 20 })
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Off)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding({
          left: 20,
          right: 20 + this.getUIContext().px2vp(mcGetRight()),
          top: 24
        })

        Row() {
          ForEach(this.buttonList, (item: OperateTabs) => {
            Column() {
              Image(item.src)
                .width(24)
                .height(24)
              Text(item.name)
                .fontSize(10)
                .margin({ top: 3 })
                .lineHeight(12)
            }
          })
        }
        .width('100%')
        .backgroundColor($r('sys.color.gray_01'))
        .height(56 + this.getUIContext().px2vp(mcGetBottom()) * 0.8)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Top)
        .padding({
          top: 6,
          right: this.breakPoint === BreakpointConstants.BREAKPOINT_SM ? 21 : 46,
          left: this.breakPoint === BreakpointConstants.BREAKPOINT_SM ? 21 : 46
        })
      }
    }
    .height('100%')
    .hideTitleBar(true)
  }
}