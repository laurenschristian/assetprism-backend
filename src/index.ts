import { Hono } from 'hono';
import { cors } from 'hono/cors';

// Define the environment type for Cloudflare Workers
type Env = {
  Bindings: {
    DB: D1Database;
  };
};

const app = new Hono<Env>();

// Add CORS middleware
app.use('/*', cors());

// Health check endpoint
app.get('/health', (c) => {
  return c.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// API v1 routes
const api = new Hono<Env>();

// Hardware Assets endpoints
api.get('/hardware-assets', async (c) => {
  try {
    const { page = '1', limit = '25', status, assetType, sortBy = 'created_at', sortOrder = 'desc' } = c.req.query();
    
    const pageNum = parseInt(page);
    const limitNum = Math.min(parseInt(limit), 100);
    const offset = (pageNum - 1) * limitNum;
    
    let query = `
      SELECT 
        ha.id,
        ha.asset_tag,
        ha.serial_number,
        ha.status,
        ha.purchase_date,
        ha.purchase_cost,
        ha.warranty_expiration_date,
        ha.notes,
        ha.created_at,
        ha.updated_at,
        am.name as model_name,
        am.model_number,
        m.name as manufacturer_name,
        ac.name as category_name
      FROM hardware_assets ha
      JOIN asset_models am ON ha.asset_model_id = am.id
      JOIN manufacturers m ON am.manufacturer_id = m.id
      JOIN asset_categories ac ON am.asset_category_id = ac.id
    `;
    
    const conditions = [];
    const params = [];
    
    if (status) {
      conditions.push('ha.status = ?');
      params.push(status);
    }
    
    if (assetType) {
      conditions.push('ac.name = ?');
      params.push(assetType);
    }
    
    if (conditions.length > 0) {
      query += ' WHERE ' + conditions.join(' AND ');
    }
    
    const allowedSortFields = ['created_at', 'updated_at', 'purchase_date', 'status', 'serial_number'];
    const sortField = allowedSortFields.includes(sortBy) ? sortBy : 'created_at';
    const order = sortOrder.toLowerCase() === 'asc' ? 'ASC' : 'DESC';
    query += ` ORDER BY ha.${sortField} ${order}`;
    
    query += ` LIMIT ? OFFSET ?`;
    params.push(limitNum, offset);
    
    const { results } = await c.env.DB.prepare(query).bind(...params).all();
    
    let countQuery = `
      SELECT COUNT(*) as total
      FROM hardware_assets ha
      JOIN asset_models am ON ha.asset_model_id = am.id
      JOIN asset_categories ac ON am.asset_category_id = ac.id
    `;
    
    if (conditions.length > 0) {
      countQuery += ' WHERE ' + conditions.join(' AND ');
    }
    
    const countParams = params.slice(0, -2);
    const { results: countResults } = await c.env.DB.prepare(countQuery).bind(...countParams).all();
    const total = Number(countResults[0]?.total) || 0;
    const totalPages = Math.ceil(total / limitNum);
    
    return c.json({
      data: results,
      pagination: {
        currentPage: pageNum,
        totalPages,
        totalItems: total,
        itemsPerPage: limitNum
      }
    });
  } catch (error: any) {
    console.error('Error fetching hardware assets:', error);
    return c.json({ 
      error: {
        code: 'FETCH_ERROR',
        message: 'Failed to fetch hardware assets',
        details: error.message
      }
    }, 500);
  }
});

api.get('/hardware-assets/:id', async (c) => {
  try {
    const id = c.req.param('id');
    
    const query = `
      SELECT 
        ha.*,
        am.name as model_name,
        am.model_number,
        am.specifications,
        m.name as manufacturer_name,
        ac.name as category_name,
        v.name as vendor_name,
        v.contact_person as vendor_contact,
        v.email as vendor_email
      FROM hardware_assets ha
      JOIN asset_models am ON ha.asset_model_id = am.id
      JOIN manufacturers m ON am.manufacturer_id = m.id
      JOIN asset_categories ac ON am.asset_category_id = ac.id
      LEFT JOIN vendors v ON ha.vendor_id = v.id
      WHERE ha.id = ?
    `;
    
    const { results } = await c.env.DB.prepare(query).bind(id).all();
    
    if (results.length === 0) {
      return c.json({ 
        error: {
          code: 'NOT_FOUND',
          message: 'Hardware asset not found'
        }
      }, 404);
    }
    
    const assignmentQuery = `
      SELECT 
        haa.*,
        u.full_name as assigned_user_name,
        u.email as assigned_user_email,
        l.name as location_name
      FROM hardware_asset_assignments haa
      JOIN users u ON haa.assigned_to_user_id = u.id
      JOIN locations l ON haa.location_id = l.id
      WHERE haa.hardware_asset_id = ? AND haa.unassignment_date IS NULL
    `;
    
    const { results: assignments } = await c.env.DB.prepare(assignmentQuery).bind(id).all();
    
    const asset = results[0];
    asset.current_assignment = assignments[0] || null;
    
    return c.json(asset);
  } catch (error: any) {
    console.error('Error fetching hardware asset:', error);
    return c.json({ 
      error: {
        code: 'FETCH_ERROR',
        message: 'Failed to fetch hardware asset',
        details: error.message
      }
    }, 500);
  }
});

api.post('/hardware-assets', async (c) => {
  try {
    const body = await c.req.json();
    const {
      make,
      model,
      serialNumber,
      assetTag,
      assetType,
      cpu,
      ram,
      storage,
      macAddresses,
      purchaseDate,
      purchaseCost,
      poNumber,
      vendorId,
      warrantyExpirationDate,
      initialStatus = 'in_stock',
      modelNumber,
      notes
    } = body;
    
    if (!make || !model || !serialNumber || !assetType) {
      return c.json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Missing required fields',
          details: ['make', 'model', 'serialNumber', 'assetType are required']
        }
      }, 400);
    }
    
    // Get or create manufacturer
    let manufacturerResult = await c.env.DB.prepare(
      'SELECT id FROM manufacturers WHERE name = ?'
    ).bind(make).first();
    
    if (!manufacturerResult) {
      manufacturerResult = await c.env.DB.prepare(
        'INSERT INTO manufacturers (name) VALUES (?) RETURNING id'
      ).bind(make).first();
    }
    
    if (!manufacturerResult) {
      throw new Error('Failed to create manufacturer');
    }
    
    const manufacturerId = manufacturerResult.id;
    
    // Get or create asset category
    let categoryResult = await c.env.DB.prepare(
      'SELECT id FROM asset_categories WHERE name = ?'
    ).bind(assetType).first();
    
    if (!categoryResult) {
      categoryResult = await c.env.DB.prepare(
        'INSERT INTO asset_categories (name) VALUES (?) RETURNING id'
      ).bind(assetType).first();
    }
    
    if (!categoryResult) {
      throw new Error('Failed to create asset category');
    }
    
    const categoryId = categoryResult.id;
    
    // Create specifications object
    const specifications = JSON.stringify({
      cpu: cpu || null,
      ram: ram || null,
      storage: storage || null
    });
    
    // Get or create asset model
    let modelResult = await c.env.DB.prepare(
      'SELECT id FROM asset_models WHERE name = ? AND manufacturer_id = ? AND model_number = ?'
    ).bind(model, manufacturerId, modelNumber || '').first();
    
    if (!modelResult) {
      modelResult = await c.env.DB.prepare(
        'INSERT INTO asset_models (name, manufacturer_id, asset_category_id, model_number, specifications) VALUES (?, ?, ?, ?, ?) RETURNING id'
      ).bind(model, manufacturerId, categoryId, modelNumber || '', specifications).first();
    }
    
    if (!modelResult) {
      throw new Error('Failed to create asset model');
    }
    
    const modelId = modelResult.id;
    
    // Create hardware asset
    const assetResult = await c.env.DB.prepare(`
      INSERT INTO hardware_assets (
        asset_tag, serial_number, asset_model_id, status, purchase_date, 
        purchase_cost, po_number, vendor_id, warranty_expiration_date, 
        notes, mac_addresses
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING *
    `).bind(
      assetTag || null,
      serialNumber,
      modelId,
      initialStatus,
      purchaseDate || null,
      purchaseCost || null,
      poNumber || null,
      vendorId || null,
      warrantyExpirationDate || null,
      notes || null,
      macAddresses ? JSON.stringify(macAddresses) : null
    ).first();
    
    if (!assetResult) {
      throw new Error('Failed to create hardware asset');
    }
    
    // Log the creation in audit log
    await c.env.DB.prepare(`
      INSERT INTO audit_logs (user_id, entity_type, entity_id, action, change_details)
      VALUES (?, ?, ?, ?, ?)
    `).bind(
      null,
      'hardware_asset',
      assetResult.id,
      'CREATE',
      JSON.stringify({ created: body })
    ).run();
    
    return c.json(assetResult, 201);
  } catch (error: any) {
    console.error('Error creating hardware asset:', error);
    return c.json({ 
      error: {
        code: 'CREATE_ERROR',
        message: 'Failed to create hardware asset',
        details: error.message
      }
    }, 500);
  }
});

