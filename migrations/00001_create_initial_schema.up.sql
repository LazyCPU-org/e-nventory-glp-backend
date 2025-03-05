-- Roles table
CREATE TABLE IF NOT EXISTS roles (
    role_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    permissions JSONB
);

-- Locations table
CREATE TABLE IF NOT EXISTS locations (
    location_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    location_lat VARCHAR(20),
    location_long VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create business and physical locations as child tables of locations
CREATE TABLE IF NOT EXISTS business_locations (
    PRIMARY KEY (location_id)
) INHERITS (locations);

CREATE TABLE IF NOT EXISTS physical_locations (
    PRIMARY KEY (location_id)
) INHERITS (locations);

-- Users table (with self-referential relationship for supervisors)
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    token_refresh VARCHAR(255),
    role_id INTEGER REFERENCES roles(role_id),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    document VARCHAR(100),
    location_id INTEGER REFERENCES business_locations(location_id),
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    user_type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User supervisors intermediate table
CREATE TABLE IF NOT EXISTS user_supervisors (
    user_supervisor_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    supervisor_id INTEGER NOT NULL REFERENCES users(user_id),
    is_active BOOLEAN DEFAULT TRUE,
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, supervisor_id, start_date) -- Prevents duplicate relationships
);

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

CREATE TABLE IF NOT EXISTS supervisors (
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
    permissions JSONB,
    PRIMARY KEY (user_id),
    CONSTRAINT fk_delivery_employee_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) INHERITS (users);

