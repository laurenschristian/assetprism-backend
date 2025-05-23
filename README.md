# AssetPrism Backend

Enterprise-grade IT Asset Management (ITAM) system backend with Supabase integration and MCP (Model Context Protocol) server.

## 🚀 Features

- **Supabase Integration**: PostgreSQL database with real-time subscriptions
- **MCP Server**: AI-powered asset management with direct database access
- **Enterprise Authentication**: Multi-tenant auth with role-based permissions
- **Real-time Updates**: Live asset tracking and compliance monitoring
- **RESTful API**: Clean, documented API endpoints
- **Database Migrations**: Version-controlled schema management
- **Row-Level Security**: Multi-tenant data isolation

## 🛠 Tech Stack

- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **MCP Server**: TypeScript-based AI integration
- **API**: RESTful endpoints with OpenAPI documentation
- **Real-time**: Supabase subscriptions
- **Deployment**: Supabase Edge Functions

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/assetprism-backend.git
cd assetprism-backend

# Install dependencies
npm install

# Install Supabase CLI
npm install -g supabase

# Copy environment variables
cp .env.example .env.local

# Start Supabase locally
supabase start

# Run migrations
supabase db reset
```

## 🔧 Environment Variables

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Database
DATABASE_URL=your_database_url

# MCP Server
MCP_SERVER_PORT=3001
MCP_SERVER_HOST=localhost

# Authentication
JWT_SECRET=your_jwt_secret
```

## 🏗 Project Structure

```
├── supabase/
│   ├── migrations/         # Database migrations
│   ├── functions/         # Edge Functions
│   └── config.toml        # Supabase configuration
├── src/
│   ├── mcp/              # MCP Server implementation
│   ├── types/            # TypeScript definitions
│   ├── utils/            # Helper functions
│   └── lib/              # Database utilities
├── scripts/              # Deployment and utility scripts
└── docs/                 # API documentation
```

## 🗄 Database Schema

### Core Tables
- `organizations` - Multi-tenant organization management
- `users` - User profiles and roles
- `hardware_assets` - Physical asset tracking
- `software_licenses` - Software license management
- `license_assignments` - User/device license assignments
- `audit_logs` - Complete audit trail

### Key Features
- **Row-Level Security (RLS)**: Automatic multi-tenant isolation
- **Real-time subscriptions**: Live updates across clients
- **Full-text search**: Advanced search capabilities
- **JSON columns**: Flexible metadata storage

## 🚦 Available Scripts

- `npm run dev` - Start development environment
- `npm run build` - Build for production
- `npm run migrate` - Run database migrations
- `npm run seed` - Seed database with sample data
- `npm run mcp:dev` - Start MCP server in development
- `npm run test` - Run test suite

## 🤖 MCP Server

The Model Context Protocol server enables AI assistants to:
- Query asset data directly
- Generate compliance reports
- Perform asset analysis
- Execute database operations
- Monitor system health

### MCP Endpoints
- `/mcp/assets` - Asset management operations
- `/mcp/licenses` - Software license operations
- `/mcp/compliance` - Compliance monitoring
- `/mcp/reports` - Report generation

## 🔐 Authentication & Security

### Multi-tenant Architecture
- Organization-based data isolation
- Row-level security policies
- Role-based access control (RBAC)

### Supported Roles
- **Super Admin**: Platform administration
- **Org Admin**: Organization management
- **Asset Manager**: Asset CRUD operations
- **Viewer**: Read-only access

### Security Features
- JWT-based authentication
- API rate limiting
- Input validation and sanitization
- Audit logging for all operations

## 📊 API Documentation

### Core Endpoints

#### Assets
```http
GET /api/v1/assets - List assets
POST /api/v1/assets - Create asset
GET /api/v1/assets/:id - Get asset details
PUT /api/v1/assets/:id - Update asset
DELETE /api/v1/assets/:id - Delete asset
```

#### Software Licenses
```http
GET /api/v1/licenses - List licenses
POST /api/v1/licenses - Create license
GET /api/v1/licenses/:id - Get license details
PUT /api/v1/licenses/:id - Update license
POST /api/v1/licenses/:id/assign - Assign license
```

#### Compliance
```http
GET /api/v1/compliance/summary - Compliance overview
GET /api/v1/compliance/licenses - License compliance
GET /api/v1/compliance/expiring - Expiring items
```

## 🚀 Deployment

### Supabase Setup
1. Create new Supabase project
2. Run migrations: `supabase db push`
3. Deploy Edge Functions: `supabase functions deploy`
4. Configure environment variables

### Production Environment
- Enable SSL/TLS
- Configure backup policies
- Set up monitoring and alerts
- Enable audit logging

## 🧪 Testing

```bash
# Run all tests
npm test

# Run integration tests
npm run test:integration

# Run with coverage
npm run test:coverage
```

## 📈 Monitoring & Analytics

- **Health Checks**: System status monitoring
- **Performance Metrics**: Query performance tracking
- **Audit Logs**: Complete operation history
- **Real-time Dashboards**: System metrics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for new functionality
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 