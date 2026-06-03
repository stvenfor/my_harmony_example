-- Supabase 数据库表结构
-- 项目名称: independent
-- 项目URL: https://uqznnzkugvhsrlcudrbj.supabase.co

-- 1. 交易记录表 (transactions)
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

-- 2. 资产表 (assets)
CREATE TABLE IF NOT EXISTS assets (
  id BIGINT PRIMARY KEY DEFAULT nextval('assets_id_seq'),
  name VARCHAR(100) NOT NULL,
  balance DECIMAL(10, 2) NOT NULL DEFAULT 0,
  type VARCHAR(50) NOT NULL,
  icon_name VARCHAR(50), -- 存储图标名称，前端映射到实际图标
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建序列
CREATE SEQUENCE IF NOT EXISTS assets_id_seq;

-- 添加索引
CREATE INDEX IF NOT EXISTS idx_assets_type ON assets(type);

-- 3. 预算表 (budgets)
CREATE TABLE IF NOT EXISTS budgets (
  id BIGINT PRIMARY KEY DEFAULT nextval('budgets_id_seq'),
  category VARCHAR(50) NOT NULL,
  budget DECIMAL(10, 2) NOT NULL,
  spent DECIMAL(10, 2) NOT NULL DEFAULT 0,
  month VARCHAR(7), -- 格式: YYYY-MM，例如 2026-05
  icon_name VARCHAR(50), -- 存储图标名称，前端映射到实际图标
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建序列
CREATE SEQUENCE IF NOT EXISTS budgets_id_seq;

-- 添加索引
CREATE INDEX IF NOT EXISTS idx_budgets_month ON budgets(month);
CREATE INDEX IF NOT EXISTS idx_budgets_category ON budgets(category);

-- 4. 插入示例数据

-- 交易记录示例数据
INSERT INTO transactions (type, category, amount, date, note) VALUES
('expense', '餐饮', 45.50, '2026-05-28', '午餐'),
('expense', '交通', 30.00, '2026-05-28', '地铁充值'),
('income', '工资', 8000.00, '2026-05-25', '5月工资'),
('expense', '购物', 299.00, '2026-05-27', '购买衣物'),
('expense', '娱乐', 128.00, '2026-05-26', '电影票'),
('income', '兼职', 1500.00, '2026-05-20', '周末兼职'),
('expense', '餐饮', 89.00, '2026-05-25', '晚餐聚餐');

-- 资产示例数据
INSERT INTO assets (name, balance, type, icon_name) VALUES
('微信钱包', 3250.80, '电子钱包', 'wechat'),
('支付宝', 5680.50, '电子钱包', 'creditcard_fill'),
('建设银行卡', 12500.00, '银行卡', 'creditcard'),
('现金', 800.00, '现金', 'wallet');

-- 预算示例数据
INSERT INTO budgets (category, budget, spent, month, icon_name) VALUES
('餐饮', 1500, 890, '2026-05', 'fork_knife'),
('交通', 500, 320, '2026-05', 'car'),
('购物', 2000, 1450, '2026-05', 'bag'),
('娱乐', 800, 560, '2026-05', 'film'),
('其他', 1000, 280, '2026-05', 'ellipsis_circle');

-- 5. 设置 RLS (Row Level Security) 策略
-- 注意: 根据你的安全需求调整这些策略

-- 启用 RLS
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;

-- 创建策略 - 允许匿名读取（公开访问）
-- 如果需要认证，请修改为 auth.uid() 相关策略
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
  USING (true);

CREATE POLICY "Allow public read access on assets"
  ON assets FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert on assets"
  ON assets FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow public update on assets"
  ON assets FOR UPDATE
  USING (true);

CREATE POLICY "Allow public delete on assets"
  ON assets FOR DELETE
  USING (true);

CREATE POLICY "Allow public read access on budgets"
  ON budgets FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert on budgets"
  ON budgets FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow public update on budgets"
  ON budgets FOR UPDATE
  USING (true);

CREATE POLICY "Allow public delete on budgets"
  ON budgets FOR DELETE
  USING (true);

-- 6. 创建自动更新 updated_at 的触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为每个表添加触发器
CREATE TRIGGER update_transactions_updated_at
  BEFORE UPDATE ON transactions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_assets_updated_at
  BEFORE UPDATE ON assets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_budgets_updated_at
  BEFORE UPDATE ON budgets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
