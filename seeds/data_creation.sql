-- Updated seed data for dashboard tables based on the new schema

-- 1. Roles seed data
INSERT INTO roles (role_id, name, description, permissions) VALUES
(1, 'supervisor', 'Manages business operations', '{"manage_inventory": true, "manage_staff": true, "manage_deliveries": true}'),
(2, 'delivery', 'Handles tank deliveries', '{"perform_deliveries": true, "update_inventory": true}');

-- Reset sequence for roles
SELECT setval('roles_role_id_seq', (SELECT MAX(role_id) FROM roles));

-- 2. Locations seed data (business and physical)
-- Business locations
INSERT INTO business_locations (location_id, name, address, city, state, postal_code, phone, is_active, location_lat, location_long) VALUES
(1, 'Main Warehouse', '123 Storage Ave', 'Springfield', 'ST', '12345', '555-111-2222', true, '37.7749', '-122.4194'),
(2, 'North Distribution Center', '456 Supply St', 'Shelbyville', 'ST', '23456', '555-333-4444', true, '37.7850', '-122.4383');

-- Physical locations (customer addresses)
INSERT INTO physical_locations (location_id, name, address, city, state, postal_code, phone, is_active, location_lat, location_long) VALUES
(3, 'Smith Residence', '789 Home Lane', 'Springfield', 'ST', '12345', '555-555-0101', true, '37.7749', '-122.4294'),
(4, 'Johnson Residence', '321 House St', 'Springfield', 'ST', '12345', '555-555-0202', true, '37.7649', '-122.4184'),
(5, 'Green Residence', '654 Dwelling Ave', 'Shelbyville', 'ST', '23456', '555-555-0303', true, '37.7839', '-122.4303');

-- Reset sequence for locations
SELECT setval('locations_location_id_seq', (SELECT MAX(location_id) FROM locations));

-- 3. Users seed data
INSERT INTO users (user_id, username, password_hash, role_id, name, email, phone, user_type, is_active, location_id) VALUES
(1, 'supervisor1', '$2a$10$6XpY3.z9MRCu8mAE1k.Cw.CbHwFYbZ3Kp8r1RH2QVRY.G9ySICIcy', 1, 'Main Supervisor', 'supervisor@lpgco.com', '555-123-4567', 'supervisor', true, 1),
(2, 'driver1', '$2a$10$6XpY3.z9MRCu8mAE1k.Cw.CbHwFYbZ3Kp8r1RH2QVRY.G9ySICIcy', 2, 'John Driver', 'driver1@lpgco.com', '555-987-6543', 'delivery_employee', true, 1),
(3, 'driver2', '$2a$10$6XpY3.z9MRCu8mAE1k.Cw.CbHwFYbZ3Kp8r1RH2QVRY.G9ySICIcy', 2, 'Sarah Driver', 'driver2@lpgco.com', '555-567-8901', 'delivery_employee', true, 2);

-- Reset sequence for users
SELECT setval('users_user_id_seq', (SELECT MAX(user_id) FROM users));

-- The trigger function insert_user_to_subtype() should handle inserting into the specific user type tables

-- 4. User-supervisor relationships
INSERT INTO user_supervisors (user_supervisor_id, user_id, supervisor_id, is_active) VALUES
(1, 2, 1, true), -- John Driver is supervised by Main Supervisor
(2, 3, 1, true); -- Sarah Driver is supervised by Main Supervisor

-- Reset sequence for user_supervisors
SELECT setval('user_supervisors_user_supervisor_id_seq', (SELECT MAX(user_supervisor_id) FROM user_supervisors));

-- 5. User-business location relationships
INSERT INTO user_business_locations (id, user_id, location_id) VALUES
(1, 1, 1), -- Supervisor has access to Main Warehouse
(2, 1, 2), -- Supervisor also has access to North Distribution Center
(3, 2, 1), -- John Driver has access to Main Warehouse
(4, 3, 2); -- Sarah Driver has access to North Distribution Center

