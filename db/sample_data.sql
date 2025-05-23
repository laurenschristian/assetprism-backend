-- Sample data for AssetPrism development and testing

-- Insert sample manufacturers
INSERT INTO manufacturers (name) VALUES 
('Dell'),
('HP'),
('Apple'),
('Lenovo'),
('Microsoft'),
('ASUS');

-- Insert sample asset categories
INSERT INTO asset_categories (name) VALUES 
('Laptop'),
('Desktop'),
('Monitor'),
('Server'),
('Network Equipment'),
('Tablet'),
('Phone');

-- Insert sample vendors
INSERT INTO vendors (name, contact_person, email, phone) VALUES 
('TechSupply Corp', 'John Smith', 'john@techsupply.com', '555-0123'),
('IT Solutions Inc', 'Jane Doe', 'jane@itsolutions.com', '555-0456'),
('Hardware Direct', 'Bob Johnson', 'bob@hardwaredirect.com', '555-0789');

-- Insert sample departments
INSERT INTO departments (name) VALUES 
('Engineering'),
('Marketing'),
('Sales'),
('HR'),
('Finance'),
('IT');

-- Insert sample locations
INSERT INTO locations (name, address_line1, city, state_province, country) VALUES 
('Headquarters', '123 Main St', 'San Francisco', 'CA', 'USA'),
('East Coast Office', '456 Oak Ave', 'New York', 'NY', 'USA'),
('Remote Office', '789 Pine St', 'Austin', 'TX', 'USA'),
('Data Center', '321 Tech Blvd', 'Seattle', 'WA', 'USA');

-- Insert sample users
INSERT INTO users (employee_id, username, email, full_name, department_id, role, is_active) VALUES 
('EMP001', 'jdoe', 'john.doe@company.com', 'John Doe', 1, 'user', 1),
('EMP002', 'asmith', 'alice.smith@company.com', 'Alice Smith', 1, 'user', 1),
('EMP003', 'bwilson', 'bob.wilson@company.com', 'Bob Wilson', 2, 'user', 1),
('EMP004', 'cjones', 'carol.jones@company.com', 'Carol Jones', 3, 'user', 1),
('EMP005', 'admin', 'admin@company.com', 'System Administrator', 6, 'admin', 1);

-- Insert sample asset models
INSERT INTO asset_models (name, manufacturer_id, asset_category_id, model_number, specifications) VALUES 
('Latitude 7490', 1, 1, 'L7490', '{"cpu": "Intel i7-8650U", "ram": "16GB DDR4", "storage": "512GB SSD"}'),
('XPS 13', 1, 1, 'XPS13-9310', '{"cpu": "Intel i7-1165G7", "ram": "16GB DDR4", "storage": "1TB SSD"}'),
('EliteBook 850', 2, 1, 'EB850G8', '{"cpu": "Intel i5-1135G7", "ram": "8GB DDR4", "storage": "256GB SSD"}'),
('MacBook Pro', 3, 1, 'MBP14-M1', '{"cpu": "Apple M1 Pro", "ram": "16GB", "storage": "512GB SSD"}'),
('ThinkPad X1 Carbon', 4, 1, 'X1C-Gen9', '{"cpu": "Intel i7-1165G7", "ram": "16GB DDR4", "storage": "1TB SSD"}'),
('OptiPlex 7090', 1, 2, 'OP7090', '{"cpu": "Intel i7-11700", "ram": "16GB DDR4", "storage": "512GB SSD"}'),
('Surface Studio', 5, 2, 'SS2021', '{"cpu": "Intel i7-11370H", "ram": "32GB DDR4", "storage": "1TB SSD"}'),
('UltraSharp 27', 1, 3, 'U2720Q', '{"resolution": "4K 3840x2160", "size": "27 inch", "panel": "IPS"}');

