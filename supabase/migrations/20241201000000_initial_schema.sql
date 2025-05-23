-- Migration: 20241201000000_initial_schema.sql
-- Description: Sets up the initial tables for AssetPrism MVP with Supabase support

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE user_role AS ENUM ('super_admin', 'org_admin', 'asset_manager', 'viewer');
CREATE TYPE assignment_type AS ENUM ('user', 'device');
CREATE TYPE asset_status AS ENUM ('in_stock', 'assigned', 'maintenance', 'retired', 'disposed');
CREATE TYPE license_type AS ENUM ('perpetual', 'subscription', 'named_user', 'device_based', 'concurrent');
CREATE TYPE license_model AS ENUM ('per_user', 'per_device', 'site_license', 'enterprise');

-- Organizations table (multi-tenant support)
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    domain TEXT UNIQUE,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS on organizations
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

-- Users table (extends Supabase auth.users)
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    employee_id TEXT,
    full_name TEXT,
    department_id UUID,
    role user_role DEFAULT 'viewer',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Hardware Asset Management Tables

CREATE TABLE manufacturers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, name)
);

ALTER TABLE manufacturers ENABLE ROW LEVEL SECURITY;

CREATE TABLE asset_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, name)
);

ALTER TABLE asset_categories ENABLE ROW LEVEL SECURITY;

CREATE TABLE asset_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    manufacturer_id UUID NOT NULL REFERENCES manufacturers(id) ON DELETE CASCADE,
    asset_category_id UUID NOT NULL REFERENCES asset_categories(id) ON DELETE CASCADE,
    model_number TEXT,
    specifications JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, manufacturer_id, name, model_number)
);

ALTER TABLE asset_models ENABLE ROW LEVEL SECURITY;

CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    contact_person TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, name)
);

ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;

CREATE TABLE departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    parent_department_id UUID REFERENCES departments(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, name)
);

ALTER TABLE departments ENABLE ROW LEVEL SECURITY;

-- Add foreign key to profiles
ALTER TABLE profiles ADD CONSTRAINT fk_profiles_department 
    FOREIGN KEY (department_id) REFERENCES departments(id);

CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    state_province TEXT,
    postal_code TEXT,
    country TEXT,
    parent_location_id UUID REFERENCES locations(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, name)
);

ALTER TABLE locations ENABLE ROW LEVEL SECURITY;

CREATE TABLE hardware_assets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    asset_tag TEXT,
    serial_number TEXT NOT NULL,
    asset_model_id UUID NOT NULL REFERENCES asset_models(id) ON DELETE CASCADE,
    status asset_status DEFAULT 'in_stock',
    purchase_date DATE,
    purchase_cost DECIMAL(15,2),
    po_number TEXT,
    vendor_id UUID REFERENCES vendors(id),
    warranty_expiration_date DATE,
    notes TEXT,
    storage_details JSONB DEFAULT '[]',
    mac_addresses JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, asset_tag),
    UNIQUE(organization_id, serial_number)
);

ALTER TABLE hardware_assets ENABLE ROW LEVEL SECURITY;

CREATE TABLE hardware_asset_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    hardware_asset_id UUID NOT NULL REFERENCES hardware_assets(id) ON DELETE CASCADE,
    assigned_to_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES locations(id),
    assignment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    unassignment_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE hardware_asset_assignments ENABLE ROW LEVEL SECURITY;

CREATE TABLE asset_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    hardware_asset_id UUID NOT NULL REFERENCES hardware_assets(id) ON DELETE CASCADE,
    changed_by_user_id UUID REFERENCES profiles(id),
    previous_status asset_status,
    new_status asset_status NOT NULL,
    change_date TIMESTAMPTZ DEFAULT NOW(),
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE asset_status_history ENABLE ROW LEVEL SECURITY;

-- Software License Management & Catalog Tables

CREATE TABLE publishers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, name)
);

ALTER TABLE publishers ENABLE ROW LEVEL SECURITY;

CREATE TABLE software_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, name)
);

ALTER TABLE software_categories ENABLE ROW LEVEL SECURITY;

CREATE TABLE software_titles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    version TEXT,
    publisher_id UUID NOT NULL REFERENCES publishers(id) ON DELETE CASCADE,
    software_category_id UUID REFERENCES software_categories(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, name, version, publisher_id)
);

