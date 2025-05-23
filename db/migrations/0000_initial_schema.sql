-- Migration: 0000_initial_schema.sql
-- Description: Sets up the initial tables for AssetPrism MVP.

-- Hardware Asset Management Tables

CREATE TABLE manufacturers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);
CREATE INDEX idx_manufacturers_name ON manufacturers(name);

CREATE TABLE asset_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE asset_models (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    manufacturer_id INTEGER NOT NULL REFERENCES manufacturers(id),
    asset_category_id INTEGER NOT NULL REFERENCES asset_categories(id),
    model_number TEXT UNIQUE,
    specifications TEXT, -- JSON
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    UNIQUE(manufacturer_id, name, model_number)
);
CREATE INDEX idx_asset_models_manufacturer_id ON asset_models(manufacturer_id);
CREATE INDEX idx_asset_models_asset_category_id ON asset_models(asset_category_id);

CREATE TABLE vendors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    contact_person TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE hardware_assets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    asset_tag TEXT UNIQUE,
    serial_number TEXT NOT NULL UNIQUE,
    asset_model_id INTEGER NOT NULL REFERENCES asset_models(id),
    status TEXT NOT NULL DEFAULT 'in_stock',
    purchase_date TEXT,
    purchase_cost REAL,
    po_number TEXT,
    vendor_id INTEGER REFERENCES vendors(id),
    warranty_expiration_date TEXT,
    notes TEXT,
    storage_details TEXT, -- JSON array
    mac_addresses TEXT, -- JSON array
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);
CREATE INDEX idx_hardware_assets_asset_model_id ON hardware_assets(asset_model_id);
CREATE INDEX idx_hardware_assets_status ON hardware_assets(status);
CREATE INDEX idx_hardware_assets_vendor_id ON hardware_assets(vendor_id);

CREATE TABLE departments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    parent_department_id INTEGER REFERENCES departments(id),
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id TEXT UNIQUE,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT,
    department_id INTEGER REFERENCES departments(id),
    role TEXT NOT NULL DEFAULT 'user', -- MVP: 'admin', 'user'
    is_active INTEGER DEFAULT 1,
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);
CREATE INDEX idx_users_employee_id ON users(employee_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);

CREATE TABLE locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state_province TEXT,
    postal_code TEXT,
    country TEXT,
    parent_location_id INTEGER REFERENCES locations(id),
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);
CREATE INDEX idx_locations_parent_location_id ON locations(parent_location_id);

CREATE TABLE hardware_asset_assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hardware_asset_id INTEGER NOT NULL REFERENCES hardware_assets(id),
    assigned_to_user_id INTEGER NOT NULL REFERENCES users(id),
    location_id INTEGER NOT NULL REFERENCES locations(id),
    assignment_date TEXT NOT NULL,
    unassignment_date TEXT,
    notes TEXT,
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);
CREATE INDEX idx_haa_hardware_asset_id ON hardware_asset_assignments(hardware_asset_id);
CREATE INDEX idx_haa_assigned_to_user_id ON hardware_asset_assignments(assigned_to_user_id);
CREATE INDEX idx_haa_location_id ON hardware_asset_assignments(location_id);
CREATE INDEX idx_haa_current_assignments ON hardware_asset_assignments(hardware_asset_id, unassignment_date) WHERE unassignment_date IS NULL;

CREATE TABLE asset_status_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hardware_asset_id INTEGER NOT NULL REFERENCES hardware_assets(id),
    changed_by_user_id INTEGER REFERENCES users(id),
    previous_status TEXT,
    new_status TEXT NOT NULL,
    change_date TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    reason TEXT,
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);
CREATE INDEX idx_ash_hardware_asset_id ON asset_status_history(hardware_asset_id);

-- Software License Management & Catalog Tables

CREATE TABLE publishers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);
CREATE INDEX idx_publishers_name ON publishers(name);

CREATE TABLE software_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE software_titles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    version TEXT,
    publisher_id INTEGER NOT NULL REFERENCES publishers(id),
    software_category_id INTEGER REFERENCES software_categories(id),
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    UNIQUE(name, version, publisher_id)
);
CREATE INDEX idx_software_titles_publisher_id ON software_titles(publisher_id);
CREATE INDEX idx_software_titles_category_id ON software_titles(software_category_id);

