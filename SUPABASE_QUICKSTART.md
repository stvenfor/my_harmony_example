# Supabase 接入 - 快速开始

## ✅ 已完成的工作

### 1. Supabase 客户端封装
- **文件**: `/common/src/main/ets/utils/SupabaseClient.ets`
- **功能**: 
  - 基于 axios 封装 Supabase REST API
  - 支持 CRUD 操作 (查询、插入、更新、删除)
  - 统一的错误处理
  - TypeScript 类型支持

### 2. FinancialManagementPage 集成
- **文件**: `/features/home/src/main/ets/pages/FinancialManagementPage.ets`
- **改动**:
  - ✅ 初始化 Supabase 客户端
  - ✅ 页面加载时从 Supabase 获取数据
  - ✅ 添加交易时保存到 Supabase
  - ✅ 删除交易时从 Supabase 删除 (长按触发)
  - ✅ 加载状态显示
  - ✅ 完善的错误处理和用户提示

### 3. 数据库 Schema
- **文件**: `/features/home/src/main/ets/pages/supabase_schema.sql`
- **包含**:
  - 3个表的定义 (transactions, assets, budgets)
  - 索引优化
  - 示例数据
  - RLS 安全策略
  - 自动更新时间戳触发器

### 4. 文档
- **SUPABASE_README.md**: 完整的接入说明和使用指南

---

## 🚀 下一步操作

### 步骤 1: 在 Supabase 中创建表

1. 访问 [Supabase Dashboard](https://app.supabase.com/)
2. 选择项目 "independent" (https://uqznnzkugvhsrlcudrbj.supabase.co)
3. 进入 **SQL Editor**
4. 复制 `supabase_schema.sql` 的全部内容
5. 粘贴并点击 **Run** 执行

### 步骤 2: 验证表创建成功

在 Supabase Dashboard 的 **Table Editor** 中检查是否创建了以下表:
- ✅ transactions
- ✅ assets  
- ✅ budgets

### 步骤 3: 运行应用测试

1. 编译并运行 HarmonyOS 应用
2. 导航到财务管理页面
3. 观察控制台日志:
   ```
   FinancialManagementPage: Data loaded successfully
   ```
4. 如果看到 "数据加载失败，使用本地数据"，请检查:
   - 网络连接
   - Supabase 项目 URL 是否正确
   - API Key 是否有效
   - 表是否已创建
   - RLS 策略是否允许访问

### 步骤 4: 测试功能

#### 测试数据加载
- 打开财务管理页面
- 应该能看到从 Supabase 加载的交易记录、资产和预算数据

#### 测试添加交易
1. 点击右下角 "+" 按钮
2. 选择类型 (收入/支出)
3. 输入金额
4. 选择分类
5. 填写日期和备注 (可选)
6. 点击保存
7. 验证:
   - 列表中立即显示新记录
   - 在 Supabase Dashboard 的 transactions 表中能看到新数据

#### 测试删除交易
1. 长按任意交易记录
2. 确认删除对话框弹出
3. 点击"删除"
4. 验证:
   - 记录从列表中消失
   - 在 Supabase Dashboard 中该记录已被删除

---

## 📋 配置信息

### Supabase 项目
```
Project URL: https://uqznnzkugvhsrlcudrbj.supabase.co
API Key: sb_publishable_b6_-AnEAi19hTurNNu7ojA_sL4oHgf5
```

### 数据库表结构

#### transactions (交易记录)
```typescript
interface TransactionRecord {
  id: number
  type: 'income' | 'expense'
  category: string
  amount: number
  date: string
  note: string
}
```

#### assets (资产)
```typescript
interface AssetItem {
  name: string
  balance: number
  type: string
}
```

#### budgets (预算)
```typescript
interface BudgetPlan {
  category: string
  budget: number
  spent: number
}
```

---

## 🔧 SupabaseClient API 使用示例

### 查询数据
```typescript
// 查询所有交易记录，按日期降序
const result = await supabase.from<TransactionRecord>('transactions', {
  order: { column: 'date', ascending: false },
  limit: 100
})

if (result.data) {
  console.log('交易记录:', result.data)
}
```

### 插入数据
```typescript
const newTransaction = {
  type: 'expense',
  category: '餐饮',
  amount: 50.00,
  date: '2026-06-03',
  note: '午餐'
}

const result = await supabase.insert<TransactionRecord>(
  'transactions', 
  newTransaction
)

if (result.error) {
  console.error('插入失败:', result.error)
}
```

### 更新数据
```typescript
const result = await supabase.update(
  'transactions',
  { amount: 60.00, note: '晚餐' },
  { id: 1 }  // 过滤条件
)
```

### 删除数据
```typescript
const result = await supabase.delete(
  'transactions',
  { id: 1 }  // 过滤条件
)
```

---

## ⚠️ 注意事项

### 安全性
1. **当前配置为公开访问** - RLS 策略允许任何人读写数据
2. **生产环境建议**:
   - 启用 Supabase Authentication
   - 修改 RLS 策略使用 `auth.uid()`
   - 不要在前端暴露 secret key

### 数据类型
- Supabase 的 `BIGINT` → HarmonyOS 的 `number`
- Supabase 的 `DECIMAL` → HarmonyOS 的 `number`
- Supabase 的 `DATE/TIMESTAMP` → HarmonyOS 的 `string`

### 错误处理
所有 Supabase 操作都包含 try-catch:
```typescript
try {
  const result = await supabase.from('transactions')
  if (result.error) {
    // 处理业务错误
  }
} catch (error) {
  // 处理网络错误等
}
```

---

## 🐛 常见问题排查

### Q: 数据加载失败
**检查清单**:
1. ✅ 网络连接正常
2. ✅ Supabase 项目 URL 正确
3. ✅ API Key 有效且未过期
4. ✅ 表已在 Supabase 中创建
5. ✅ RLS 策略允许匿名访问
6. ✅ 查看控制台错误日志

### Q: 如何查看 Supabase 请求日志?
在 Supabase Dashboard → **Logs** → **API Logs** 可以查看所有 API 请求

### Q: 如何调试数据问题?
1. 在 Supabase Dashboard → **Table Editor** 直接查看数据
2. 使用 **SQL Editor** 执行查询验证数据
3. 在应用中添加更多 console.log 输出

---

## 📚 相关文件

```
/common/src/main/ets/utils/SupabaseClient.ets          # Supabase 客户端
/common/Index.ets                                       # 导出 Supabase 相关类
/features/home/src/main/ets/pages/FinancialManagementPage.ets  # 财务管理页面
/features/home/src/main/ets/pages/supabase_schema.sql   # 数据库 schema
/features/home/src/main/ets/pages/SUPABASE_README.md    # 详细文档
```

---

## 🎯 后续优化建议

1. **实时同步**: 使用 Supabase Realtime 订阅数据变化
2. **离线缓存**: 实现本地数据库 (Preferences/SQLite)
3. **分页加载**: 大数据量时使用 limit/offset
4. **图片上传**: 集成 Supabase Storage
5. **用户认证**: 启用 Supabase Auth
6. **云函数**: 使用 Supabase Functions 进行数据统计
7. **性能监控**: 添加请求耗时统计

---

## ✨ 总结

现在你的财务管理页面已经完全接入 Supabase! 

- ✅ 数据存储在云端
- ✅ 支持多设备同步
- ✅ 实时 CRUD 操作
- ✅ 完善的错误处理

接下来只需在 Supabase Dashboard 执行 SQL 脚本,就可以开始使用了!

如有问题,请参考 `SUPABASE_README.md` 获取更详细的说明。