-- Insert sample hardware assets
INSERT INTO hardware_assets (asset_tag, serial_number, asset_model_id, status, purchase_date, purchase_cost, vendor_id, warranty_expiration_date, notes) VALUES 
('LAP001', 'DL001234567', 1, 'in_stock', '2023-01-15', 1299.99, 1, '2026-01-15', 'New laptop for engineering team'),
('LAP002', 'DL001234568', 1, 'deployed', '2023-01-15', 1299.99, 1, '2026-01-15', 'Assigned to developer'),
('LAP003', 'HP001234567', 3, 'in_stock', '2023-02-10', 899.99, 2, '2026-02-10', 'Backup laptop'),
('LAP004', 'AP001234567', 4, 'deployed', '2023-03-01', 2399.99, 2, '2026-03-01', 'Design team laptop'),
('LAP005', 'LN001234567', 5, 'in_repair', '2023-01-20', 1599.99, 1, '2026-01-20', 'Keyboard replacement needed'),
('DSK001', 'DL002234567', 6, 'deployed', '2023-02-15', 999.99, 1, '2026-02-15', 'Engineering workstation'),
('DSK002', 'MS002234567', 7, 'in_stock', '2023-03-10', 2999.99, 2, '2026-03-10', 'High-end workstation'),
('MON001', 'DL003234567', 8, 'deployed', '2023-01-25', 399.99, 1, '2026-01-25', '4K monitor for developer'),
('MON002', 'DL003234568', 8, 'in_stock', '2023-01-25', 399.99, 1, '2026-01-25', 'Spare monitor');

-- Insert sample publishers
INSERT INTO publishers (name) VALUES 
('Microsoft'),
('Adobe'),
('JetBrains'),
('Atlassian'),
('Slack Technologies'),
('Zoom');

-- Insert sample software categories
INSERT INTO software_categories (name) VALUES 
('Operating System'),
('Productivity'),
('Development Tools'),
('Design'),
('Communication'),
('Security');

-- Insert sample software titles
INSERT INTO software_titles (name, version, publisher_id, software_category_id) VALUES 
('Windows 11 Pro', '11.0', 1, 1),
('Microsoft 365', '2023', 1, 2),
('Visual Studio Professional', '2022', 1, 3),
('Creative Cloud', '2023', 2, 4),
('IntelliJ IDEA', '2023.3', 3, 3),
('Jira Software', 'Cloud', 4, 2),
('Slack', 'Enterprise Grid', 5, 5),
('Zoom Pro', '5.17', 6, 5);

-- Insert sample software licenses (using existing license model IDs: 1=perpetual, 2=subscription, 3=named_user, 4=device_based, 5=concurrent)
INSERT INTO software_licenses (software_title_id, license_model_id, purchased_units, available_units, purchase_date, purchase_cost, vendor_id, subscription_end_date) VALUES 
(1, 3, 100, 85, '2023-01-01', 15000.00, 1, '2024-12-31'),
(2, 2, 50, 35, '2023-01-01', 12500.00, 1, '2024-12-31'),
(3, 3, 10, 7, '2023-02-01', 5500.00, 1, '2024-02-01'),
(4, 3, 20, 15, '2023-01-15', 12000.00, 2, '2024-01-15'),
(5, 3, 5, 3, '2023-03-01', 1500.00, 2, '2024-03-01'),
(6, 5, 25, 20, '2023-01-01', 3750.00, 2, '2024-12-31'),
(7, 3, 100, 80, '2023-01-01', 8000.00, 1, '2024-12-31'),
(8, 3, 50, 40, '2023-01-01', 7500.00, 1, '2024-12-31');

-- Insert sample hardware asset assignments
INSERT INTO hardware_asset_assignments (hardware_asset_id, assigned_to_user_id, location_id, assignment_date) VALUES 
(2, 1, 1, '2023-01-20'),  -- LAP002 to John Doe at HQ
(4, 2, 1, '2023-03-05'),  -- LAP004 to Alice Smith at HQ
(6, 1, 1, '2023-02-20'),  -- DSK001 to John Doe at HQ
(8, 2, 1, '2023-02-01');  -- MON001 to Alice Smith at HQ

-- Insert sample software license assignments
INSERT INTO software_license_assignments (software_license_id, assigned_to_type, assigned_to_user_id, assignment_date) VALUES 
(1, 'user', 1, '2023-01-25'),  -- Windows 11 to John Doe
(1, 'user', 2, '2023-01-25'),  -- Windows 11 to Alice Smith
(2, 'user', 1, '2023-01-25'),  -- Office 365 to John Doe
(2, 'user', 2, '2023-01-25'),  -- Office 365 to Alice Smith
(3, 'user', 1, '2023-02-10'),  -- Visual Studio to John Doe
(4, 'user', 2, '2023-02-01'),  -- Creative Cloud to Alice Smith
(7, 'user', 1, '2023-02-01'),  -- Slack to John Doe
(7, 'user', 2, '2023-02-01'),  -- Slack to Alice Smith
(8, 'user', 1, '2023-02-01'),  -- Zoom to John Doe
(8, 'user', 2, '2023-02-01');  -- Zoom to Alice Smith 