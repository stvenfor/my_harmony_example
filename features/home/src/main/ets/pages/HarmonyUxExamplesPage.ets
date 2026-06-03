import { NavItem, StringConstants } from '@ohos/common'

interface UxExampleItem {
  readonly title: string
  readonly desc: string
  readonly icon: Resource
}

@Component
export struct HarmonyUxExamplesPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  @State counter: number = 2
  @State progress: number = 64
  @State rating: number = 4
  @State sliderValue: number = 56
  @State switchOn: boolean = true
  @State searchText: string = ''
  @State activeTab: number = 0
  @State listItems: string[] = ['列表项 1', '列表项 2', '列表项 3', '列表项 4', '列表项 5']
  @State showPanel: boolean = false
  @State checkboxGroup: string[] = ['选项1']
  @State selectedDate: string = '2026-01-01'
  @State showDialog: boolean = false
  @State textInputValue: string = ''

  private readonly pageBg: string = '#F2F3F5'
  private readonly cardBg: string = '#FFFFFF'
  private readonly accent: string = '#0A59F7'
  private readonly exampleItems: UxExampleItem[] = [
    { title: '操作类组件', desc: '按钮、菜单、核心操作区', icon: $r('sys.symbol.checkmark_circle') },
    { title: '容器类组件', desc: '列表、弹出面板、信息承载', icon: $r('sys.symbol.square_grid_2x2') },
    { title: '输入类组件', desc: '搜索框、文本框、数字加减', icon: $r('sys.symbol.search_things') },
    { title: '导航类组件', desc: '底部页签、子页签、标题栏', icon: $r('sys.symbol.arrow_left_arrow_right') },
    { title: '展示类组件', desc: '角标、进度条、即时反馈', icon: $r('sys.symbol.star') },
    { title: '选择类组件', desc: '评分、滑动条、开关、复选框', icon: $r('sys.symbol.repeat') }
  ]

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration: 1800 })
    } catch (error) {
      console.error(`HarmonyUxExamplesPage showToast failed: ${JSON.stringify(error)}`)
    }
  }

  @Builder
  private menuBuilder() {
    Menu() {
      MenuItem({ content: '复制' })
      MenuItem({ content: '分享' })
      MenuItem({ content: '收藏' })
      MenuItem({ content: '更多设置' })
    }
  }

  @Builder
  private sectionTitle(title: string, desc: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#182431')
      Text(desc)
        .fontSize(12)
        .lineHeight(18)
        .fontColor('#99182431')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  private categoryItem(item: UxExampleItem) {
    Row({ space: 12 }) {
      Column() {
        SymbolGlyph(item.icon)
          .fontSize(22)
          .fontColor([this.accent])
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#E8F0FE')
      .borderRadius(12)

      Column({ space: 4 }) {
        Text(item.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
        Text(item.desc)
          .fontSize(12)
          .fontColor('#99182431')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#F7F8FA')
    .borderRadius(12)
  }

  @Builder
  private primaryButton(label: string, action: () => void) {
    Button(label)
      .height(40)
      .layoutWeight(1)
      .borderRadius(20)
      .fontSize(14)
      .backgroundColor(this.accent)
      .fontColor(Color.White)
      .onClick(action)
  }

  @Builder
  private secondaryButton(label: string, action: () => void) {
    Button(label)
      .height(40)
      .layoutWeight(1)
      .borderRadius(20)
      .fontSize(14)
      .backgroundColor('#E8F0FE')
      .fontColor(this.accent)
      .onClick(action)
  }

  @Builder
  private badgeLabel(label: string, count: number) {
    Stack({ alignContent: Alignment.TopEnd }) {
      Text(label)
        .fontSize(14)
        .fontColor('#182431')
        .padding({ left: 14, right: 14, top: 8, bottom: 8 })
        .backgroundColor('#F4F6F8')
        .borderRadius(18)
      Text(`${count}`)
        .fontSize(10)
        .fontColor(Color.White)
        .height(18)
        .width(count > 9 ? 24 : 18)
        .textAlign(TextAlign.Center)
        .backgroundColor('#E64545')
        .borderRadius(9)
        .translate({ x: 6, y: -6 })
    }
  }

  build() {
    NavDestination() {
      Column() {
        NavItem({ showBack: true, title: '组件 UX 示例' })

        Scroll() {
        Column({ space: 16 }) {
          Column({ space: 8 }) {
            Text('HarmonyOS Component UX Examples')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#182431')
              .width('100%')
            Text('参考官方 ArkUI 组件示例集合，展示 HarmonyOS Design 常用组件的原生交互形态。')
              .fontSize(13)
              .lineHeight(20)
              .fontColor('#99182431')
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          Grid() {
            ForEach(this.exampleItems, (item: UxExampleItem) => {
              GridItem() {
                this.categoryItem(item)
              }
            }, (item: UxExampleItem) => item.title)
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(10)
          .rowsGap(10)
          .width('100%')

          // 操作类组件
          Column({ space: 14 }) {
            this.sectionTitle('操作类组件', '按钮状态、菜单和即时操作。')
            Column({ space: 12 }) {
              Row({ space: 10 }) {
                this.primaryButton('主按钮', () => {
                  this.showToast('点击了主按钮')
                })
                this.secondaryButton('次按钮', () => {
                  this.showToast('点击了次按钮')
                })
              }
              .width('100%')

              Button('打开菜单')
                .width('100%')
                .height(40)
                .borderRadius(20)
                .backgroundColor('#F4F6F8')
                .fontColor('#182431')
                .bindMenu(this.menuBuilder())
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.cardBg)
          .borderRadius(16)

          // 容器类组件
          Column({ space: 14 }) {
            this.sectionTitle('容器类组件', '列表、弹出面板和信息承载。')
            Column({ space: 12 }) {
              // List 示例
              Text('列表示例')
                .fontSize(14)
                .fontColor('#66182431')
                .width('100%')

              List({ space: 8 }) {
                ForEach(this.listItems, (item: string, index: number) => {
                  ListItem() {
                    Row() {
                      Text(item)
                        .fontSize(14)
                        .fontColor('#182431')
                        .layoutWeight(1)
                      SymbolGlyph($r('sys.symbol.chevron_right'))
                        .fontSize(16)
                        .fontColor(['#99182431'])
                    }
                    .width('100%')
                    .padding(12)
                    .backgroundColor('#F7F8FA')
                    .borderRadius(8)
                  }
                }, (item: string, index: number) => `${item}_${index}`)
              }
              .width('100%')
              .height(200)
              .scrollBar(BarState.Auto)
              .edgeEffect(EdgeEffect.Spring)

              // Panel 示例
              Button('打开底部面板')
                .width('100%')
                .height(40)
                .borderRadius(20)
                .backgroundColor('#E8F0FE')
                .fontColor(this.accent)
                .onClick(() => {
                  this.showPanel = true
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.cardBg)
          .borderRadius(16)

          // 输入类组件
          Column({ space: 14 }) {
            this.sectionTitle('输入类组件', '搜索框、文本输入和数字加减。')
            Column({ space: 12 }) {
              Search({ value: this.searchText, placeholder: '搜索组件' })
                .height(40)
                .backgroundColor('#F4F6F8')
                .onChange((value: string) => {
                  this.searchText = value
                })
              TextInput({ placeholder: '请输入内容' })
                .height(40)
                .backgroundColor('#F4F6F8')
                .borderRadius(10)
              Row({ space: 12 }) {
                Button('-')
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .backgroundColor('#E8F0FE')
                  .fontColor(this.accent)
                  .onClick(() => {
                    this.counter = Math.max(0, this.counter - 1)
                  })
                Text(`${this.counter}`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#182431')
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                Button('+')
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .backgroundColor(this.accent)
                  .fontColor(Color.White)
                  .onClick(() => {
                    this.counter += 1
                  })
              }
              .width('100%')
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.cardBg)
          .borderRadius(16)

          // 导航类组件
          Column({ space: 14 }) {
            this.sectionTitle('导航类组件', '底部页签和子页签的切换反馈。')
            Column({ space: 12 }) {
              Row() {
                ForEach(['首页', '发现', '我的'], (tab: string, index: number) => {
                  Text(tab)
                    .fontSize(14)
                    .fontWeight(this.activeTab === index ? FontWeight.Bold : FontWeight.Normal)
                    .fontColor(this.activeTab === index ? Color.White : '#66182431')
                    .textAlign(TextAlign.Center)
                    .layoutWeight(1)
                    .height(36)
                    .backgroundColor(this.activeTab === index ? this.accent : Color.Transparent)
                    .borderRadius(18)
                    .onClick(() => {
                      this.activeTab = index
                    })
                }, (tab: string) => tab)
              }
              .width('100%')
              .padding(4)
              .backgroundColor('#F4F6F8')
              .borderRadius(22)

              Text(`当前页签：${['首页', '发现', '我的'][this.activeTab]}`)
                .fontSize(14)
                .fontColor('#66182431')
                .width('100%')
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.cardBg)
          .borderRadius(16)

          // 展示类组件
          Column({ space: 14 }) {
            this.sectionTitle('展示类组件', '角标、进度条和反馈信息。')
            Column({ space: 14 }) {
              Row({ space: 16 }) {
                this.badgeLabel('消息', 3)
                this.badgeLabel('待办', 8)
              }
              .width('100%')

              Row({ space: 10 }) {
                Text('下载')
                  .fontSize(14)
                  .fontColor('#66182431')
                Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
                  .layoutWeight(1)
                Text(`${this.progress}%`)
                  .fontSize(14)
                  .fontColor('#66182431')
              }
              .width('100%')

              this.secondaryButton('显示 Toast', () => {
                this.showToast('这是一条即时反馈')
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.cardBg)
          .borderRadius(16)

          // 选择类组件
          Column({ space: 14 }) {
            this.sectionTitle('选择类组件', '评分、滑动条、开关和复选框。')
            Column({ space: 14 }) {
              // 评分
              Row({ space: 12 }) {
                Text('评分')
                  .fontSize(14)
                  .fontColor('#66182431')
                Rating({ rating: this.rating, indicator: false })
                  .stars(5)
                  .stepSize(1)
                  .onChange((value: number) => {
                    this.rating = value
                  })
              }
              .width('100%')

              // 滑动条
              Row({ space: 12 }) {
                Text('滑动')
                  .fontSize(14)
                  .fontColor('#66182431')
                Slider({
                  value: this.sliderValue,
                  min: 0,
                  max: 100,
                  style: SliderStyle.OutSet
                })
                  .layoutWeight(1)
                  .onChange((value: number) => {
                    this.sliderValue = Math.round(value)
                  })
                Text(`${this.sliderValue}`)
                  .fontSize(14)
                  .fontColor('#66182431')
                  .width(36)
                  .textAlign(TextAlign.End)
              }
              .width('100%')

              // 开关
              Row() {
                Text('开启原生体验')
                  .fontSize(15)
                  .fontColor('#182431')
                Blank()
                Toggle({ type: ToggleType.Switch, isOn: this.switchOn })
                  .selectedColor(this.accent)
                  .onChange((isOn: boolean) => {
                    this.switchOn = isOn
                  })
              }
              .width('100%')
              .height(48)
              .padding({ left: 12, right: 12 })
              .backgroundColor('#F4F6F8')
              .borderRadius(12)

              // 复选框组
              Column({ space: 8 }) {
                Text('复选框组')
                  .fontSize(14)
                  .fontColor('#66182431')
                  .width('100%')
                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                  ForEach(['选项1', '选项2', '选项3'], (item: string) => {
                    Row({ space: 4 }) {
                      Checkbox({ name: item })
                        .selectedColor(this.accent)
                        .select(this.checkboxGroup.includes(item))
                        .onChange((isSelected: boolean) => {
                          if (isSelected) {
                            if (!this.checkboxGroup.includes(item)) {
                              this.checkboxGroup.push(item)
                            }
                          } else {
                            const index = this.checkboxGroup.indexOf(item)
                            if (index !== -1) {
                              this.checkboxGroup.splice(index, 1)
                            }
                          }
                        })
                      Text(item)
                        .fontSize(14)
                        .fontColor('#182431')
                    }
                  }, (item: string) => item)
                }
                .width('100%')
                Text(`已选择：${this.checkboxGroup.join(', ')}`)
                  .fontSize(12)
                  .fontColor('#99182431')
                  .width('100%')
              }
              .width('100%')
              .padding(12)
              .backgroundColor('#F4F6F8')
              .borderRadius(12)
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.cardBg)
          .borderRadius(16)

          // 弹窗与反馈
          Column({ space: 14 }) {
            this.sectionTitle('弹窗与反馈', '对话框、Toast 和加载状态。')
            Column({ space: 12 }) {
              Row({ space: 10 }) {
                this.primaryButton('显示对话框', () => {
                  this.showDialog = true
                })
                this.secondaryButton('显示 Toast', () => {
                  this.showToast('这是一条即时反馈消息')
                })
              }
              .width('100%')

              this.secondaryButton('模拟加载', () => {
                this.showToast('加载中...')
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.cardBg)
          .borderRadius(16)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.topArea, bottom: this.bottomArea })
    .backgroundColor(this.pageBg)
    .bindContentCover($$this.showPanel, this.panelBuilder(), ModalTransition.DEFAULT)
    .bindContentCover($$this.showDialog, this.dialogBuilder(), ModalTransition.DEFAULT)
  }
  .hideTitleBar(true)
  .onReady((context: NavDestinationContext) => {
    this.pathStack = context.pathStack
  })
  .title('组件 UX 示例')
  }

  @Builder
  private panelBuilder() {
    Column() {
      Row() {
        Text('底部面板')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .layoutWeight(1)
        Button('关闭')
          .fontSize(14)
          .fontColor(this.accent)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showPanel = false
          })
      }
      .width('100%')
      .padding(16)
      .borderRadius({ topLeft: 16, topRight: 16 })

      Column({ space: 12 }) {
        Text('这是一个从底部弹出的面板')
          .fontSize(14)
          .fontColor('#66182431')
          .width('100%')

        Button('面板操作按钮')
          .width('100%')
          .height(44)
          .borderRadius(22)
          .backgroundColor(this.accent)
          .fontColor(Color.White)
          .onClick(() => {
            this.showToast('点击了面板按钮')
            this.showPanel = false
          })
      }
      .width('100%')
      .padding(16)
      .layoutWeight(1)
    }
    .width('100%')
    .height('60%')
    .backgroundColor(this.cardBg)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private dialogBuilder() {
    Column() {
      Column({ space: 16 }) {
        Text('确认对话框')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .width('100%')
          .textAlign(TextAlign.Center)

        Text('这是一个模态对话框示例，用于展示 HarmonyOS 的对话框组件。')
          .fontSize(14)
          .fontColor('#66182431')
          .width('100%')
          .lineHeight(20)

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .borderRadius(22)
            .backgroundColor('#F4F6F8')
            .fontColor('#182431')
            .onClick(() => {
              this.showDialog = false
            })

          Button('确定')
            .layoutWeight(1)
            .height(44)
            .borderRadius(22)
            .backgroundColor(this.accent)
            .fontColor(Color.White)
            .onClick(() => {
              this.showToast('已确认')
              this.showDialog = false
            })
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')
      .padding(20)
    }
    .width('80%')
    .backgroundColor(this.cardBg)
    .borderRadius(16)
  }
}