-- Reset sequence for user_business_locations
SELECT setval('user_business_locations_id_seq', (SELECT MAX(id) FROM user_business_locations));

-- 6. Products seed data
INSERT INTO products (product_id, name, description, weight_kg, price, is_active) VALUES
(1, 'LPG 25kg', 'Standard 25kg LPG tank for residential use', 25.0, 45.99, true),
(2, 'LPG 40kg', 'Large 40kg LPG tank for commercial/heavy residential use', 40.0, 72.99, true);

-- Reset sequence for products
SELECT setval('products_product_id_seq', (SELECT MAX(product_id) FROM products));

-- 7. Customers seed data
INSERT INTO customers (customer_id, name, email, primary_phone, address, is_active) VALUES
(1, 'John Smith', 'john.smith@email.com', '555-555-0101', '789 Home Lane, Springfield, ST 12345', true),
(2, 'Mary Johnson', 'mary.johnson@email.com', '555-555-0202', '321 House St, Springfield, ST 12345', true),
(3, 'Robert Green', 'robert.green@email.com', '555-555-0303', '654 Dwelling Ave, Shelbyville, ST 23456', true);

-- Reset sequence for customers
SELECT setval('customers_customer_id_seq', (SELECT MAX(customer_id) FROM customers));

-- 8. Customer phones seed data
INSERT INTO customer_phones (phone_id, customer_id, phone_number, is_primary, phone_type) VALUES
(1, 1, '555-555-0101', true, 'mobile'),
(2, 2, '555-555-0202', true, 'mobile'),
(3, 3, '555-555-0303', true, 'home');

-- Reset sequence for customer_phones
SELECT setval('customer_phones_phone_id_seq', (SELECT MAX(phone_id) FROM customer_phones));

-- 9. Tank inventory seed data
INSERT INTO tank_inventory (inventory_id, location_id, product_id, full_tanks_count, empty_tanks_count, last_updated) VALUES
(1, 1, 1, 50, 25, CURRENT_TIMESTAMP), -- Main Warehouse, 25kg tanks
(2, 1, 2, 30, 15, CURRENT_TIMESTAMP), -- Main Warehouse, 40kg tanks
(3, 2, 1, 35, 10, CURRENT_TIMESTAMP), -- North Distribution Center, 25kg tanks
(4, 2, 2, 20, 8, CURRENT_TIMESTAMP);  -- North Distribution Center, 40kg tanks

-- Reset sequence for tank_inventory
SELECT setval('tank_inventory_inventory_id_seq', (SELECT MAX(inventory_id) FROM tank_inventory));

-- 10. Verification status
INSERT INTO inventory_verification_status (status_id, verification_status) VALUES
(1, 'pending'),
(2, 'verified'),
(3, 'rejected');

-- Reset sequence for inventory_verification_status
SELECT setval('inventory_verification_status_status_id_seq', (SELECT MAX(status_id) FROM inventory_verification_status));

