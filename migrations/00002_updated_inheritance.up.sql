-- Create base location table for inheritance
CREATE TABLE IF NOT EXISTS locations_base (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    phone VARCHAR(20),
    location_lat VARCHAR(20),
    location_long VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create business and physical locations as child tables
CREATE TABLE IF NOT EXISTS business_locations (
    PRIMARY KEY (location_id)
) INHERITS (locations_base);

CREATE TABLE IF NOT EXISTS physical_locations (
    PRIMARY KEY (location_id)
) INHERITS (locations_base);

-- Update users table to add token_refresh and document fields
ALTER TABLE users 
    ADD COLUMN IF NOT EXISTS user_type VARCHAR(50) NOT NULL,
    ADD COLUMN IF NOT EXISTS token_refresh VARCHAR(255),
    ADD COLUMN IF NOT EXISTS document VARCHAR(100);

-- Create user role specific tables with inheritance
CREATE TABLE IF NOT EXISTS superadmins (
    permissions JSONB,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_superadmin_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) INHERITS (users);

CREATE TABLE IF NOT EXISTS admins (
    permissions JSONB,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_admin_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) INHERITS (users);

CREATE TABLE IF NOT EXISTS administrators (
    department VARCHAR(100),
    permissions JSONB,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_administrator_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) INHERITS (users);

CREATE TABLE IF NOT EXISTS accountants (
    certification VARCHAR(100),
    specialization VARCHAR(100),
    permissions JSONB,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_accountant_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) INHERITS (users);

CREATE TABLE IF NOT EXISTS delivery_employees (
    vehicle_id VARCHAR(50),
    max_capacity INTEGER,
    permissions JSONB,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_delivery_employee_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) INHERITS (users);

-- Create user-business_location many-to-many relationship table
CREATE TABLE IF NOT EXISTS user_business_locations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    location_id INTEGER REFERENCES business_locations(location_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create tank inventory reports tables
CREATE TABLE IF NOT EXISTS tank_inventory_reports (
    report_id SERIAL PRIMARY KEY,
    business_location_id INTEGER REFERENCES business_locations(location_id),
    user_id INTEGER REFERENCES users(user_id),
    administrator_id INTEGER REFERENCES administrators(user_id),
    report_date DATE NOT NULL,
    report_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    verification_status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tank_inventory_report_items (
    item_id SERIAL PRIMARY KEY,
    report_id INTEGER REFERENCES tank_inventory_reports(report_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(product_id),
    full_tanks_count INTEGER NOT NULL,
    empty_tanks_count INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Update customers table structure
ALTER TABLE customers
    ALTER COLUMN location_lat TYPE VARCHAR(20),
    ALTER COLUMN location_long TYPE VARCHAR(20);

-- Update deliveries table to use both business and physical locations
ALTER TABLE deliveries 
    RENAME COLUMN location_id TO origin_location_id;
    
ALTER TABLE deliveries
    ADD COLUMN destination_location_id INTEGER REFERENCES physical_locations(location_id);

-- Update supervisor_id column in deliveries to be administrator_id
ALTER TABLE deliveries
    RENAME COLUMN supervisor_id TO administrator_id;

-- Create triggers for new tables
CREATE TRIGGER update_business_locations_timestamp BEFORE UPDATE ON business_locations
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_physical_locations_timestamp BEFORE UPDATE ON physical_locations
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_tank_inventory_reports_timestamp BEFORE UPDATE ON tank_inventory_reports
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Create additional indexes for performance
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_user_business_locations_user_id ON user_business_locations(user_id);
CREATE INDEX idx_user_business_locations_location_id ON user_business_locations(location_id);
CREATE INDEX idx_tank_inventory_reports_date ON tank_inventory_reports(report_date);
CREATE INDEX idx_tank_inventory_reports_location ON tank_inventory_reports(business_location_id);