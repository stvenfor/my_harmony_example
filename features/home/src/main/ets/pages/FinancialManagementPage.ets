import { NavItem, StringConstants, createSupabaseClient, SupabaseClient } from '@ohos/common'

const TAG: string = 'FinancialManagementPage'

interface TransactionRecord {
  id: number;
  type: 'income' | 'expense';
  category: string;
  amount: number;
  date: string;
  note: string;
  icon: Resource;
}

interface AssetItem {
  name: string;
  balance: number;
  type: string;
  icon: Resource;
}

interface BudgetPlan {
  category: string;
  budget: number;
  spent: number;
  icon: Resource;
}

/** Supabase 排序参数类 */
class OrderParams {
  column: string = '';
  ascending?: boolean;
}

/** Supabase 查询参数封装类 */
class SupabaseQueryOptions {
  order?: OrderParams;
  limit?: number;
}

/** 交易数据插入类 */
class TransactionInsertData {
  type: string = '';
  category: string = '';
  amount: number = 0;
  date: string = '';
  note: string = '';
}

/** 交易数据更新类（包含主键 id） */
class TransactionUpdateData {
  id: number = 0;
  type: string = '';
  category: string = '';
  amount: number = 0;
  date: string = '';
  note: string = '';
}

/** 删除过滤条件类 */
class DeleteFilter {
  id: number = 0;
}

/** 表单结果回调类 */
class FormResult {
  type: string = '';
  amount: string = '';
  category: string = '';
  date: string = '';
  note: string = '';
}

@CustomDialog
struct TransactionDialog {
  controller: CustomDialogController
  isEdit: boolean = false
  onConfirm: (result: FormResult) => void = () => {}
  onCancel: () => void = () => {}

  @State transactionType: string = 'expense'
  @State formAmount: string = ''
  @State formCategory: string = ''
  @State formDate: string = ''
  @State formNote: string = ''

  private readonly expenseCategories: string[] = ['餐饮', '交通', '购物', '娱乐', '住房', '医疗', '教育', '其他']
  private readonly incomeCategories: string[] = ['工资', '兼职', '投资', '奖金', '其他']
  private readonly accent: string = '#0A59F7'
  private readonly incomeColor: string = '#10B981'
  private readonly expenseColor: string = '#EF4444'

  aboutToAppear(): void {
    if (!this.formDate) {
      this.formDate = new Date().toISOString().split('T')[0]
    }
  }

  build() {
    Column({ space: 16 }) {
      // 标题栏
      Row() {
        Text(this.isEdit ? '编辑交易' : '记一笔')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#182431')
          .layoutWeight(1)

        Button('关闭')
          .fontSize(14)
          .fontColor(this.accent)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.onCancel()
            this.controller.close()
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

      // 确认按钮
      Button(this.isEdit ? '更新' : '保存')
        .width('100%')
        .height(48)
        .borderRadius(24)
        .backgroundColor(this.accent)
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .onClick(() => {
          const result: FormResult = new FormResult();
          result.type = this.transactionType;
          result.amount = this.formAmount;
          result.category = this.formCategory;
          result.date = this.formDate;
          result.note = this.formNote;
          this.onConfirm(result)
          this.controller.close()
        })
    }
    .width('90%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(20)
  }
}

@Component
export struct FinancialManagementPage {
  @Consume('pathStack') pathStack: NavPathStack
  @StorageLink(StringConstants.TOP_AREA) topArea: number = 0
  @StorageLink(StringConstants.BOTTOM_AREA) bottomArea: number = 0
  
  @State activeTab: number = 0
  @State selectedMonth: string = '2026-05'
  @State transactionType: 'income' | 'expense' = 'expense'
  @State editingTransaction: TransactionRecord | null = null
  @State isEditMode: boolean = false
  
  // CustomDialog 控制器
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: TransactionDialog({
      isEdit: this.isEditMode,
      onConfirm: (result: FormResult) => {
        if (this.isEditMode) {
          this.handleUpdateResult(result)
        } else {
          this.handleAddResult(result)
        }
      },
      onCancel: () => {
        this.editingTransaction = null
      }
    }),
    customStyle: true,
    alignment: DialogAlignment.Center,
    maskColor: '#4D000000'
  })
  
