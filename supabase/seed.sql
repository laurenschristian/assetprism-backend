-- Supabase seed data for AssetPrism development and testing
-- Run this after the initial migration to populate sample data

-- Create a demo organization
INSERT INTO organizations (id, name, domain, settings) VALUES 
('550e8400-e29b-41d4-a716-446655440000', 'Demo Corporation', 'demo.com', '{"timezone": "America/Los_Angeles", "currency": "USD"}');

-- Store the organization ID for reference
DO $$
DECLARE
    org_id UUID := '550e8400-e29b-41d4-a716-446655440000';
BEGIN
    -- Insert sample manufacturers
    INSERT INTO manufacturers (id, organization_id, name) VALUES 
    ('550e8400-e29b-41d4-a716-446655440001', org_id, 'Dell'),
    ('550e8400-e29b-41d4-a716-446655440002', org_id, 'HP'),
    ('550e8400-e29b-41d4-a716-446655440003', org_id, 'Apple'),
    ('550e8400-e29b-41d4-a716-446655440004', org_id, 'Lenovo'),
    ('550e8400-e29b-41d4-a716-446655440005', org_id, 'Microsoft'),
    ('550e8400-e29b-41d4-a716-446655440006', org_id, 'ASUS');

    -- Insert sample asset categories
    INSERT INTO asset_categories (id, organization_id, name) VALUES 
    ('550e8400-e29b-41d4-a716-446655440010', org_id, 'Laptop'),
    ('550e8400-e29b-41d4-a716-446655440011', org_id, 'Desktop'),
    ('550e8400-e29b-41d4-a716-446655440012', org_id, 'Monitor'),
    ('550e8400-e29b-41d4-a716-446655440013', org_id, 'Server'),
    ('550e8400-e29b-41d4-a716-446655440014', org_id, 'Network Equipment'),
    ('550e8400-e29b-41d4-a716-446655440015', org_id, 'Tablet'),
    ('550e8400-e29b-41d4-a716-446655440016', org_id, 'Phone');

    -- Insert sample vendors
    INSERT INTO vendors (id, organization_id, name, contact_person, email, phone) VALUES 
    ('550e8400-e29b-41d4-a716-446655440020', org_id, 'TechSupply Corp', 'John Smith', 'john@techsupply.com', '555-0123'),
    ('550e8400-e29b-41d4-a716-446655440021', org_id, 'IT Solutions Inc', 'Jane Doe', 'jane@itsolutions.com', '555-0456'),
    ('550e8400-e29b-41d4-a716-446655440022', org_id, 'Hardware Direct', 'Bob Johnson', 'bob@hardwaredirect.com', '555-0789');

    -- Insert sample departments
    INSERT INTO departments (id, organization_id, name) VALUES 
    ('550e8400-e29b-41d4-a716-446655440030', org_id, 'Engineering'),
    ('550e8400-e29b-41d4-a716-446655440031', org_id, 'Marketing'),
    ('550e8400-e29b-41d4-a716-446655440032', org_id, 'Sales'),
    ('550e8400-e29b-41d4-a716-446655440033', org_id, 'HR'),
    ('550e8400-e29b-41d4-a716-446655440034', org_id, 'Finance'),
    ('550e8400-e29b-41d4-a716-446655440035', org_id, 'IT');

    -- Insert sample locations
    INSERT INTO locations (id, organization_id, name, address_line1, city, state_province, country) VALUES 
    ('550e8400-e29b-41d4-a716-446655440040', org_id, 'Headquarters', '123 Main St', 'San Francisco', 'CA', 'USA'),
    ('550e8400-e29b-41d4-a716-446655440041', org_id, 'East Coast Office', '456 Oak Ave', 'New York', 'NY', 'USA'),
    ('550e8400-e29b-41d4-a716-446655440042', org_id, 'Remote Office', '789 Pine St', 'Austin', 'TX', 'USA'),
    ('550e8400-e29b-41d4-a716-446655440043', org_id, 'Data Center', '321 Tech Blvd', 'Seattle', 'WA', 'USA');

    -- Note: User profiles will be created when users sign up through Supabase Auth
    -- This is just for reference - in production, these would be created via the auth flow
    -- INSERT INTO profiles (id, organization_id, employee_id, full_name, department_id, role, is_active) VALUES 
    -- ('550e8400-e29b-41d4-a716-446655440050', org_id, 'EMP001', 'John Doe', '550e8400-e29b-41d4-a716-446655440030', 'asset_manager', true),
    -- ('550e8400-e29b-41d4-a716-446655440051', org_id, 'EMP002', 'Alice Smith', '550e8400-e29b-41d4-a716-446655440030', 'viewer', true);

    -- Insert sample asset models
    INSERT INTO asset_models (id, organization_id, name, manufacturer_id, asset_category_id, model_number, specifications) VALUES 
    ('550e8400-e29b-41d4-a716-446655440060', org_id, 'Latitude 7490', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440010', 'L7490', '{"cpu": "Intel i7-8650U", "ram": "16GB DDR4", "storage": "512GB SSD"}'),
    ('550e8400-e29b-41d4-a716-446655440061', org_id, 'XPS 13', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440010', 'XPS13-9310', '{"cpu": "Intel i7-1165G7", "ram": "16GB DDR4", "storage": "1TB SSD"}'),
    ('550e8400-e29b-41d4-a716-446655440062', org_id, 'EliteBook 850', '550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440010', 'EB850G8', '{"cpu": "Intel i5-1135G7", "ram": "8GB DDR4", "storage": "256GB SSD"}'),
    ('550e8400-e29b-41d4-a716-446655440063', org_id, 'MacBook Pro', '550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440010', 'MBP14-M1', '{"cpu": "Apple M1 Pro", "ram": "16GB", "storage": "512GB SSD"}'),
    ('550e8400-e29b-41d4-a716-446655440064', org_id, 'ThinkPad X1 Carbon', '550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440010', 'X1C-Gen9', '{"cpu": "Intel i7-1165G7", "ram": "16GB DDR4", "storage": "1TB SSD"}'),
    ('550e8400-e29b-41d4-a716-446655440065', org_id, 'OptiPlex 7090', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440011', 'OP7090', '{"cpu": "Intel i7-11700", "ram": "16GB DDR4", "storage": "512GB SSD"}'),
    ('550e8400-e29b-41d4-a716-446655440066', org_id, 'Surface Studio', '550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440011', 'SS2021', '{"cpu": "Intel i7-11370H", "ram": "32GB DDR4", "storage": "1TB SSD"}'),
    ('550e8400-e29b-41d4-a716-446655440067', org_id, 'UltraSharp 27', '550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440012', 'U2720Q', '{"resolution": "4K 3840x2160", "size": "27 inch", "panel": "IPS"}');

    -- Insert sample hardware assets
    INSERT INTO hardware_assets (id, organization_id, asset_tag, serial_number, asset_model_id, status, purchase_date, purchase_cost, vendor_id, warranty_expiration_date, notes) VALUES 
    ('550e8400-e29b-41d4-a716-446655440070', org_id, 'LAP001', 'DL001234567', '550e8400-e29b-41d4-a716-446655440060', 'in_stock', '2023-01-15', 1299.99, '550e8400-e29b-41d4-a716-446655440020', '2026-01-15', 'New laptop for engineering team'),
    ('550e8400-e29b-41d4-a716-446655440071', org_id, 'LAP002', 'DL001234568', '550e8400-e29b-41d4-a716-446655440060', 'assigned', '2023-01-15', 1299.99, '550e8400-e29b-41d4-a716-446655440020', '2026-01-15', 'Assigned to developer'),
    ('550e8400-e29b-41d4-a716-446655440072', org_id, 'LAP003', 'HP001234567', '550e8400-e29b-41d4-a716-446655440062', 'in_stock', '2023-02-10', 899.99, '550e8400-e29b-41d4-a716-446655440021', '2026-02-10', 'Backup laptop'),
    ('550e8400-e29b-41d4-a716-446655440073', org_id, 'LAP004', 'AP001234567', '550e8400-e29b-41d4-a716-446655440063', 'assigned', '2023-03-01', 2399.99, '550e8400-e29b-41d4-a716-446655440021', '2026-03-01', 'Design team laptop'),
    ('550e8400-e29b-41d4-a716-446655440074', org_id, 'LAP005', 'LN001234567', '550e8400-e29b-41d4-a716-446655440064', 'maintenance', '2023-01-20', 1599.99, '550e8400-e29b-41d4-a716-446655440020', '2026-01-20', 'Keyboard replacement needed'),
    ('550e8400-e29b-41d4-a716-446655440075', org_id, 'DSK001', 'DL002234567', '550e8400-e29b-41d4-a716-446655440065', 'assigned', '2023-02-15', 999.99, '550e8400-e29b-41d4-a716-446655440020', '2026-02-15', 'Engineering workstation'),
    ('550e8400-e29b-41d4-a716-446655440076', org_id, 'DSK002', 'MS002234567', '550e8400-e29b-41d4-a716-446655440066', 'in_stock', '2023-03-10', 2999.99, '550e8400-e29b-41d4-a716-446655440021', '2026-03-10', 'High-end workstation'),
    ('550e8400-e29b-41d4-a716-446655440077', org_id, 'MON001', 'DL003234567', '550e8400-e29b-41d4-a716-446655440067', 'assigned', '2023-01-25', 399.99, '550e8400-e29b-41d4-a716-446655440020', '2026-01-25', '4K monitor for developer'),
    ('550e8400-e29b-41d4-a716-446655440078', org_id, 'MON002', 'DL003234568', '550e8400-e29b-41d4-a716-446655440067', 'in_stock', '2023-01-25', 399.99, '550e8400-e29b-41d4-a716-446655440020', '2026-01-25', 'Spare monitor');

    -- Insert sample publishers
    INSERT INTO publishers (id, organization_id, name) VALUES 
    ('550e8400-e29b-41d4-a716-446655440080', org_id, 'Microsoft'),
    ('550e8400-e29b-41d4-a716-446655440081', org_id, 'Adobe'),
    ('550e8400-e29b-41d4-a716-446655440082', org_id, 'JetBrains'),
    ('550e8400-e29b-41d4-a716-446655440083', org_id, 'Atlassian'),
    ('550e8400-e29b-41d4-a716-446655440084', org_id, 'Slack Technologies'),
    ('550e8400-e29b-41d4-a716-446655440085', org_id, 'Zoom');

    -- Insert sample software categories
    INSERT INTO software_categories (id, organization_id, name) VALUES 
    ('550e8400-e29b-41d4-a716-446655440090', org_id, 'Operating System'),
    ('550e8400-e29b-41d4-a716-446655440091', org_id, 'Productivity'),
    ('550e8400-e29b-41d4-a716-446655440092', org_id, 'Development Tools'),
    ('550e8400-e29b-41d4-a716-446655440093', org_id, 'Design'),
    ('550e8400-e29b-41d4-a716-446655440094', org_id, 'Communication'),
    ('550e8400-e29b-41d4-a716-446655440095', org_id, 'Security');

    -- Insert sample software titles
    INSERT INTO software_titles (id, organization_id, name, version, publisher_id, software_category_id) VALUES 
    ('550e8400-e29b-41d4-a716-446655440100', org_id, 'Windows 11 Pro', '11.0', '550e8400-e29b-41d4-a716-446655440080', '550e8400-e29b-41d4-a716-446655440090'),
    ('550e8400-e29b-41d4-a716-446655440101', org_id, 'Microsoft 365', '2023', '550e8400-e29b-41d4-a716-446655440080', '550e8400-e29b-41d4-a716-446655440091'),
    ('550e8400-e29b-41d4-a716-446655440102', org_id, 'Visual Studio Professional', '2022', '550e8400-e29b-41d4-a716-446655440080', '550e8400-e29b-41d4-a716-446655440092'),
    ('550e8400-e29b-41d4-a716-446655440103', org_id, 'Creative Cloud', '2023', '550e8400-e29b-41d4-a716-446655440081', '550e8400-e29b-41d4-a716-446655440093'),
    ('550e8400-e29b-41d4-a716-446655440104', org_id, 'IntelliJ IDEA', '2023.3', '550e8400-e29b-41d4-a716-446655440082', '550e8400-e29b-41d4-a716-446655440092'),
    ('550e8400-e29b-41d4-a716-446655440105', org_id, 'Jira Software', 'Cloud', '550e8400-e29b-41d4-a716-446655440083', '550e8400-e29b-41d4-a716-446655440091'),
    ('550e8400-e29b-41d4-a716-446655440106', org_id, 'Slack', 'Enterprise Grid', '550e8400-e29b-41d4-a716-446655440084', '550e8400-e29b-41d4-a716-446655440094'),
    ('550e8400-e29b-41d4-a716-446655440107', org_id, 'Zoom Pro', '5.17', '550e8400-e29b-41d4-a716-446655440085', '550e8400-e29b-41d4-a716-446655440094');

    -- Insert sample software licenses
    INSERT INTO software_licenses (id, organization_id, software_title_id, license_type, license_model, purchased_units, available_units, purchase_date, purchase_cost, vendor_id, subscription_end_date) VALUES 
    ('550e8400-e29b-41d4-a716-446655440110', org_id, '550e8400-e29b-41d4-a716-446655440100', 'named_user', 'per_user', 100, 85, '2023-01-01', 15000.00, '550e8400-e29b-41d4-a716-446655440020', '2024-12-31'),
    ('550e8400-e29b-41d4-a716-446655440111', org_id, '550e8400-e29b-41d4-a716-446655440101', 'subscription', 'per_user', 50, 35, '2023-01-01', 12500.00, '550e8400-e29b-41d4-a716-446655440020', '2024-12-31'),
    ('550e8400-e29b-41d4-a716-446655440112', org_id, '550e8400-e29b-41d4-a716-446655440102', 'named_user', 'per_user', 10, 7, '2023-02-01', 5500.00, '550e8400-e29b-41d4-a716-446655440020', '2024-02-01'),
    ('550e8400-e29b-41d4-a716-446655440113', org_id, '550e8400-e29b-41d4-a716-446655440103', 'named_user', 'per_user', 20, 15, '2023-01-15', 12000.00, '550e8400-e29b-41d4-a716-446655440021', '2024-01-15'),
    ('550e8400-e29b-41d4-a716-446655440114', org_id, '550e8400-e29b-41d4-a716-446655440104', 'named_user', 'per_user', 5, 3, '2023-03-01', 1500.00, '550e8400-e29b-41d4-a716-446655440021', '2024-03-01'),
    ('550e8400-e29b-41d4-a716-446655440115', org_id, '550e8400-e29b-41d4-a716-446655440105', 'concurrent', 'per_user', 25, 20, '2023-01-01', 3750.00, '550e8400-e29b-41d4-a716-446655440021', '2024-12-31'),
    ('550e8400-e29b-41d4-a716-446655440116', org_id, '550e8400-e29b-41d4-a716-446655440106', 'named_user', 'per_user', 100, 80, '2023-01-01', 8000.00, '550e8400-e29b-41d4-a716-446655440020', '2024-12-31'),
    ('550e8400-e29b-41d4-a716-446655440117', org_id, '550e8400-e29b-41d4-a716-446655440107', 'named_user', 'per_user', 50, 40, '2023-01-01', 7500.00, '550e8400-e29b-41d4-a716-446655440020', '2024-12-31');

    -- Note: Hardware asset assignments and software license assignments would be added
    -- after user profiles are created through the authentication flow

END $$; 