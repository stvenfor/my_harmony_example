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
  DataSource,
  DataSourceStyleAStyleA,
  DataSourceStyleBStyleB,
  DataSourceStyleCStyleC,
  DataSourceStyleDStyleD,
  DataSourceStyleEStyleE,
  DataSourceStyleFStyleF,
  DataSourceStyleGStyleG,
  DataSourceStyleHStyleH
} from '../viewmodel/SearchModuleData';

@Component
struct SearchIcon {
  private styles: DataSource = new DefaultSearchBarStyle('');
  onJump?: () => void;

  build() {
    Image($r('sys.media.ohos_ic_public_scan'))
      .width(this.styles.icon.size)
      .height(this.styles.icon.size)
      .margin({ left: this.styles.spacing.iconLeft })
      .fillColor(this.styles.icon.color)
  }
}

@Component
struct SearchDivider {
  private styles: DataSource = new DefaultSearchBarStyle('');

  build() {
    Divider()
      .vertical(true)
      .height(this.styles.divider.height)
      .strokeWidth(this.styles.divider.width)
      .color(this.styles.divider.color)
      .margin({
        left: this.styles.spacing.dividerMargin.left,
        right: this.styles.spacing.dividerMargin.right
      })
  }
}

@Component
struct SearchInput {
  private styles: DataSource = new DefaultSearchBarStyle('');

  build() {
    TextInput({ placeholder: this.styles.input.placeholder })
      .placeholderColor(this.styles.input.placeholderColor)
      .placeholderFont({ size: this.styles.input.fontSize })
      .caretColor(this.styles.input.caretColor)
      .fontSize(this.styles.input.fontSize)
      .backgroundColor('transparent')
      .layoutWeight(1)
      .height(this.styles.input.height)
      .border({ width: 0 })
  }
}

@Component
struct SearchButton {
  private styles: DataSource = new DefaultSearchBarStyle('');
  onJump?: () => void;

  build() {
    Text(this.styles.button.text)
      .fontSize(this.styles.button.fontSize)
      .fontColor(this.styles.button.color)
      .backgroundColor(this.styles.button.backgroundColor)
      .borderRadius(this.styles.size.borderRadius)
      .width(this.styles.button.width)
      .height(this.styles.button.height)
      .textAlign(TextAlign.Center)
      .position({ right: this.styles.spacing.buttonRight })
      .onClick(() => this.onJump?.())
  }
}

class DefaultSearchBarStyle implements DataSource {
  readonly size: DataSourceStyleAStyleA;
  readonly spacing: DataSourceStyleBStyleB;
  readonly icon: DataSourceStyleCStyleC;
  readonly divider: DataSourceStyleDStyleD;
  readonly input: DataSourceStyleEStyleE;
  readonly button: DataSourceStyleFStyleF;
  readonly colors: DataSourceStyleHStyleH;

  constructor(text: string) {
    this.size = {
      height: 40,
      contentHeight: 36,
      borderRadius: 24
    } as DataSourceStyleAStyleA;
    this.spacing = {
      horizontal: 16,
      iconLeft: 16,
      dividerMargin: {
        left: 8,
        right: 0
      } as DataSourceStyleGStyleG,
      inputLeft: 8,
      buttonRight: 16
    } as DataSourceStyleBStyleB;
    this.icon = {
      size: 16,
      color: '#999999'
    } as DataSourceStyleCStyleC;
    this.divider = {
      height: 12,
      width: 1,
      color: '#DDDDDD'
    } as DataSourceStyleDStyleD;
    this.input = {
      width: 'auto',
      height: 36,
      fontSize: 16,
      placeholder: text,
      placeholderColor: '$r(\'sys.color.font_secondary\')',
      caretColor: '#0A59F7'
    } as DataSourceStyleEStyleE;
    this.button = {
      width: 35,
      height: this.size.height,
      fontSize: 16,
      color: '#0A59F7',
      backgroundColor: 'Color.Transparent',
      text: '搜索'
    } as DataSourceStyleFStyleF;
    this.colors = {
      background: 'Color.Transparent',
      contentBackground: '#0C000000',
      border: 'Color.Transparent'
    } as DataSourceStyleHStyleH;
  }
}

@Component
export struct SearchModule {
  @Consume('pathStack') pathStack: NavPathStack;
  @State text: string = "搜索商品";
  private styles: DataSource = new DefaultSearchBarStyle(this.text);

  jump(pageName: string = 'EmptyPagePathStack'): void {
    this.pathStack.pushPathByName(pageName, null);
  }

  build() {
    Row() {
      Row() {
        SearchIcon({
          styles: this.styles,
          onJump: () => this.jump()
        })
        SearchDivider({ styles: this.styles })
        SearchInput({ styles: this.styles })
        SearchButton({
          styles: this.styles,
          onJump: () => this.jump()
        })
      }
      .width('100%')
      .height(this.styles.size.contentHeight)
      .backgroundColor(this.styles.colors.contentBackground)
      .borderRadius(this.styles.size.borderRadius)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
    }
    .padding({ left: this.styles.spacing.horizontal, right: this.styles.spacing.horizontal })
    .width('100%')
    .height(this.styles.size.height)
    .backgroundColor(this.styles.colors.background)
  }
}