// Supporting endpoints
api.get('/users', async (c) => {
  try {
    const { results } = await c.env.DB.prepare(`
      SELECT id, employee_id, full_name, email, department_id, is_active
      FROM users 
      WHERE is_active = 1
      ORDER BY full_name
    `).all();
    
    return c.json(results);
  } catch (error: any) {
    console.error('Error fetching users:', error);
    return c.json({ 
      error: {
        code: 'FETCH_ERROR',
        message: 'Failed to fetch users',
        details: error.message
      }
    }, 500);
  }
});

api.get('/locations', async (c) => {
  try {
    const { results } = await c.env.DB.prepare(`
      SELECT id, name, address_line1, city, state_province, country
      FROM locations 
      ORDER BY name
    `).all();
    
    return c.json(results);
  } catch (error: any) {
    console.error('Error fetching locations:', error);
    return c.json({ 
      error: {
        code: 'FETCH_ERROR',
        message: 'Failed to fetch locations',
        details: error.message
      }
    }, 500);
  }
});

api.get('/manufacturers', async (c) => {
  try {
    const { results } = await c.env.DB.prepare(`
      SELECT id, name
      FROM manufacturers 
      ORDER BY name
    `).all();
    
    return c.json(results);
  } catch (error: any) {
    console.error('Error fetching manufacturers:', error);
    return c.json({ 
      error: {
        code: 'FETCH_ERROR',
        message: 'Failed to fetch manufacturers',
        details: error.message
      }
    }, 500);
  }
});

api.get('/asset-categories', async (c) => {
  try {
    const { results } = await c.env.DB.prepare(`
      SELECT id, name
      FROM asset_categories 
      ORDER BY name
    `).all();
    
    return c.json(results);
  } catch (error: any) {
    console.error('Error fetching asset categories:', error);
    return c.json({ 
      error: {
        code: 'FETCH_ERROR',
        message: 'Failed to fetch asset categories',
        details: error.message
      }
    }, 500);
  }
});

// Mount API routes under /api/v1
app.route('/api/v1', api);

// Root endpoint
app.get('/', (c) => {
  return c.json({
    message: 'AssetPrism API',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      api: '/api/v1'
    }
  });
});

export default app; 