-- Down Migration Script: Undo Supplier Management and Dynamic Pricing
-- ========================================================

-- ========================================================
-- PART 1: DROP INDEXES
-- ========================================================

-- Drop Dynamic Pricing Indexes
DROP INDEX IF EXISTS idx_loyalty_transactions_customer;
DROP INDEX IF EXISTS idx_customer_loyalty_customer;
DROP INDEX IF EXISTS idx_seasonal_pricing_dates;
DROP INDEX IF EXISTS idx_seasonal_pricing_product;
DROP INDEX IF EXISTS idx_volume_discounts_product;
DROP INDEX IF EXISTS idx_customers_group;

-- Drop Supplier Management Indexes
DROP INDEX IF EXISTS idx_supplier_performance_supplier;
DROP INDEX IF EXISTS idx_bulk_purchases_date;
DROP INDEX IF EXISTS idx_bulk_purchases_location;
DROP INDEX IF EXISTS idx_bulk_purchases_supplier;

-- ========================================================
-- PART 2: DROP TRIGGERS
-- ========================================================

-- Drop Dynamic Pricing Triggers
DROP TRIGGER IF EXISTS update_customer_loyalty_timestamp ON customer_loyalty;
DROP TRIGGER IF EXISTS update_seasonal_pricing_timestamp ON seasonal_pricing;
DROP TRIGGER IF EXISTS update_volume_discounts_timestamp ON volume_discounts;
DROP TRIGGER IF EXISTS update_customer_groups_timestamp ON customer_groups;

-- Drop Supplier Management Triggers
DROP TRIGGER IF EXISTS update_bulk_purchases_timestamp ON bulk_purchases;
DROP TRIGGER IF EXISTS update_suppliers_timestamp ON suppliers;

-- ========================================================
-- PART 3: DROP FOREIGN KEY COLUMN
-- ========================================================

-- Remove customer_group_id column from customers
ALTER TABLE customers DROP COLUMN IF EXISTS customer_group_id;

-- ========================================================
-- PART 4: DROP TABLES (in reverse dependency order)
-- ========================================================

-- Drop Dynamic Pricing Tables
DROP TABLE IF EXISTS loyalty_transactions;
DROP TABLE IF EXISTS customer_loyalty;
DROP TABLE IF EXISTS seasonal_pricing;
DROP TABLE IF EXISTS volume_discounts;
DROP TABLE IF EXISTS customer_groups;

-- Drop Supplier Management Tables
DROP TABLE IF EXISTS supplier_performance;
DROP TABLE IF EXISTS bulk_purchases;
DROP TABLE IF EXISTS suppliers;