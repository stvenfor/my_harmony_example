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
import { CommonConstants } from "../common/CommonConstants";
import { SymbolGlyphModifier } from "@kit.ArkUI";

@Component
export struct SearchNotificationModule {
  @State icon: Resource = $r('app.media.ic_headphones_lined')
  @State search_placeholder: string = "搜索"
  @State button_icon: Resource = $r('app.media.icon')
  @State button_value: string = '新闻有料'
  @State image: Resource = $r('app.media.icon')
  @Consume("pathStack") pathStack: NavPathStack

  jump(pageName: string = 'EmptyPagePathStack'): void {
    this.pathStack.pushPathByName(pageName, null);
  }

  build() {
    Row({ space: 8 }) {
      Image(this.icon)
        .height('60%')
        .borderRadius($r('sys.float.corner_radius_level12'))
        .backgroundColor($r('app.color.background_primary_SearchModuleWithIcons'))
        .padding(4)
        .fillColor($r('app.color.icon_primary_SearchModuleWithIcons'))
      Search({ placeholder: this.search_placeholder })
        .layoutWeight(1)
        .enableKeyboardOnFocus(false)
        .backgroundColor($r('app.color.comp_background_primary_trans'))
        .placeholderColor($r('sys.color.font_secondary'))
        .placeholderFont({
          family: "HarmonyHeiTi",
          size: $r('sys.float.Body_L'),
          weight: FontWeight.Regular
        })
        .searchIcon(new SymbolGlyphModifier($r('sys.symbol.ohos_trash')))
        .fontColor($r('sys.color.font_primary'))
        .borderRadius($r('sys.float.corner_radius_level4'))
        .onClick(() => {
          this.jump()
        })
      Row({ space: 4 }) {
        Text(this.button_value)
          .fontSize($r('app.integer.caption_text_M'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.font_on_primary'))
      }
      .height('60%')
      .borderRadius('50%')
      .borderWidth(1)
      .borderColor($r('app.color.comp_background_primary_trans'))
      .padding({
        left: 8,
        right: 8
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(45)
    .padding({ left: 8, right: 8 })
    .backgroundColor($r('app.color.icon_primary_SearchModuleWithIcons'))
  }
}