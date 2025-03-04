-- Create user-business_location many-to-many relationship table
CREATE TABLE IF NOT EXISTS user_business_locations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    location_id INTEGER REFERENCES business_locations(location_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS inventory_verification_status (
    status_id SERIAL PRIMARY KEY,
    verification_status VARCHAR(20) NOT NULL
);

-- Create tank inventory reports tables
CREATE TABLE IF NOT EXISTS tank_inventory_reports (
    report_id SERIAL PRIMARY KEY,
    business_location_id INTEGER REFERENCES business_locations(location_id),
    user_id INTEGER REFERENCES users(user_id),
    supervisor_id INTEGER REFERENCES supervisors(user_id),
    report_date DATE NOT NULL,
    report_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    verification_status INTEGER REFERENCES inventory_verification_status(status_id),
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