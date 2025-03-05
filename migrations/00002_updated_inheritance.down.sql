-- Drop indexes
DROP INDEX IF EXISTS idx_tank_inventory_reports_location;
DROP INDEX IF EXISTS idx_tank_inventory_reports_date;
DROP INDEX IF EXISTS idx_user_business_locations_location_id;
DROP INDEX IF EXISTS idx_user_business_locations_user_id;
DROP INDEX IF EXISTS idx_users_user_type;

-- Drop triggers
DROP TRIGGER IF EXISTS update_tank_inventory_reports_timestamp ON tank_inventory_reports;
DROP TRIGGER IF EXISTS update_physical_locations_timestamp ON physical_locations;
DROP TRIGGER IF EXISTS update_business_locations_timestamp ON business_locations;

-- Drop tables in reverse order of dependencies
DROP TABLE IF EXISTS tank_inventory_report_items;
DROP TABLE IF EXISTS tank_inventory_reports;
DROP TABLE IF EXISTS inventory_verification_status;
DROP TABLE IF EXISTS user_business_locations;