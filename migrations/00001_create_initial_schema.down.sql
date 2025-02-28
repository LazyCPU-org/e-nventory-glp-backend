-- First drop all triggers
DROP TRIGGER IF EXISTS update_delivery_routes_timestamp ON delivery_routes;
DROP TRIGGER IF EXISTS update_invoices_timestamp ON invoices;
DROP TRIGGER IF EXISTS update_deliveries_timestamp ON deliveries;
DROP TRIGGER IF EXISTS update_customers_timestamp ON customers;
DROP TRIGGER IF EXISTS update_products_timestamp ON products;
DROP TRIGGER IF EXISTS update_users_timestamp ON users;
DROP TRIGGER IF EXISTS update_locations_timestamp ON locations;

-- Drop the trigger function
DROP FUNCTION IF EXISTS update_timestamp();

-- Drop all indexes
DROP INDEX IF EXISTS idx_customer_phone;
DROP INDEX IF EXISTS idx_users_role;
DROP INDEX IF EXISTS idx_invoices_date;
DROP INDEX IF EXISTS idx_deliveries_date;
DROP INDEX IF EXISTS idx_deliveries_status;

-- Drop tables in reverse order of creation (respecting dependencies)
DROP TABLE IF EXISTS route_stops;
DROP TABLE IF EXISTS delivery_routes;
DROP TABLE IF EXISTS accountant_reports;
DROP TABLE IF EXISTS financial_verification;
DROP TABLE IF EXISTS tank_inventory;
DROP TABLE IF EXISTS invoice_items;
DROP TABLE IF EXISTS invoices;
DROP TABLE IF EXISTS delivery_status_history;
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS customer_phones;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS roles;