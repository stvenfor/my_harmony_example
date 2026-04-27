/**
 * Apache License
 *
 * Copyright (C) 2025 Huawei Device Co., Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { PageHeaderComp, RouteConstants, StringConstants } from '@ohos/common';

@Entry
@Component
export struct SpinePage {
  @Consume('pathStack') pathStack: NavPathStack;
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0

  build() {
    NavDestination() {
      Column() {
        PageHeaderComp({
          title: 'Spine动画',
          backAction: () => {
            this.pathStack.pop();
          }
        })
        Column() {
          Button($r('app.string.Load_animation'))
            .margin({ top: 10 })
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteConstants.SPINE_EXAMPLE1 });
            })

          Button($r('app.string.Load_network_animation'))
            .margin({ top: 10 })
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteConstants.SPINE_NETWORK_EXAMPLE });
            })

          Button($r('app.string.Load_JSON_animation'))
            .margin({ top: 10 })
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteConstants.SPINE_SINGLE_EXAMPLE });
            })
          Button($r('app.string.Load_skeletal_animation'))
            .margin({ top: 10 })
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteConstants.SPINE_EXAMPLE2 });
            })
          Button($r('app.string.Load_sandbox_animation'))
            .margin({ top: 10 })
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteConstants.SPINE_EXAMPLE3 });
            })
          Button($r('app.string.other'))
            .margin({ top: 10 })
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteConstants.SPINE_EXAMPLE4 });
            })

          Button($r('app.string.basic'))
            .margin({ top: 10 })
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteConstants.BASIC_EXAMPLE4 });
            })

          Button($r('app.string.special'))
            .margin({ top: 10 })
            .onClick(() => {
              this.pathStack.pushPath({ name: RouteConstants.SPECIAL_ANIMATION });
            })
        }
        .padding(10)
      }
      .height('100%')
      .width('100%')
      .padding({ top: this.topArea, bottom: this.bottomArea })
    }.hideTitleBar(true)

  }
}