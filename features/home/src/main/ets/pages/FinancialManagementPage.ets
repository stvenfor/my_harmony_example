import { NavItem, StringConstants } from '@ohos/common'

const TAG: string = 'FinancialManagementPage'

interface TransactionRecord {
  readonly id: number
  readonly type: 'income' | 'expense'
  readonly category: string
  readonly amount: number
  readonly date: string
  readonly note: string
  readonly icon: Resource
}

interface AssetItem {
  readonly name: string
  readonly balance: number
  readonly type: string
  readonly icon: Resource
}

interface BudgetPlan {
  readonly category: string
  readonly budget: number
  readonly spent: number
  readonly icon: Resource
}

@Component
export struct FinancialManagementPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  
  @State activeTab: number = 0
  @State selectedMonth: string = '2026-05'
  @State showAddDialog: boolean = false
  @State transactionType: 'income' | 'expense' = 'expense'
  
  // 表单数据
  @State formAmount: string = ''
  @State formCategory: string = ''
  @State formDate: string = new Date().toISOString().split('T')[0]
  @State formNote: string = ''
  
  private readonly accent: string = '#0A59F7'
  private readonly cardBg: string = '#FFFFFF'
  private readonly pageBg: string = '#F2F3F5'
  private readonly incomeColor: string = '#10B981'
  private readonly expenseColor: string = '#EF4444'
  
  // 模拟数据
  @State transactions: TransactionRecord[] = [
    { id: 1, type: 'expense', category: '餐饮', amount: 45.50, date: '2026-05-28', note: '午餐', icon: $r('sys.symbol.fork_knife') },
    { id: 2, type: 'expense', category: '交通', amount: 30.00, date: '2026-05-28', note: '地铁充值', icon: $r('sys.symbol.car') },
    { id: 3, type: 'income', category: '工资', amount: 8000.00, date: '2026-05-25', note: '5月工资', icon: $r('sys.symbol.briefcase') },
    { id: 4, type: 'expense', category: '购物', amount: 299.00, date: '2026-05-27', note: '购买衣物', icon: $r('sys.symbol.bag') },
    { id: 5, type: 'expense', category: '娱乐', amount: 128.00, date: '2026-05-26', note: '电影票', icon: $r('sys.symbol.film') },
    { id: 6, type: 'income', category: '兼职', amount: 1500.00, date: '2026-05-20', note: '周末兼职', icon: $r('sys.symbol.clock') },
    { id: 7, type: 'expense', category: '餐饮', amount: 89.00, date: '2026-05-25', note: '晚餐聚餐', icon: $r('sys.symbol.fork_knife') },
  ]
  
  @State assets: AssetItem[] = [
    { name: '微信钱包', balance: 3250.80, type: '电子钱包', icon: $r('sys.symbol.wechat') },
    { name: '支付宝', balance: 5680.50, type: '电子钱包', icon: $r('sys.symbol.creditcard_fill') },
    { name: '建设银行卡', balance: 12500.00, type: '银行卡', icon: $r('sys.symbol.creditcard') },
    { name: '现金', balance: 800.00, type: '现金', icon: $r('sys.symbol.wallet') },
  ]
  
  @State budgets: BudgetPlan[] = [
    { category: '餐饮', budget: 1500, spent: 890, icon: $r('sys.symbol.fork_knife') },
    { category: '交通', budget: 500, spent: 320, icon: $r('sys.symbol.car') },
    { category: '购物', budget: 2000, spent: 1450, icon: $r('sys.symbol.bag') },
    { category: '娱乐', budget: 800, spent: 560, icon: $r('sys.symbol.film') },
    { category: '其他', budget: 1000, spent: 280, icon: $r('sys.symbol.ellipsis_circle') },
  ]
  
  private readonly expenseCategories: string[] = ['餐饮', '交通', '购物', '娱乐', '住房', '医疗', '教育', '其他']
  private readonly incomeCategories: string[] = ['工资', '兼职', '投资', '奖金', '其他']

  aboutToAppear(): void {
    console.info(`${TAG}: Page appeared`)
  }

  private getTotalIncome(): number {
    return this.transactions
      .filter(t => t.type === 'income')
      .reduce((sum, t) => sum + t.amount, 0)
  }

  private getTotalExpense(): number {
    return this.transactions
      .filter(t => t.type === 'expense')
      .reduce((sum, t) => sum + t.amount, 0)
  }

  private getBalance(): number {
    return this.getTotalIncome() - this.getTotalExpense()
  }

  private getTotalAssets(): number {
    return this.assets.reduce((sum, a) => sum + a.balance, 0)
  }

  private formatMoney(amount: number): string {
    return `¥${amount.toFixed(2)}`
  }

  private showToast(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message, duration: 2000 })
    } catch (error) {
      const err = error as BusinessError
      console.error(`${TAG}: showToast failed. Code: ${err.code}, message: ${err.message}`)
    }
  }

  private addTransaction(): void {
    if (!this.formAmount || parseFloat(this.formAmount) <= 0) {
      this.showToast('请输入有效金额')
      return
    }

    if (!this.formCategory) {
      this.showToast('请选择分类')
      return
    }

    const newTransaction: TransactionRecord = {
      id: Date.now(),
      type: this.transactionType,
      category: this.formCategory,
      amount: parseFloat(this.formAmount),
      date: this.formDate,
      note: this.formNote,
      icon: this.transactionType === 'expense' ? $r('sys.symbol.minus_circle') : $r('sys.symbol.plus_circle')
    }

    this.transactions = [newTransaction, ...this.transactions]
    this.resetForm()
    this.showAddDialog = false
    this.showToast('记账成功')
  }

  private resetForm(): void {
    this.formAmount = ''
    this.formCategory = ''
    this.formDate = new Date().toISOString().split('T')[0]
    this.formNote = ''
  }

  private deleteTransaction(id: number): void {
    this.transactions = this.transactions.filter(t => t.id !== id)
    this.showToast('已删除')
  }

  @Builder
  private tabButton(label: string, index: number) {
    Text(label)
      .fontSize(15)
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
  }

  @Builder
  private summaryCard() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 4 }) {
          Text('本月结余')
            .fontSize(13)
            .fontColor('#99182431')
          Text(this.formatMoney(this.getBalance()))
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getBalance() >= 0 ? this.incomeColor : this.expenseColor)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Column({ space: 12 }) {
          Row({ space: 4 }) {
            Text('收入')
              .fontSize(12)
              .fontColor('#99182431')
            Text(this.formatMoney(this.getTotalIncome()))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.incomeColor)
          }

          Row({ space: 4 }) {
            Text('支出')
              .fontSize(12)
              .fontColor('#99182431')
            Text(this.formatMoney(this.getTotalExpense()))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.expenseColor)
          }
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(this.cardBg)
    .borderRadius(16)
  }

  @Builder
  private transactionItem(record: TransactionRecord) {
    Row({ space: 12 }) {
      Column() {
        SymbolGlyph(record.icon)
          .fontSize(22)
          .fontColor([record.type === 'income' ? this.incomeColor : this.expenseColor])
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(record.type === 'income' ? '#D1FAE5' : '#FEE2E2')
      .borderRadius(12)

      Column({ space: 4 }) {
        Text(record.category)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
        Text(`${record.date} ${record.note ? '· ' + record.note : ''}`)
          .fontSize(12)
          .fontColor('#99182431')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column({ space: 4 }) {
        Text(`${record.type === 'income' ? '+' : '-'}${this.formatMoney(record.amount)}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(record.type === 'income' ? this.incomeColor : this.expenseColor)
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.cardBg)
    .borderRadius(12)
  }

  @Builder
  private assetCard(asset: AssetItem) {
    Row({ space: 12 }) {
      Column() {
        SymbolGlyph(asset.icon)
          .fontSize(24)
          .fontColor([this.accent])
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#E8F0FE')
      .borderRadius(14)

      Column({ space: 4 }) {
        Text(asset.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
        Text(asset.type)
          .fontSize(12)
          .fontColor('#99182431')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.formatMoney(asset.balance))
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#182431')
    }
    .width('100%')
    .padding(14)
    .backgroundColor(this.cardBg)
    .borderRadius(12)
  }

  @Builder
  private budgetItem(budget: BudgetPlan) {
    Column({ space: 8 }) {
      Row() {
        SymbolGlyph(budget.icon)
          .fontSize(20)
          .fontColor([budget.spent > budget.budget ? this.expenseColor : this.accent])

        Text(budget.category)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#182431')
          .layoutWeight(1)
          .margin({ left: 8 })

        Text(`${this.formatMoney(budget.spent)} / ${this.formatMoney(budget.budget)}`)
          .fontSize(13)
          .fontColor(budget.spent > budget.budget ? this.expenseColor : '#66182431')
      }
      .width('100%')

      Progress({ 
        value: Math.min((budget.spent / budget.budget) * 100, 100), 
        total: 100, 
        type: ProgressType.Linear 
      })
        .width('100%')
        .height(8)
        .borderRadius(4)
        .color(budget.spent > budget.budget ? this.expenseColor : this.accent)
        .backgroundColor('#F4F6F8')

      Text(`${Math.min((budget.spent / budget.budget) * 100, 100).toFixed(0)}% ${budget.spent > budget.budget ? '(已超支)' : ''}`)
        .fontSize(11)
        .fontColor(budget.spent > budget.budget ? this.expenseColor : '#99182431')
        .width('100%')
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(this.cardBg)
    .borderRadius(12)
  }

  @Builder
  private addTransactionDialog() {
    Column() {
      Column({ space: 16 }) {
        Row() {
          Text('记一笔')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182431')
            .layoutWeight(1)

          Button('关闭')
            .fontSize(14)
            .fontColor(this.accent)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.showAddDialog = false
              this.resetForm()
            })
        }
        .width('100%')

        // 类型切换
        Row({ space: 10 }) {
          Button('支出')
            .layoutWeight(1)
            .height(40)
            .borderRadius(20)
            .backgroundColor(this.transactionType === 'expense' ? this.expenseColor : '#F4F6F8')
            .fontColor(this.transactionType === 'expense' ? Color.White : '#66182431')
            .onClick(() => {
              this.transactionType = 'expense'
              this.formCategory = ''
            })

          Button('收入')
            .layoutWeight(1)
            .height(40)
            .borderRadius(20)
            .backgroundColor(this.transactionType === 'income' ? this.incomeColor : '#F4F6F8')
            .fontColor(this.transactionType === 'income' ? Color.White : '#66182431')
            .onClick(() => {
              this.transactionType = 'income'
              this.formCategory = ''
            })
        }
        .width('100%')

        // 金额输入
        Column({ space: 4 }) {
          Text('金额')
            .fontSize(13)
            .fontColor('#66182431')
            .width('100%')
          TextInput({ placeholder: '0.00', text: this.formAmount })
            .height(48)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .type(InputType.Number)
            .backgroundColor('#F4F6F8')
            .borderRadius(10)
            .onChange((value: string) => {
              this.formAmount = value
            })
        }
        .width('100%')

        // 分类选择
        Column({ space: 4 }) {
          Text('分类')
            .fontSize(13)
            .fontColor('#66182431')
            .width('100%')
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.transactionType === 'expense' ? this.expenseCategories : this.incomeCategories, 
              (category: string) => {
                Text(category)
                  .fontSize(13)
                  .fontColor(this.formCategory === category ? Color.White : '#66182431')
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.formCategory === category ? this.accent : '#F4F6F8')
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    this.formCategory = category
                  })
              }, (category: string) => category)
          }
          .width('100%')
        }
        .width('100%')

        // 日期选择
        Column({ space: 4 }) {
          Text('日期')
            .fontSize(13)
            .fontColor('#66182431')
            .width('100%')
          TextInput({ text: this.formDate })
            .height(44)
            .fontSize(14)
            .backgroundColor('#F4F6F8')
            .borderRadius(10)
            .onChange((value: string) => {
              this.formDate = value
            })
        }
        .width('100%')

        // 备注
        Column({ space: 4 }) {
          Text('备注（可选）')
            .fontSize(13)
            .fontColor('#66182431')
            .width('100%')
          TextArea({ text: this.formNote, placeholder: '添加备注...' })
            .height(60)
            .fontSize(14)
            .backgroundColor('#F4F6F8')
            .borderRadius(10)
            .onChange((value: string) => {
              this.formNote = value
            })
        }
        .width('100%')

        Button('保存')
          .width('100%')
          .height(48)
          .borderRadius(24)
          .backgroundColor(this.accent)
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .onClick(() => {
            this.addTransaction()
          })
      }
      .width('100%')
      .padding(20)
    }
    .width('90%')
    .backgroundColor(this.cardBg)
    .borderRadius(20)
  }

  build() {
    NavDestination() {
      Column() {
        NavItem({ showBack: true, title: '财务管理示例' })

        Column({ space: 12 }) {
          // Tab 切换
          Row() {
            this.tabButton('账单', 0)
            this.tabButton('资产', 1)
            this.tabButton('预算', 2)
          }
          .width('100%')
          .padding(4)
          .backgroundColor('#F4F6F8')
          .borderRadius(22)

          // 内容区域
          Scroll() {
            Column({ space: 16 }) {
              if (this.activeTab === 0) {
                // 账单页面
                this.summaryCard()

                Column({ space: 12 }) {
                  Row() {
                    Text('交易记录')
                      .fontSize(17)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#182431')
                      .layoutWeight(1)

                    Text(`${this.selectedMonth}`)
                      .fontSize(13)
                      .fontColor('#66182431')
                  }
                  .width('100%')

                  List({ space: 8 }) {
                    ForEach(this.transactions, (record: TransactionRecord) => {
                      ListItem() {
                        this.transactionItem(record)
                      }
                    }, (record: TransactionRecord) => record.id.toString())
                  }
                  .width('100%')
                  .scrollBar(BarState.Auto)
                }
                .width('100%')
              } else if (this.activeTab === 1) {
                // 资产页面
                Column({ space: 12 }) {
                  Column({ space: 8 }) {
                    Text('总资产')
                      .fontSize(13)
                      .fontColor('#99182431')
                    Text(this.formatMoney(this.getTotalAssets()))
                      .fontSize(32)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#182431')
                  }
                  .alignItems(HorizontalAlign.Start)
                  .width('100%')
                  .padding(20)
                  .backgroundColor(this.cardBg)
                  .borderRadius(16)

                  Text('资产明细')
                    .fontSize(17)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#182431')
                    .width('100%')

                  List({ space: 8 }) {
                    ForEach(this.assets, (asset: AssetItem) => {
                      ListItem() {
                        this.assetCard(asset)
                      }
                    }, (asset: AssetItem) => asset.name)
                  }
                  .width('100%')
                  .scrollBar(BarState.Auto)
                }
                .width('100%')
              } else if (this.activeTab === 2) {
                // 预算页面
                Column({ space: 12 }) {
                  Text('月度预算')
                    .fontSize(17)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#182431')
                    .width('100%')

                  List({ space: 8 }) {
                    ForEach(this.budgets, (budget: BudgetPlan) => {
                      ListItem() {
                        this.budgetItem(budget)
                      }
                    }, (budget: BudgetPlan) => budget.category)
                  }
                  .width('100%')
                  .scrollBar(BarState.Auto)
                }
                .width('100%')
              }
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 100 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('100%')
        .height('100%')
        .padding({ top: this.topArea, bottom: this.bottomArea })
        .backgroundColor(this.pageBg)

        // 悬浮添加按钮
        Stack({ alignContent: Alignment.BottomEnd }) {
          Button() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(28)
              .fontColor([Color.White])
          }
          .width(56)
          .height(56)
          .borderRadius(28)
          .backgroundColor(this.accent)
          .shadow({
            radius: 16,
            color: '#400A59F7',
            offsetX: 0,
            offsetY: 4
          })
          .margin({ right: 20, bottom: 20 })
          .onClick(() => {
            this.showAddDialog = true
          })
        }
        .width('100%')
        .height('100%')
        .bindContentCover($$this.showAddDialog, this.addTransactionDialog(), ModalTransition.DEFAULT)
      }
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .title('财务管理示例')
  }
}