ALTER TABLE software_titles ENABLE ROW LEVEL SECURITY;

CREATE TABLE software_licenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    software_title_id UUID NOT NULL REFERENCES software_titles(id) ON DELETE CASCADE,
    license_type license_type NOT NULL DEFAULT 'subscription',
    license_model license_model NOT NULL DEFAULT 'per_user',
    purchased_units INTEGER NOT NULL DEFAULT 1,
    available_units INTEGER NOT NULL DEFAULT 1,
    license_key TEXT,
    usage_rights TEXT,
    purchase_date DATE,
    purchase_cost DECIMAL(15,2),
    vendor_id UUID REFERENCES vendors(id),
    subscription_start_date DATE,
    subscription_end_date DATE,
    renewal_date DATE,
    maintenance_expiration_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE software_licenses ENABLE ROW LEVEL SECURITY;

CREATE TABLE software_license_assignments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    software_license_id UUID NOT NULL REFERENCES software_licenses(id) ON DELETE CASCADE,
    assigned_to_type assignment_type NOT NULL,
    assigned_to_user_id UUID REFERENCES profiles(id),
    assigned_to_hardware_asset_id UUID REFERENCES hardware_assets(id),
    assignment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    unassignment_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CHECK (
        (assigned_to_type = 'user' AND assigned_to_user_id IS NOT NULL AND assigned_to_hardware_asset_id IS NULL) OR 
        (assigned_to_type = 'device' AND assigned_to_hardware_asset_id IS NOT NULL AND assigned_to_user_id IS NULL)
    )
);

ALTER TABLE software_license_assignments ENABLE ROW LEVEL SECURITY;

CREATE TABLE installed_software (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    hardware_asset_id UUID NOT NULL REFERENCES hardware_assets(id) ON DELETE CASCADE,
    software_title_id UUID NOT NULL REFERENCES software_titles(id) ON DELETE CASCADE,
    detected_version TEXT,
    install_date DATE,
    last_seen_date DATE,
    discovery_source TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(organization_id, hardware_asset_id, software_title_id, detected_version)
);

ALTER TABLE installed_software ENABLE ROW LEVEL SECURITY;

-- Audit Logs
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES profiles(id),
    action TEXT NOT NULL,
    entity_type TEXT,
    entity_id UUID,
    change_details JSONB DEFAULT '{}',
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    ip_address INET
);

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Create indexes for performance
CREATE INDEX idx_profiles_organization_id ON profiles(organization_id);
CREATE INDEX idx_profiles_role ON profiles(role);

CREATE INDEX idx_manufacturers_organization_id ON manufacturers(organization_id);
CREATE INDEX idx_asset_categories_organization_id ON asset_categories(organization_id);
CREATE INDEX idx_asset_models_organization_id ON asset_models(organization_id);
CREATE INDEX idx_asset_models_manufacturer_id ON asset_models(manufacturer_id);
CREATE INDEX idx_asset_models_category_id ON asset_models(asset_category_id);

CREATE INDEX idx_vendors_organization_id ON vendors(organization_id);
CREATE INDEX idx_departments_organization_id ON departments(organization_id);
CREATE INDEX idx_locations_organization_id ON locations(organization_id);

CREATE INDEX idx_hardware_assets_organization_id ON hardware_assets(organization_id);
CREATE INDEX idx_hardware_assets_model_id ON hardware_assets(asset_model_id);
CREATE INDEX idx_hardware_assets_status ON hardware_assets(status);
CREATE INDEX idx_hardware_assets_vendor_id ON hardware_assets(vendor_id);

CREATE INDEX idx_haa_organization_id ON hardware_asset_assignments(organization_id);
CREATE INDEX idx_haa_hardware_asset_id ON hardware_asset_assignments(hardware_asset_id);
CREATE INDEX idx_haa_assigned_to_user_id ON hardware_asset_assignments(assigned_to_user_id);
CREATE INDEX idx_haa_location_id ON hardware_asset_assignments(location_id);
CREATE INDEX idx_haa_current_assignments ON hardware_asset_assignments(hardware_asset_id, unassignment_date) WHERE unassignment_date IS NULL;

