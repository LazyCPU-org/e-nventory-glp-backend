-- Migration Script: Add Supplier Management and Dynamic Pricing
-- ========================================================
-- PART 1: SUPPLIER MANAGEMENT
-- ========================================================

-- Suppliers table
CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    tax_id VARCHAR(50),
    payment_terms VARCHAR(100),
    lead_time_days INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bulk LPG purchases
CREATE TABLE IF NOT EXISTS bulk_purchases (
    purchase_id SERIAL PRIMARY KEY,
    supplier_id INTEGER REFERENCES suppliers(supplier_id),
    business_location_id INTEGER REFERENCES business_locations(location_id),
    administrator_id INTEGER REFERENCES administrators(user_id),
    purchase_date DATE NOT NULL,
    delivery_date DATE,
    lpg_volume_kg DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    invoice_number VARCHAR(50),
    payment_status VARCHAR(20) NOT NULL,
    payment_date DATE,
    quality_check_status VARCHAR(20),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Supplier performance tracking
CREATE TABLE IF NOT EXISTS supplier_performance (
    performance_id SERIAL PRIMARY KEY,
    supplier_id INTEGER REFERENCES suppliers(supplier_id),
    review_period_start DATE NOT NULL,
    review_period_end DATE NOT NULL,
    delivery_timeliness DECIMAL(3,2), -- Score from 0.00 to 5.00
    product_quality DECIMAL(3,2),
    pricing_competitiveness DECIMAL(3,2),
    communication DECIMAL(3,2),
    overall_score DECIMAL(3,2),
    reviewer_id INTEGER REFERENCES users(user_id),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================
-- PART 2: DYNAMIC PRICING STRUCTURE
-- ========================================================

-- Customer pricing groups
CREATE TABLE IF NOT EXISTS customer_groups (
    group_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    min_purchase_amount DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Associate customers with pricing groups
ALTER TABLE customers ADD COLUMN customer_group_id INTEGER REFERENCES customer_groups(group_id);

-- Volume discount tiers
CREATE TABLE IF NOT EXISTS volume_discounts (
    discount_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    min_quantity INTEGER NOT NULL,
    max_quantity INTEGER,
    discount_percentage DECIMAL(5,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seasonal pricing adjustments
CREATE TABLE IF NOT EXISTS seasonal_pricing (
    seasonal_price_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    price_adjustment_type VARCHAR(20) NOT NULL, -- 'percentage' or 'fixed'
    adjustment_value DECIMAL(10,2) NOT NULL, -- Percentage or fixed amount
    reason VARCHAR(100),
    created_by INTEGER REFERENCES users(user_id),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Loyalty program
CREATE TABLE IF NOT EXISTS customer_loyalty (
    loyalty_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    points_balance INTEGER DEFAULT 0,
    lifetime_points INTEGER DEFAULT 0,
    tier_level VARCHAR(20) DEFAULT 'standard',
    join_date DATE DEFAULT CURRENT_DATE,
    last_activity_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Loyalty point transactions
CREATE TABLE IF NOT EXISTS loyalty_transactions (
    transaction_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    points_amount INTEGER NOT NULL,
    transaction_type VARCHAR(20) NOT NULL, -- 'earn', 'redeem', 'expire', 'adjust'
    source_type VARCHAR(20), -- 'purchase', 'referral', 'promotion'
    source_id INTEGER, -- Could reference an invoice_id or other source
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================================
-- PART 3: TRIGGERS FOR UPDATED_AT TIMESTAMPS
-- ========================================================

-- Supplier Management Triggers
CREATE TRIGGER update_suppliers_timestamp 
BEFORE UPDATE ON suppliers
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_bulk_purchases_timestamp 
BEFORE UPDATE ON bulk_purchases
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Dynamic Pricing Triggers
CREATE TRIGGER update_customer_groups_timestamp 
BEFORE UPDATE ON customer_groups
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_volume_discounts_timestamp 
BEFORE UPDATE ON volume_discounts
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_seasonal_pricing_timestamp 
BEFORE UPDATE ON seasonal_pricing
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_customer_loyalty_timestamp 
BEFORE UPDATE ON customer_loyalty
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- ========================================================
-- PART 4: INDEXES FOR PERFORMANCE OPTIMIZATION
-- ========================================================

-- Supplier Management Indexes
CREATE INDEX idx_bulk_purchases_supplier ON bulk_purchases(supplier_id);
CREATE INDEX idx_bulk_purchases_location ON bulk_purchases(business_location_id);
CREATE INDEX idx_bulk_purchases_date ON bulk_purchases(purchase_date);
CREATE INDEX idx_supplier_performance_supplier ON supplier_performance(supplier_id);

-- Dynamic Pricing Indexes
CREATE INDEX idx_customers_group ON customers(customer_group_id);
CREATE INDEX idx_volume_discounts_product ON volume_discounts(product_id);
CREATE INDEX idx_seasonal_pricing_product ON seasonal_pricing(product_id);
CREATE INDEX idx_seasonal_pricing_dates ON seasonal_pricing(start_date, end_date);
CREATE INDEX idx_customer_loyalty_customer ON customer_loyalty(customer_id);
CREATE INDEX idx_loyalty_transactions_customer ON loyalty_transactions(customer_id);