-- 11. Deliveries seed data (including past, current, and future deliveries)
INSERT INTO deliveries (
    delivery_id,
    customer_id, 
    delivery_employee_id,
    origin_location_id,
    destination_location_id,
    supervisor_id,
    delivery_status,
    scheduled_date,
    actual_delivery_time,
    is_tank_returned,
    cash_payment_amount
) VALUES
-- Completed delivery yesterday
(1, 1, 2, 3, 3, 1, 'completed', CURRENT_DATE - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day', true, 45.99),
-- Delivery in progress today
(2, 2, 3, 3, 4, 1, 'in_progress', CURRENT_DATE, NULL, false, 45.99),
-- Scheduled for tomorrow
(3, 3, 2, 3, 5, 1, 'scheduled', CURRENT_DATE + INTERVAL '1 day', NULL, false, 72.99),
-- Scheduled for day after tomorrow
(4, 1, 3, 3, 3, 1, 'scheduled', CURRENT_DATE + INTERVAL '2 days', NULL, false, 45.99);

-- Reset sequence for deliveries
SELECT setval('deliveries_delivery_id_seq', (SELECT MAX(delivery_id) FROM deliveries));

-- 12. Delivery status history
INSERT INTO delivery_status_history (
    history_id,
    delivery_id,
    previous_status,
    new_status,
    changed_by,
    notes
) VALUES
(1, 1, 'scheduled', 'in_progress', 2, 'Started delivery'),
(2, 1, 'in_progress', 'completed', 2, 'Successfully delivered'),
(3, 2, 'scheduled', 'in_progress', 3, 'Started delivery');

-- Reset sequence for delivery_status_history
SELECT setval('delivery_status_history_history_id_seq', (SELECT MAX(history_id) FROM delivery_status_history));

-- 13. Invoices and invoice items seed data
INSERT INTO invoices (
    invoice_id,
    delivery_id,
    customer_id,
    accountant_id,
    total_amount,
    payment_status,
    payment_method,
    invoice_date,
    verification_status
) VALUES
(1, 1, 1, NULL, 45.99, 'paid', 'cash', CURRENT_DATE - INTERVAL '1 day', 'verified'),
(2, 2, 2, NULL, 45.99, 'pending', 'cash', CURRENT_DATE, 'pending'),
(3, 3, 3, NULL, 72.99, 'pending', 'cash', CURRENT_DATE + INTERVAL '1 day', 'pending'),
(4, 4, 1, NULL, 45.99, 'pending', 'cash', CURRENT_DATE + INTERVAL '2 days', 'pending');

-- Reset sequence for invoices
SELECT setval('invoices_invoice_id_seq', (SELECT MAX(invoice_id) FROM invoices));

INSERT INTO invoice_items (
    item_id,
    invoice_id,
    product_id,
    quantity,
    unit_price,
    subtotal
) VALUES
(1, 1, 1, 1, 45.99, 45.99), -- 1x 25kg tank for Invoice 1
(2, 2, 1, 1, 45.99, 45.99), -- 1x 25kg tank for Invoice 2
(3, 3, 2, 1, 72.99, 72.99), -- 1x 40kg tank for Invoice 3
(4, 4, 1, 1, 45.99, 45.99); -- 1x 25kg tank for Invoice 4

-- Reset sequence for invoice_items
SELECT setval('invoice_items_item_id_seq', (SELECT MAX(item_id) FROM invoice_items));

-- 14. Tank inventory reports
INSERT INTO tank_inventory_reports (
    report_id,
    business_location_id,
    user_id,
    supervisor_id,
    report_date,
    verification_status,
    notes
) VALUES
(1, 1, 1, 1, CURRENT_DATE - INTERVAL '1 day', 2, 'End of day inventory count'),
(2, 2, 1, 1, CURRENT_DATE - INTERVAL '1 day', 2, 'End of day inventory count'),
(3, 1, 1, 1, CURRENT_DATE, 1, 'Mid-day inventory check');

-- Reset sequence for tank_inventory_reports
SELECT setval('tank_inventory_reports_report_id_seq', (SELECT MAX(report_id) FROM tank_inventory_reports));

INSERT INTO tank_inventory_report_items (
    item_id,
    report_id,
    product_id,
    full_tanks_count,
    empty_tanks_count
) VALUES
(1, 1, 1, 50, 25), -- 25kg tanks at Main Warehouse yesterday
(2, 1, 2, 30, 15), -- 40kg tanks at Main Warehouse yesterday
(3, 2, 1, 35, 10), -- 25kg tanks at North Distribution Center yesterday
(4, 2, 2, 20, 8),  -- 40kg tanks at North Distribution Center yesterday
(5, 3, 1, 48, 27), -- Updated 25kg tanks at Main Warehouse today
(6, 3, 2, 29, 16); -- Updated 40kg tanks at Main Warehouse today

-- Reset sequence for tank_inventory_report_items
SELECT setval('tank_inventory_report_items_item_id_seq', (SELECT MAX(item_id) FROM tank_inventory_report_items));