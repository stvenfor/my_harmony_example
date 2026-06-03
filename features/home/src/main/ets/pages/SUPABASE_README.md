# Supabase 接入说明

## 项目信息
- **项目名称**: independent
- **项目URL**: https://uqznnzkugvhsrlcudrbj.supabase.co
- **API Key**: sb_publishable_b6_-AnEAi19hTurNNu7ojA_sL4oHgf5

## 数据库表结构

已在 `supabase_schema.sql` 文件中定义了以下表:

### 1. transactions (交易记录表)
存储收入和支出记录。

**字段说明:**
- `id`: 主键，自增
- `type`: 类型 (income/expense)
- `category`: 分类 (餐饮、交通、工资等)
- `amount`: 金额
- `date`: 日期
- `note`: 备注
- `created_at`: 创建时间
- `updated_at`: 更新时间

### 2. assets (资产表)
存储各类资产信息。

**字段说明:**
- `id`: 主键，自增
- `name`: 资产名称 (微信钱包、支付宝等)
- `balance`: 余额
- `type`: 类型 (电子钱包、银行卡、现金)
- `icon_name`: 图标名称
- `created_at`: 创建时间
- `updated_at`: 更新时间

### 3. budgets (预算表)
存储月度预算计划。

**字段说明:**
- `id`: 主键，自增
- `category`: 分类 (餐饮、交通、购物等)
- `budget`: 预算金额
- `spent`: 已花费金额
- `month`: 月份 (格式: YYYY-MM)
- `icon_name`: 图标名称
- `created_at`: 创建时间
- `updated_at`: 更新时间

## 设置步骤

### 1. 在 Supabase Dashboard 中执行 SQL

1. 登录 [Supabase Dashboard](https://app.supabase.com/)
2. 选择项目 "independent"
3. 进入 SQL Editor
4. 复制 `supabase_schema.sql` 文件的全部内容
5. 粘贴并执行 SQL 脚本

### 2. 验证表是否创建成功

在 Supabase Dashboard 的 Table Editor 中应该能看到三个表:
- transactions
- assets
- budgets

### 3. 配置 RLS 策略

SQL 脚本已经包含了基本的 RLS (Row Level Security) 策略，允许公开访问。

**注意**: 
- 当前配置为公开访问（无需认证）
- 如果需要用户认证，请修改策略使用 `auth.uid()` 
- 生产环境建议启用认证和更严格的权限控制

## 代码实现

### SupabaseClient 封装

位置: `/common/src/main/ets/utils/SupabaseClient.ets`

提供的方法:
- `from<T>(table, params)`: 查询数据
- `insert<T>(table, data)`: 插入数据
- `update<T>(table, data, filters)`: 更新数据
- `delete(table, filters)`: 删除数据
- `rpc<T>(functionName, params)`: 调用 RPC 函数

### FinancialManagementPage 集成

位置: `/features/home/src/main/ets/pages/FinancialManagementPage.ets`

**主要改动:**

1. **初始化 Supabase 客户端**
```typescript
private supabase: SupabaseClient = createSupabaseClient({
  projectUrl: 'https://uqznnzkugvhsrlcudrbj.supabase.co',
  apiKey: 'sb_publishable_b6_-AnEAi19hTurNNu7ojA_sL4oHgf5'
})
```

2. **页面加载时从 Supabase 获取数据**
```typescript
async loadData(): Promise<void> {
  // 加载交易记录、资产、预算数据
}
```

3. **添加交易时保存到 Supabase**
```typescript
async addTransaction(): Promise<void> {
  // 插入到 transactions 表
}
```

4. **删除交易时从 Supabase 删除**
```typescript
async deleteTransaction(id: number): Promise<void> {
  // 从 transactions 表删除
}
```

## 功能特性

### 已完成
✅ Supabase 客户端封装
✅ 数据加载（transactions, assets, budgets）
✅ 添加交易记录
✅ 删除交易记录（长按触发）
✅ 加载状态显示
✅ 错误处理和提示

### 可扩展
- 更新资产信息
- 更新预算计划
- 按月份筛选数据
- 数据同步优化
- 离线缓存
- 用户认证集成

## 注意事项

### 1. API Key 安全
- 当前使用的是 publishable key（可公开）
- 不要暴露 secret key
- 生产环境建议使用环境变量管理密钥

### 2. 数据类型映射
Supabase 返回的数据类型需要与前端接口匹配：
- `BIGINT` → `number`
- `DECIMAL` → `number`
- `DATE` → `string`
- `TIMESTAMP` → `string`
- `TEXT/VARCHAR` → `string`

### 3. 错误处理
所有 Supabase 操作都包含 try-catch 错误处理：
- 网络错误
- 权限错误
- 数据验证错误
- 超时错误

### 4. 性能优化建议
- 使用分页加载大量数据
- 添加适当的数据库索引
- 考虑本地缓存减少请求
- 使用防抖/节流优化频繁操作

## 测试验证

### 1. 检查数据加载
运行应用后，查看控制台日志：
```
FinancialManagementPage: Data loaded successfully
```

### 2. 测试添加交易
1. 点击右下角 "+" 按钮
2. 填写交易信息
3. 点击保存
4. 验证数据是否出现在列表中
5. 在 Supabase Dashboard 中检查 transactions 表

### 3. 测试删除交易
1. 长按任意交易记录
2. 确认删除
3. 验证记录是否从列表中消失
4. 在 Supabase Dashboard 中检查 transactions 表

## 常见问题

### Q: 数据加载失败怎么办？
A: 检查以下几点：
1. 网络连接是否正常
2. Supabase 项目 URL 是否正确
3. API Key 是否有效
4. 表是否已正确创建
5. RLS 策略是否允许访问

### Q: 如何添加用户认证？
A: 
1. 在 Supabase Dashboard 启用 Authentication
2. 修改 RLS 策略使用 `auth.uid()`
3. 在前端添加登录流程
4. 在请求头中添加用户 token

### Q: 如何处理并发冲突？
A: 
1. 使用乐观锁（version 字段）
2. 实现重试机制
3. 添加冲突解决策略

### Q: 数据量大了会慢吗？
A: 
1. 确保添加了合适的索引
2. 使用分页加载
3. 只查询需要的字段
4. 考虑使用 Supabase 的实时订阅功能

## 参考资源

- [Supabase 官方文档](https://supabase.com/docs)
- [Supabase JavaScript Client](https://supabase.com/docs/reference/javascript/introduction)
- [HarmonyOS axios](https://ohpm.openharmony.cn/#/cn/detail/@ohos%2Faxios)

## 下一步优化

1. **实时同步**: 使用 Supabase Realtime 订阅数据变化
2. **离线支持**: 实现本地数据库缓存
3. **图片上传**: 集成 Supabase Storage 上传图标
4. **数据分析**: 使用 Supabase Functions 进行数据统计
5. **推送通知**: 预算超支时发送通知
6. **数据导出**: 支持导出 CSV/Excel