  // Supabase 客户端
  private supabase: SupabaseClient = createSupabaseClient({
    projectUrl: 'https://uqznnzkugvhsrlcudrbj.supabase.co',
    apiKey: 'sb_publishable_b6_-AnEAi19hTurNNu7ojA_sL4oHgf5'
  })
  
  @State isLoading: boolean = false
  
  @State isSaving: boolean = false
  
  private readonly accent: string = '#0A59F7'
  private readonly cardBg: string = '#FFFFFF'
  private readonly pageBg: string = '#F2F3F5'
  private readonly incomeColor: string = '#10B981'
  private readonly expenseColor: string = '#EF4444'
  
  // 数据（首次进入时从 Supabase 加载）
  @State transactions: TransactionRecord[] = []
  
  @State assets: AssetItem[] = []
  
  @State budgets: BudgetPlan[] = []
  
  private readonly expenseCategories: string[] = ['餐饮', '交通', '购物', '娱乐', '住房', '医疗', '教育', '其他']
  private readonly incomeCategories: string[] = ['工资', '兼职', '投资', '奖金', '其他']

  aboutToAppear(): void {
    console.info(`${TAG}: Page appeared`)
    this.loadData()
  }

  /**
   * 从 Supabase 加载数据
   */
  async loadData(): Promise<void> {
    this.isLoading = true
    try {
      // 加载交易记录
      const queryOptions: SupabaseQueryOptions = new SupabaseQueryOptions();
      const orderParam: OrderParams = new OrderParams();
      orderParam.column = 'date';
      orderParam.ascending = false;
      queryOptions.order = orderParam;
      queryOptions.limit = 100;
      
      const transactionsResult = 
        await this.supabase.from<TransactionRecord>('transactions', queryOptions)
      
      if (transactionsResult.error) {
        console.error(`${TAG}: Load transactions error:`, transactionsResult.error.message)
      } else if (transactionsResult.data && transactionsResult.data.length > 0) {
        this.transactions = transactionsResult.data
      }
      
      // 加载资产数据
      const assetsResult = 
        await this.supabase.from<AssetItem>('assets')
      
      if (assetsResult.error) {
        console.error(`${TAG}: Load assets error:`, assetsResult.error.message)
      } else if (assetsResult.data && assetsResult.data.length > 0) {
        this.assets = assetsResult.data
      }
      
      // 加载预算数据
      const budgetsResult = 
        await this.supabase.from<BudgetPlan>('budgets')
      
      if (budgetsResult.error) {
        console.error(`${TAG}: Load budgets error:`, budgetsResult.error.message)
      } else if (budgetsResult.data && budgetsResult.data.length > 0) {
        this.budgets = budgetsResult.data
      }
      
      console.info(`${TAG}: Data loaded - transactions: ${this.transactions.length}, assets: ${this.assets.length}, budgets: ${this.budgets.length}`)
    } catch (error) {
      const err = error as BusinessError
      console.error(`${TAG}: Failed to load data. Code: ${err.code}, message: ${err.message}`)
      this.showToast('数据加载失败，请检查网络')
    } finally {
      this.isLoading = false
    }
  }