CREATE INDEX idx_ash_organization_id ON asset_status_history(organization_id);
CREATE INDEX idx_ash_hardware_asset_id ON asset_status_history(hardware_asset_id);

CREATE INDEX idx_publishers_organization_id ON publishers(organization_id);
CREATE INDEX idx_software_categories_organization_id ON software_categories(organization_id);
CREATE INDEX idx_software_titles_organization_id ON software_titles(organization_id);
CREATE INDEX idx_software_titles_publisher_id ON software_titles(publisher_id);

CREATE INDEX idx_sl_organization_id ON software_licenses(organization_id);
CREATE INDEX idx_sl_software_title_id ON software_licenses(software_title_id);
CREATE INDEX idx_sl_vendor_id ON software_licenses(vendor_id);

CREATE INDEX idx_sla_organization_id ON software_license_assignments(organization_id);
CREATE INDEX idx_sla_software_license_id ON software_license_assignments(software_license_id);
CREATE INDEX idx_sla_assigned_to_user_id ON software_license_assignments(assigned_to_user_id);
CREATE INDEX idx_sla_assigned_to_hardware_asset_id ON software_license_assignments(assigned_to_hardware_asset_id);
CREATE INDEX idx_sla_current_user_assignments ON software_license_assignments(software_license_id, assigned_to_user_id, unassignment_date) WHERE unassignment_date IS NULL AND assigned_to_type = 'user';
CREATE INDEX idx_sla_current_device_assignments ON software_license_assignments(software_license_id, assigned_to_hardware_asset_id, unassignment_date) WHERE unassignment_date IS NULL AND assigned_to_type = 'device';

CREATE INDEX idx_is_organization_id ON installed_software(organization_id);
CREATE INDEX idx_is_hardware_asset_id ON installed_software(hardware_asset_id);
CREATE INDEX idx_is_software_title_id ON installed_software(software_title_id);

CREATE INDEX idx_al_organization_id ON audit_logs(organization_id);
CREATE INDEX idx_al_user_id ON audit_logs(user_id);
CREATE INDEX idx_al_entity_type_id ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_al_timestamp ON audit_logs(timestamp);

-- Row Level Security Policies

-- Organizations: Users can only see their own organization
CREATE POLICY "Users can view own organization" ON organizations
    FOR SELECT USING (auth.uid() IN (
        SELECT id FROM profiles WHERE organization_id = organizations.id
    ));

-- Profiles: Users can view profiles in their organization
CREATE POLICY "Users can view profiles in own organization" ON profiles
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (id = auth.uid());

-- Apply organization-scoped policies to all tables
CREATE POLICY "Organization scoped select" ON manufacturers
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON asset_categories
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON asset_models
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON vendors
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON departments
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON locations
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON hardware_assets
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON hardware_asset_assignments
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON asset_status_history
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON publishers
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON software_categories
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON software_titles
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON software_licenses
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON software_license_assignments
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON installed_software
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

CREATE POLICY "Organization scoped select" ON audit_logs
    FOR SELECT USING (organization_id IN (
        SELECT organization_id FROM profiles WHERE id = auth.uid()
    ));

-- Admin users can perform all operations
-- (Add more specific policies based on roles as needed)

-- Create trigger functions for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to all tables with updated_at column
CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_manufacturers_updated_at BEFORE UPDATE ON manufacturers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_asset_categories_updated_at BEFORE UPDATE ON asset_categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_asset_models_updated_at BEFORE UPDATE ON asset_models FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vendors_updated_at BEFORE UPDATE ON vendors FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON departments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_locations_updated_at BEFORE UPDATE ON locations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_hardware_assets_updated_at BEFORE UPDATE ON hardware_assets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_hardware_asset_assignments_updated_at BEFORE UPDATE ON hardware_asset_assignments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_publishers_updated_at BEFORE UPDATE ON publishers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_software_categories_updated_at BEFORE UPDATE ON software_categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_software_titles_updated_at BEFORE UPDATE ON software_titles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_software_licenses_updated_at BEFORE UPDATE ON software_licenses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_software_license_assignments_updated_at BEFORE UPDATE ON software_license_assignments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_installed_software_updated_at BEFORE UPDATE ON installed_software FOR EACH ROW EXECUTE FUNCTION update_updated_at_column(); 