-- Drop new indexes
DROP INDEX IF EXISTS idx_users_user_type;
DROP INDEX IF EXISTS idx_user_business_locations_user_id;
DROP INDEX IF EXISTS idx_user_business_locations_location_id;
DROP INDEX IF EXISTS idx_tank_inventory_reports_date;
DROP INDEX IF EXISTS idx_tank_inventory_reports_location;

-- Drop triggers
DROP TRIGGER IF EXISTS update_business_locations_timestamp ON business_locations;
DROP TRIGGER IF EXISTS update_physical_locations_timestamp ON physical_locations;
DROP TRIGGER IF EXISTS update_tank_inventory_reports_timestamp ON tank_inventory_reports;

-- Revert deliveries table changes
ALTER TABLE deliveries
    DROP COLUMN IF EXISTS destination_location_id;
    
ALTER TABLE deliveries
    RENAME COLUMN administrator_id TO supervisor_id;
    
ALTER TABLE deliveries
    RENAME COLUMN origin_location_id TO location_id;

-- Drop tank inventory report tables
DROP TABLE IF EXISTS tank_inventory_report_items;
DROP TABLE IF EXISTS tank_inventory_reports;

-- Drop user-location mapping table
DROP TABLE IF EXISTS user_business_locations;

-- Drop user role-specific tables with permissions field
DROP TABLE IF EXISTS delivery_employees;
DROP TABLE IF EXISTS accountants;
DROP TABLE IF EXISTS administrators;
DROP TABLE IF EXISTS admins;
DROP TABLE IF EXISTS superadmins;

-- Revert user table changes
ALTER TABLE users
    DROP COLUMN IF EXISTS user_type,
    DROP COLUMN IF EXISTS token_refresh,
    DROP COLUMN IF EXISTS document;

-- Drop location inheritance tables
DROP TABLE IF EXISTS physical_locations;
DROP TABLE IF EXISTS business_locations;
DROP TABLE IF EXISTS locations_base;

-- Revert customers table structure if needed
ALTER TABLE customers
    ALTER COLUMN location_lat TYPE VARCHAR(20),
    ALTER COLUMN location_long TYPE VARCHAR(20);