  /**
   * 批量保存所有交易到 Supabase（自动建表）
   */
  async saveAllTransactions(): Promise<void> {
    if (this.transactions.length === 0) {
      this.showToast('没有数据可保存')
      return
    }

    this.isSaving = true
    let firstError: string = ''
    
    try {
      // 首先检查表是否存在，如果不存在则提示用户
      const checkResult = await this.checkTableExists('transactions')
      
      if (!checkResult) {
        // 表不存在，显示创建表的指引
        this.showCreateTableDialog()
        this.isSaving = false
        return
      }
      
      let successCount = 0
      let failCount = 0

      for (const transaction of this.transactions) {
        try {
          // 构建要插入的数据对象（不包含 id 和 icon，因为它们是本地字段）
          const transactionData: TransactionInsertData = new TransactionInsertData();
          transactionData.type = transaction.type;
          transactionData.category = transaction.category;
          transactionData.amount = transaction.amount;
          transactionData.date = transaction.date;
          transactionData.note = transaction.note;

          console.info(`${TAG}: Attempting to save transaction:`, JSON.stringify(transactionData))

          // 尝试插入数据
          const result = await this.supabase.insert<TransactionRecord>('transactions', transactionData)
          
          if (result.error) {
            console.warn(`${TAG}: Failed to save transaction ${transaction.id}`, result.error)
            console.warn(`${TAG}: Error details - Message: ${result.error.message}, Code: ${result.error.code}`)
            
            // 记录第一个错误用于显示
            if (!firstError) {
              firstError = result.error.message
            }
            
            failCount++
          } else {
            successCount++
            console.info(`${TAG}: Successfully saved transaction ${transaction.id}`)
          }
        } catch (err) {
          const error = err as BusinessError
          console.error(`${TAG}: Exception saving transaction ${transaction.id}. Code: ${error.code}, message: ${error.message}`)
          
          // 记录第一个错误用于显示
          if (!firstError) {
            firstError = error.message
          }
          
          failCount++
        }
      }

      // 显示结果
      if (failCount === 0) {
        this.showToast(`成功保存 ${successCount} 条记录`)
      } else {
        const message = `保存完成：成功 ${successCount} 条，失败 ${failCount} 条`
        this.showToast(message)
        
        // 如果有错误，显示详细错误信息
        if (firstError) {
          setTimeout(() => {
            AlertDialog.show({
              title: '保存失败详情',
              message: `第一条错误信息：\n${firstError}\n\n请检查：\n1. 表是否已正确创建\n2. 网络连接是否正常\n3. Supabase配置是否正确`,
              primaryButton: {
                value: '确定',
                action: () => {}
              }
            })
          }, 500)
        }
      }

      console.info(`${TAG}: Save completed. Success: ${successCount}, Failed: ${failCount}`)
    } catch (error) {
      const err = error as BusinessError
      console.error(`${TAG}: Failed to save all transactions. Code: ${err.code}, message: ${err.message}`)
      this.showToast('保存失败，请检查网络连接')
    } finally {
      this.isSaving = false
    }
  }

  /**
   * 检查表是否存在
   */
  async checkTableExists(tableName: string): Promise<boolean> {
    try {
      // 尝试查询一条数据,如果表不存在会返回错误
      const queryOptions: SupabaseQueryOptions = new SupabaseQueryOptions();
      queryOptions.limit = 1;
        
      const result = await this.supabase.from<TransactionRecord>(tableName, queryOptions)
        
      // 如果返回错误且错误信息包含表不存在的提示
      if (result.error) {
        const errorMsg = result.error.message.toLowerCase()
        if (errorMsg.includes('relation') && errorMsg.includes('does not exist') ||
            errorMsg.includes('table') && errorMsg.includes('not found') ||
            result.error.code === '42P01') {
          return false
        }
      }
        
      return true
    } catch (error) {
      const err = error as BusinessError
      console.error(`${TAG}: Check table failed. Code: ${err.code}, message: ${err.message}`)
      return false
    }
  }

  /**
   * 显示创建表的对话框
   */
  private showCreateTableDialog(): void {
    AlertDialog.show({
      title: '需要先创建数据库表',
      message: '检测到 Supabase 中还没有 transactions 表。\n\n请先在 Supabase Dashboard 中执行 SQL 脚本创建表：\n\n1. 登录 Supabase Dashboard\n2. 进入 SQL Editor\n3. 执行 supabase_schema.sql 文件中的内容\n\n或者点击"查看SQL"按钮复制SQL语句。',
      primaryButton: {
        value: '关闭',
        action: () => {}
      },
      secondaryButton: {
        value: '查看SQL',
        action: () => {
          this.showSQLContent()
        }
      }
    })
  }