-- Products table (LPG tanks)
CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    weight_kg DECIMAL(5,2) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customers table
CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    primary_phone VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customer phones table
CREATE TABLE IF NOT EXISTS customer_phones (
    phone_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    phone_number VARCHAR(20) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    phone_type VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Deliveries table
CREATE TABLE IF NOT EXISTS deliveries (
    delivery_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    delivery_employee_id INTEGER REFERENCES delivery_employees(user_id),
    origin_location_id INTEGER REFERENCES physical_locations(location_id),
    destination_location_id INTEGER REFERENCES physical_locations(location_id),
    supervisor_id INTEGER REFERENCES users(user_id),
    delivery_status VARCHAR(20) NOT NULL,
    scheduled_date DATE NOT NULL,
    actual_delivery_time TIMESTAMP,
    is_tank_returned BOOLEAN,
    cash_payment_amount DECIMAL(10,2),
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Delivery status history table
CREATE TABLE IF NOT EXISTS delivery_status_history (
    history_id SERIAL PRIMARY KEY,
    delivery_id INTEGER REFERENCES deliveries(delivery_id),
    previous_status VARCHAR(20) NOT NULL,
    new_status VARCHAR(20) NOT NULL,
    changed_by INTEGER REFERENCES users(user_id),
    change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

-- Invoices table (with accountant verification)
CREATE TABLE IF NOT EXISTS invoices (
    invoice_id SERIAL PRIMARY KEY,
    delivery_id INTEGER REFERENCES deliveries(delivery_id),
    customer_id INTEGER REFERENCES customers(customer_id),
    accountant_id INTEGER REFERENCES users(user_id),
    total_amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    invoice_date DATE NOT NULL,
    payment_date DATE,
    verification_status VARCHAR(20) DEFAULT 'pending',
    verification_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Invoice items table
CREATE TABLE IF NOT EXISTS invoice_items (
    item_id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoices(invoice_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL
);

-- Tank inventory table
CREATE TABLE IF NOT EXISTS tank_inventory (
    inventory_id SERIAL PRIMARY KEY,
    location_id INTEGER REFERENCES business_locations(location_id),
    product_id INTEGER REFERENCES products(product_id),
    full_tanks_count INTEGER NOT NULL DEFAULT 0,
    empty_tanks_count INTEGER NOT NULL DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Financial verification table
CREATE TABLE IF NOT EXISTS financial_verification (
    verification_id SERIAL PRIMARY KEY,
    invoice_id INTEGER REFERENCES invoices(invoice_id),
    accountant_id INTEGER REFERENCES users(user_id),
    previous_status VARCHAR(20) NOT NULL,
    new_status VARCHAR(20) NOT NULL,
    verification_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    discrepancy_amount DECIMAL(10,2),
    resolution_status VARCHAR(20),
    resolved_by INTEGER REFERENCES users(user_id),
    resolution_date TIMESTAMP
);

-- Accountant reports table
CREATE TABLE IF NOT EXISTS accountant_reports (
    report_id SERIAL PRIMARY KEY,
    accountant_id INTEGER REFERENCES users(user_id),
    location_id INTEGER REFERENCES business_locations(location_id),
    report_date DATE NOT NULL,
    start_period DATE NOT NULL,
    end_period DATE NOT NULL,
    total_transactions INTEGER NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    total_verified INTEGER NOT NULL,
    total_with_discrepancies INTEGER NOT NULL,
    report_status VARCHAR(20) NOT NULL,
    generated_by INTEGER REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Delivery routes table
CREATE TABLE IF NOT EXISTS delivery_routes (
    route_id SERIAL PRIMARY KEY,
    location_id INTEGER REFERENCES physical_locations(location_id),
    delivery_employee_id INTEGER REFERENCES users(user_id),
    route_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Route stops table
CREATE TABLE IF NOT EXISTS route_stops (
    stop_id SERIAL PRIMARY KEY,
    route_id INTEGER REFERENCES delivery_routes(route_id),
    delivery_id INTEGER REFERENCES deliveries(delivery_id),
    stop_order INTEGER NOT NULL,
    estimated_arrival TIME,
    actual_arrival TIME
);

-- Create auto-update triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Insert the user into the appropriate subtable based on user_type
CREATE OR REPLACE FUNCTION insert_user_to_subtype()
RETURNS TRIGGER AS $$
BEGIN
    CASE NEW.user_type
        WHEN 'superadmin' THEN
            INSERT INTO superadmins 
            (user_id, username, password_hash, role_id, name, email, phone, 
             user_type, is_active, location_id, token_refresh, document, last_login, 
             created_at, updated_at)
            VALUES 
            (NEW.user_id, NEW.username, NEW.password_hash, NEW.role_id, NEW.name, 
             NEW.email, NEW.phone, NEW.user_type, NEW.is_active, NEW.location_id, 
             NEW.token_refresh, NEW.document, NEW.last_login, NEW.created_at, NEW.updated_at);
        WHEN 'admin' THEN
            INSERT INTO admins 
            (user_id, username, password_hash, role_id, name, email, phone, 
             user_type, is_active, location_id, token_refresh, document, last_login, 
             created_at, updated_at)
            VALUES 
            (NEW.user_id, NEW.username, NEW.password_hash, NEW.role_id, NEW.name, 
             NEW.email, NEW.phone, NEW.user_type, NEW.is_active, NEW.location_id, 
             NEW.token_refresh, NEW.document, NEW.last_login, NEW.created_at, NEW.updated_at);
        WHEN 'supervisor' THEN
            INSERT INTO supervisors 
            (user_id, username, password_hash, role_id, name, email, phone, 
             user_type, is_active, location_id, token_refresh, document, last_login, 
             created_at, updated_at, department)
            VALUES 
            (NEW.user_id, NEW.username, NEW.password_hash, NEW.role_id, NEW.name, 
             NEW.email, NEW.phone, NEW.user_type, NEW.is_active, NEW.location_id, 
             NEW.token_refresh, NEW.document, NEW.last_login, NEW.created_at, NEW.updated_at,
             NULL);
        WHEN 'accountant' THEN
            INSERT INTO accountants 
            (user_id, username, password_hash, role_id, name, email, phone, 
             user_type, is_active, location_id, token_refresh, document, last_login, 
             created_at, updated_at, certification, specialization)
            VALUES 
            (NEW.user_id, NEW.username, NEW.password_hash, NEW.role_id, NEW.name, 
             NEW.email, NEW.phone, NEW.user_type, NEW.is_active, NEW.location_id, 
             NEW.token_refresh, NEW.document, NEW.last_login, NEW.created_at, NEW.updated_at,
             NULL, NULL);
        WHEN 'delivery_employee' THEN
            INSERT INTO delivery_employees 
            (user_id, username, password_hash, role_id, name, email, phone, 
             user_type, is_active, location_id, token_refresh, document, last_login, 
             created_at, updated_at)
            VALUES 
            (NEW.user_id, NEW.username, NEW.password_hash, NEW.role_id, NEW.name, 
             NEW.email, NEW.phone, NEW.user_type, NEW.is_active, NEW.location_id, 
             NEW.token_refresh, NEW.document, NEW.last_login, NEW.created_at, NEW.updated_at);
        ELSE
            RAISE EXCEPTION 'Unknown user_type: %', NEW.user_type;
    END CASE;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_user_to_subtype_trigger
AFTER INSERT ON users
FOR EACH ROW 
EXECUTE FUNCTION insert_user_to_subtype();

-- Create triggers for tables that need updated_at timestamp
CREATE TRIGGER update_locations_timestamp BEFORE UPDATE ON locations
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_users_timestamp BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_products_timestamp BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_customers_timestamp BEFORE UPDATE ON customers
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_deliveries_timestamp BEFORE UPDATE ON deliveries
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_invoices_timestamp BEFORE UPDATE ON invoices
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_delivery_routes_timestamp BEFORE UPDATE ON delivery_routes
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- Create additional indexes for performance
CREATE INDEX idx_deliveries_status ON deliveries(delivery_status);
CREATE INDEX idx_deliveries_date ON deliveries(scheduled_date);
CREATE INDEX idx_invoices_date ON invoices(invoice_date);
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_customer_phone ON customers(primary_phone);