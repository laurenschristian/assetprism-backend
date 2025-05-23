#!/bin/bash

# AssetPrism API Test Script
echo "🧪 AssetPrism API Test Script"
echo "================================"

API_BASE="http://localhost:8787"

echo ""
echo "1️⃣ Testing Health Endpoint..."
curl -s "$API_BASE/health" | jq '.' || echo "❌ Health check failed"

echo ""
echo "2️⃣ Testing Root API Endpoint..."
curl -s "$API_BASE/" | jq '.' || echo "❌ Root endpoint failed"

echo ""
echo "3️⃣ Testing Hardware Assets List..."
curl -s "$API_BASE/api/v1/hardware-assets?limit=5" | jq '.' || echo "❌ Hardware assets list failed"

echo ""
echo "4️⃣ Testing Get Single Hardware Asset..."
curl -s "$API_BASE/api/v1/hardware-assets/1" | jq '.' || echo "❌ Single asset fetch failed"

echo ""
echo "5️⃣ Testing Users Endpoint..."
curl -s "$API_BASE/api/v1/users" | jq '.' || echo "❌ Users endpoint failed"

echo ""
echo "6️⃣ Testing Locations Endpoint..."
curl -s "$API_BASE/api/v1/locations" | jq '.' || echo "❌ Locations endpoint failed"

echo ""
echo "7️⃣ Testing Manufacturers Endpoint..."
curl -s "$API_BASE/api/v1/manufacturers" | jq '.' || echo "❌ Manufacturers endpoint failed"

echo ""
echo "8️⃣ Testing Asset Categories Endpoint..."
curl -s "$API_BASE/api/v1/asset-categories" | jq '.' || echo "❌ Asset categories endpoint failed"

echo ""
echo "9️⃣ Testing Hardware Assets Filtering..."
curl -s "$API_BASE/api/v1/hardware-assets?status=deployed" | jq '.data | length' || echo "❌ Filtering failed"

echo ""
echo "🔟 Testing Hardware Asset Creation..."
curl -s -X POST "$API_BASE/api/v1/hardware-assets" \
  -H "Content-Type: application/json" \
  -d '{
    "make": "Dell",
    "model": "Test Laptop",
    "serialNumber": "TEST123456",
    "assetType": "Laptop",
    "cpu": "Intel i5",
    "ram": "8GB",
    "purchaseDate": "2023-12-01",
    "purchaseCost": 999.99,
    "notes": "Test asset created via API"
  }' | jq '.' || echo "❌ Asset creation failed"

echo ""
echo "1️⃣1️⃣ Testing Software Licenses List..."
curl -s "$API_BASE/api/v1/software-licenses?limit=5" | jq '.' || echo "❌ Software licenses list failed"

echo ""
echo "1️⃣2️⃣ Testing Get Single Software License..."
curl -s "$API_BASE/api/v1/software-licenses/1" | jq '.' || echo "❌ Single license fetch failed"

echo ""
echo "1️⃣3️⃣ Testing Software Titles Endpoint..."
curl -s "$API_BASE/api/v1/software-titles" | jq '.' || echo "❌ Software titles endpoint failed"

echo ""
echo "1️⃣4️⃣ Testing Publishers Endpoint..."
curl -s "$API_BASE/api/v1/publishers" | jq '.' || echo "❌ Publishers endpoint failed"

echo ""
echo "1️⃣5️⃣ Testing License Models Endpoint..."
curl -s "$API_BASE/api/v1/license-models" | jq '.' || echo "❌ License models endpoint failed"

echo ""
echo "1️⃣6️⃣ Testing Software License Creation..."
curl -s -X POST "$API_BASE/api/v1/software-licenses" \
  -H "Content-Type: application/json" \
  -d '{
    "softwareTitleId": 1,
    "licenseModelId": 3,
    "purchasedUnits": 10,
    "purchaseDate": "2023-12-01",
    "purchaseCost": 2000.00,
    "notes": "Test license created via API"
  }' | jq '.' || echo "❌ License creation failed"

echo ""
echo "1️⃣7️⃣ Testing Software License Assignment..."
curl -s -X POST "$API_BASE/api/v1/software-licenses/1/assignments" \
  -H "Content-Type: application/json" \
  -d '{
    "assignedToType": "user",
    "assignedToUserId": 3,
    "assignmentDate": "2023-12-01"
  }' | jq '.' || echo "❌ License assignment failed"

echo ""
echo "✅ API Test Complete!"
echo "================================" 