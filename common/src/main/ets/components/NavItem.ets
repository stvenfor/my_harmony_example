/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

/** 导航条固定高度（vp） */
export const NAV_ITEM_BAR_HEIGHT: number = 44

/**
 * 通用导航条：左（返回）- 中（标题或自定义）- 右（自定义），高 44。
 * 默认返回依赖祖先 Provide 的 pathStack；若传入 onBackPress 则只执行自定义逻辑（不再 pop）。
 */
@Component
export struct NavItem {
  @Consume('pathStack') pathStack: NavPathStack
  /** 中间默认展示文案；与 center 二选一：传入 center 时由 center 完全接管中间区域 */
  @Prop title: string = ''
  /** 是否展示左侧返回 */
  @Prop showBack: boolean = true
  /**
   * 自定义返回逻辑；未设置时点击返回为 pathStack.pop()。
   * 设置后仅调用本回调，不再自动 pop（便于自行 replacePath 等）。
   */
  backAction?: () => void

  @BuilderParam center: () => void = this.defaultCenter
  @BuilderParam trailing: () => void = this.emptyTrailing

  @Builder
  defaultCenter() {
    if (this.title.length > 0) {
      Text(this.title)
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
  }

  @Builder
  emptyTrailing() {
  }

  private handleBack(): void {
    this.backAction ? this.backAction() : this.pathStack.pop()
  }

  build() {
    Row() {
      Row() {
        if (this.showBack) {
          Image($r('app.media.ic_arrow_left'))
            .width(22)
            .height(22)
            .fillColor('#182431')
            .onClick(() => {
              this.handleBack()
            })
        }
      }
      .width(56)
      .height(NAV_ITEM_BAR_HEIGHT)
      .justifyContent(FlexAlign.Center)

      Row() {
        this.center()
      }
      .layoutWeight(1)
      .height(NAV_ITEM_BAR_HEIGHT)
      .justifyContent(FlexAlign.Center)

      Row() {
        this.trailing()
      }
      .constraintSize({ minWidth: 56 })
      .height(NAV_ITEM_BAR_HEIGHT)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(NAV_ITEM_BAR_HEIGHT)
  }
}