CREATE TABLE license_models (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    model_key TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    description TEXT,
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE TABLE software_licenses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    software_title_id INTEGER NOT NULL REFERENCES software_titles(id),
    license_model_id INTEGER NOT NULL REFERENCES license_models(id),
    purchased_units INTEGER NOT NULL,
    available_units INTEGER NOT NULL,
    license_key TEXT,
    usage_rights TEXT,
    purchase_date TEXT,
    purchase_cost REAL,
    vendor_id INTEGER REFERENCES vendors(id),
    subscription_start_date TEXT,
    subscription_end_date TEXT,
    renewal_date TEXT,
    maintenance_expiration_date TEXT,
    notes TEXT,
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);
CREATE INDEX idx_sl_software_title_id ON software_licenses(software_title_id);
CREATE INDEX idx_sl_license_model_id ON software_licenses(license_model_id);
CREATE INDEX idx_sl_vendor_id ON software_licenses(vendor_id);

CREATE TABLE software_license_assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    software_license_id INTEGER NOT NULL REFERENCES software_licenses(id),
    assigned_to_type TEXT NOT NULL CHECK (assigned_to_type IN ('user', 'device')),
    assigned_to_user_id INTEGER REFERENCES users(id),
    assigned_to_hardware_asset_id INTEGER REFERENCES hardware_assets(id),
    assignment_date TEXT NOT NULL,
    unassignment_date TEXT,
    notes TEXT,
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    CHECK ((assigned_to_type = 'user' AND assigned_to_user_id IS NOT NULL AND assigned_to_hardware_asset_id IS NULL) OR 
           (assigned_to_type = 'device' AND assigned_to_hardware_asset_id IS NOT NULL AND assigned_to_user_id IS NULL))
);
CREATE INDEX idx_sla_software_license_id ON software_license_assignments(software_license_id);
CREATE INDEX idx_sla_assigned_to_user_id ON software_license_assignments(assigned_to_user_id);
CREATE INDEX idx_sla_assigned_to_hardware_asset_id ON software_license_assignments(assigned_to_hardware_asset_id);
CREATE INDEX idx_sla_current_user_assignments ON software_license_assignments(software_license_id, assigned_to_user_id, unassignment_date) WHERE unassignment_date IS NULL AND assigned_to_type = 'user';
CREATE INDEX idx_sla_current_device_assignments ON software_license_assignments(software_license_id, assigned_to_hardware_asset_id, unassignment_date) WHERE unassignment_date IS NULL AND assigned_to_type = 'device';

CREATE TABLE installed_software (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    hardware_asset_id INTEGER NOT NULL REFERENCES hardware_assets(id),
    software_title_id INTEGER NOT NULL REFERENCES software_titles(id),
    detected_version TEXT,
    install_date TEXT,
    last_seen_date TEXT,
    discovery_source TEXT,
    created_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    updated_at TEXT DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    UNIQUE(hardware_asset_id, software_title_id, detected_version)
);
CREATE INDEX idx_is_hardware_asset_id ON installed_software(hardware_asset_id);
CREATE INDEX idx_is_software_title_id ON installed_software(software_title_id);

-- Common/Utility Tables

CREATE TABLE audit_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER REFERENCES users(id),
    action TEXT NOT NULL,
    entity_type TEXT,
    entity_id INTEGER,
    change_details TEXT, -- JSON
    timestamp TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
    ip_address TEXT
);
CREATE INDEX idx_al_user_id ON audit_logs(user_id);
CREATE INDEX idx_al_entity_type_id ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_al_timestamp ON audit_logs(timestamp);

-- Seed initial data for some tables

INSERT INTO license_models (model_key, display_name, description) VALUES
('perpetual', 'Perpetual', 'One-time purchase, rights to use indefinitely.'),
('subscription', 'Subscription', 'Time-limited rights, recurring payments.'),
('named_user', 'Named User', 'License assigned to a specific individual.'),
('device_based', 'Device-Based', 'License assigned to a specific device.'),
('concurrent', 'Concurrent User', 'Limited number of simultaneous users allowed.');

-- Default Admin User (example - replace with secure setup)
-- For MVP, this user might be created manually or via a seed script outside migrations initially.
-- If using Cloudflare Access, user management is external primarily.
-- INSERT INTO users (username, email, full_name, role, is_active) VALUES
-- ('admin', 'admin@example.com', 'Admin User', 'admin', 1); 