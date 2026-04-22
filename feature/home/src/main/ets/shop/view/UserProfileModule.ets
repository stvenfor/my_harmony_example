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
import { CommonConstants } from '../common/CommonConstants';

@Component
export struct UserProfileModule {
  @State vipIcon: Resource = $r('app.media.avatar');
  @State vipLevel: string = "黄金会员";
  @State vipFunctionIcon1: Resource = $r('app.media.vip');
  @State vipFunctionTitle1: string = "专属折扣";
  @State vipFunctionIcon2: Resource = $r('app.media.ticketmoney');
  @State vipFunctionTitle2: string = "生日特权";
  @State buttonText: string = "查看特权";
  @State slogan: string = "提高等级 享超多高价值权力";
  @State expireText: string = "有效期至";
  @State expireDate: string = "2019/07/01";
  @Consume('pathStack') pathStack: NavPathStack;

  jump(pageName: string = 'EmptyPagePathStack'): void {
    this.pathStack.pushPathByName(pageName, null);
  }

  build() {
    Column() {
      Column() {
        Row() {
          Column() {
            Row() {
              /**
               * TODO:
               * please modify it according to the actual situation.
               * modify {@link MemberInformationModule#vipIcon}
               */
              Image(this.vipIcon)
                .height("28vp")
                .width("28vp")
                .margin({ right: "8vp" })
                .fillColor($r('app.color.icon_primary'))
                .borderRadius($r('sys.float.corner_radius_level8'))
              /**
               * TODO:
               * please modify it according to the actual situation.
               * modify {@link MemberInformationModule#vipLevel}
               */
              Text(this.vipLevel)
                .font({ size: $r('app.integer.title_text_S'), weight: FontWeight.Bold })
                .fontColor($r('app.color.font_primary'))
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
            }
            .margin({ bottom: "4vp" })
            .width(CommonConstants.FULL_PERCENT)
            .onClick(() => this.jump())

            Row() {
              /**
               * TODO:
               * please modify it according to the actual situation.
               * modify {@link MemberInformationModule#expireText}
               */
              Text(this.expireText)
                .font({ size: $r('app.integer.body_text_S'), weight: FontWeight.Regular })
                .fontColor($r('app.color.font_tertiary'))
                .margin({ bottom: "4vp" })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
              /**
               * TODO:
               * please modify it according to the actual situation.
               * modify {@link MemberInformationModule#expireDate}
               */
              Text(this.expireDate)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
                .font({ size: $r('app.integer.body_text_S'), weight: FontWeight.Regular })
                .fontColor($r('app.color.font_tertiary'))
                .padding({ left: 4 })
                .margin({ bottom: "4vp" })
            }
            .width(CommonConstants.FULL_PERCENT)
          }
          .alignItems(HorizontalAlign.Start)
          .width("55%")
          .height(CommonConstants.FULL_PERCENT)

          Row() {
            Column() {
              /**
               * TODO:
               * please modify it according to the actual situation.
               * modify {@link MemberInformationModule#vipFunctionIcon1}
               */
              Image(this.vipFunctionIcon1)
                .height("28vp")
                .width("28vp")
                .fillColor($r('app.color.icon_primary'))
                .borderRadius($r('sys.float.corner_radius_level8'))
                .margin({ bottom: "4vp" })
                .onClick(() => {
                  this.jump()
                })
              /**
               * TODO:
               * please modify it according to the actual situation.
               * modify {@link MemberInformationModule#vipFunctionTitle1}
               */
              Text(this.vipFunctionTitle1)
                .font({ size: $r('app.integer.body_text_S'), weight: FontWeight.Regular })
                .fontColor($r('app.color.font_secondary'))
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
            }
            .margin({ right: "8vp" })
            .height(CommonConstants.FULL_PERCENT)
            .width("45%")

            Column() {
              /**
               * TODO:
               * please modify it according to the actual situation.
               * modify {@link MemberInformationModule#vipFunctionIcon2}
               */
              Image(this.vipFunctionIcon2)
                .height("28vp")
                .width("28vp")
                .fillColor($r('app.color.icon_primary'))
                .borderRadius($r('sys.float.corner_radius_level8'))
                .margin({ bottom: "4vp" })
                .onClick(() => {
                  this.jump()
                })
              /**
               * TODO:
               * please modify it according to the actual situation.
               * modify {@link MemberInformationModule#vipFunctionTitle2}
               */
              Text(this.vipFunctionTitle2)
                .font({ size: $r('app.integer.body_text_S'), weight: FontWeight.Regular })
                .fontColor($r('app.color.font_secondary'))
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
            }
            .margin({ right: "8vp" })
            .height(CommonConstants.FULL_PERCENT)
            .width("45%")
          }
          .justifyContent(FlexAlign.End)
          .width("45%")
          .height(CommonConstants.FULL_PERCENT)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .height("55%")
        .width(CommonConstants.FULL_PERCENT)

        Row() {
          /**
           * TODO:
           * please modify it according to the actual situation.
           * modify {@link MemberInformationModule#slogan}
           */
          Text(this.slogan)
            .fontColor($r('app.color.font_secondary'))
            .font({ size: $r('app.integer.subtitle_text_S'), weight: FontWeight.Medium })
            .width("70%")
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
          /**
           * TODO:
           * please modify it according to the actual situation.
           * modify {@link MemberInformationModule#buttonText}
           */
          Button(this.buttonText, { controlSize: ControlSize.SMALL })
            .type(ButtonType.Capsule)
            .fontColor($r('app.color.font_on_primary'))
            .backgroundColor($r('app.color.comp_background_emphasize'))
            .onClick(() => {
              this.jump()
            })
        }
        .height("45%")
        .width(CommonConstants.FULL_PERCENT)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(12)
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }
    .backgroundColor($r('app.color.comp_background_primary_trans'))
    .height("120vp")
    .width('92%')
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .margin({ bottom: "10vp" })
    .borderRadius($r('sys.float.corner_radius_level8'))
  }
}