  /**
   * 显示SQL内容
   */
  private showSQLContent(): void {
    const sqlContent = `-- 创建交易记录表
CREATE TABLE IF NOT EXISTS transactions (
  id BIGINT PRIMARY KEY DEFAULT nextval('transactions_id_seq'),
  type VARCHAR(10) NOT NULL CHECK (type IN ('income', 'expense')),
  category VARCHAR(50) NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  date DATE NOT NULL,
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建序列
CREATE SEQUENCE IF NOT EXISTS transactions_id_seq;

-- 添加索引
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category);

-- 启用行级安全
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- 允许公开访问（生产环境建议启用认证）
CREATE POLICY "Allow public read access on transactions"
  ON transactions FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert on transactions"
  ON transactions FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow public update on transactions"
  ON transactions FOR UPDATE
  USING (true);

CREATE POLICY "Allow public delete on transactions"
  ON transactions FOR DELETE
  USING (true);`

    AlertDialog.show({
      title: 'SQL 建表语句',
      message: sqlContent,
      primaryButton: {
        value: '关闭',
        action: () => {}
      }
    })
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

  /**
   * 打开新增对话框
   */
  private openAddDialog(): void {
    this.isEditMode = false
    this.editingTransaction = null
    this.dialogController.open()
  }

  /**
   * 打开编辑对话框
   */
  private openEditDialog(transaction: TransactionRecord): void {
    this.editingTransaction = transaction
    this.isEditMode = true
    this.dialogController.open()
  }

  /**
   * 处理新增结果
   */
  private async handleAddResult(result: FormResult): Promise<void> {
    if (!result.amount || parseFloat(result.amount) <= 0) {
      this.showToast('请输入有效金额')
      return
    }
    if (!result.category) {
      this.showToast('请选择分类')
      return
    }

    const transactionData: TransactionInsertData = new TransactionInsertData();
    transactionData.type = result.type;
    transactionData.category = result.category;
    transactionData.amount = parseFloat(result.amount);
    transactionData.date = result.date;
    transactionData.note = result.note;

    try {
      const supabaseResult = 
        await this.supabase.insert<TransactionRecord>('transactions', transactionData)
      
      if (supabaseResult.error) {
        console.error(`${TAG}: Failed to save transaction`, supabaseResult.error)
        this.showToast('保存失败: ' + supabaseResult.error.message)
        return
      }
      
      const completeTransaction: TransactionRecord = {
        id: Date.now(),
        type: result.type as 'income' | 'expense',
        category: result.category,
        amount: parseFloat(result.amount),
        date: result.date,
        note: result.note,
        icon: result.type === 'expense' ? $r('sys.symbol.minus_circle') : $r('sys.symbol.plus_circle')
      }
      
      this.transactions = [completeTransaction, ...this.transactions]
      this.showToast('记账成功')
    } catch (error) {
      const err = error as BusinessError
      console.error(`${TAG}: Failed to add transaction. Code: ${err.code}, message: ${err.message}`)
      this.showToast('保存失败，请重试')
    }
  }

  /**
   * 处理更新结果
   */
  private async handleUpdateResult(result: FormResult): Promise<void> {
    if (!this.editingTransaction) {
      return
    }
    if (!result.amount || parseFloat(result.amount) <= 0) {
      this.showToast('请输入有效金额')
      return
    }
    if (!result.category) {
      this.showToast('请选择分类')
      return
    }

    const updateData: TransactionUpdateData = new TransactionUpdateData();
    updateData.id = this.editingTransaction.id;
    updateData.type = result.type;
    updateData.category = result.category;
    updateData.amount = parseFloat(result.amount);
    updateData.date = result.date;
    updateData.note = result.note;

    try {
      console.info(`${TAG}: Updating transaction ${this.editingTransaction.id}`, JSON.stringify(updateData))
      
      const filter: DeleteFilter = new DeleteFilter();
      filter.id = this.editingTransaction.id;
      
      const supabaseResult = 
        await this.supabase.update<TransactionRecord>('transactions', updateData, filter)
      
      if (supabaseResult.error) {
        console.error(`${TAG}: Failed to update transaction`, supabaseResult.error)
        this.showToast('更新失败: ' + supabaseResult.error.message)
        return
      }
      
      console.info(`${TAG}: Update successful`)
      
      const updatedTransaction: TransactionRecord = {
        id: this.editingTransaction.id,
        type: result.type as 'income' | 'expense',
        category: result.category,
        amount: parseFloat(result.amount),
        date: result.date,
        note: result.note,
        icon: result.type === 'expense' ? $r('sys.symbol.minus_circle') : $r('sys.symbol.plus_circle')
      }
      
      this.transactions = this.transactions.map(t => 
        t.id === this.editingTransaction!.id ? updatedTransaction : t
      )
      
      this.editingTransaction = null
      this.showToast('更新成功')
    } catch (error) {
      const err = error as BusinessError
      console.error(`${TAG}: Exception updating transaction. Code: ${err.code}, message: ${err.message}`)
      this.showToast('更新失败，请重试')
    }
  }

  private async deleteTransaction(id: number): Promise<void> {
    try {
      // 构建删除过滤条件
      const deleteFilter: DeleteFilter = new DeleteFilter();
      deleteFilter.id = id;
      
      // 从 Supabase 删除
      const result = 
        await this.supabase.delete('transactions', deleteFilter)
      
      if (result.error) {
        console.error(`${TAG}: Failed to delete transaction`, result.error)
        this.showToast('删除失败: ' + result.error.message)
        return
      }
      
      // 更新本地数据
      this.transactions = this.transactions.filter(t => t.id !== id)
      this.showToast('已删除')
    } catch (error) {
      const err = error as BusinessError
      console.error(`${TAG}: Failed to delete transaction. Code: ${err.code}, message: ${err.message}`)
      this.showToast('删除失败，请重试')
    }
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
    .onClick(() => {
      // 点击打开编辑对话框
      this.openEditDialog(record)
    })
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        // 左滑删除手势
        SwipeGesture()
          .onAction(() => {
            // 左滑显示删除确认
            AlertDialog.show({
              title: '确认删除',
              message: `确定要删除这条${record.type === 'income' ? '收入' : '支出'}记录吗？`,
              primaryButton: {
                value: '取消',
                action: () => {}
              },
              secondaryButton: {
                value: '删除',
                fontColor: this.expenseColor,
                action: () => {
                  this.deleteTransaction(record.id)
                }
              }
            })
          })
      )
    )
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
              // 加载状态
              if (this.isLoading) {
                Column() {
                  Text('加载中...')
                    .fontSize(14)
                    .fontColor('#99182431')
                }
                .width('100%')
                .height(200)
                .justifyContent(FlexAlign.Center)
              } else {
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

                    // 按钮行：新增 + 保存
                    Row({ space: 12 }) {
                      // 新增按钮
                      Button() {
                        Row({ space: 4 }) {
                          SymbolGlyph($r('sys.symbol.plus'))
                            .fontSize(18)
                            .fontColor([Color.White])
                          Text('新增')
                            .fontSize(15)
                            .fontColor(Color.White)
                        }
                      }
                      .layoutWeight(1)
                      .height(48)
                      .borderRadius(12)
                      .backgroundColor('#10B981')
                      .onClick(() => {
                        this.openAddDialog()
                      })

                      // 保存到 Supabase 按钮
                      Button(this.isSaving ? '保存中...' : `保存(${this.transactions.length})`)
                        .layoutWeight(1)
                        .height(48)
                        .borderRadius(12)
                        .backgroundColor(this.accent)
                        .fontColor(Color.White)
                        .fontSize(15)
                        .fontWeight(FontWeight.Medium)
                        .enabled(!this.isSaving && this.transactions.length > 0)
                        .opacity(this.isSaving || this.transactions.length === 0 ? 0.6 : 1.0)
                        .onClick(() => {
                          this.saveAllTransactions()
                        })
                    }
                    .width('100%')
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
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .title('财务管理示例')
  }
}
