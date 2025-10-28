# BAZI Casino API - Bruno Collection

This folder contains the Bruno API collection for testing the BAZI Casino API.

## What is Bruno?

Bruno is an open-source API client similar to Postman/Insomnia, but stores collections as files in your repository.

- **Website**: https://www.usebruno.com/
- **GitHub**: https://github.com/usebruno/bruno

## Setup

1. **Install Bruno**: Download from [usebruno.com](https://www.usebruno.com/downloads)
2. **Open Collection**: In Bruno, click "Open Collection" and select this `bruno/` folder
3. **Select Environment**: Choose "Local" environment for local development

## Environments

- **Local**: `http://localhost:8080` - For local development
- **Production**: `https://api.bazi.casino` - For production API (when deployed)

## Current Endpoints

### Implemented ✅
- **Health Check** - `GET /health` - Server health status

### Not Yet Implemented ⏳
All other endpoints are defined in the router but return TODO or are commented out.

## Authentication

Authentication is handled by **Better Auth** (integrated in the frontend), not by our Go API directly.

When auth is implemented, requests will include a JWT token in the `Authorization` header:
```
Authorization: Bearer <token>
```

## Usage

1. Start the backend server:
   ```bash
   cd backend
   go run cmd/api/main.go
   ```

2. Open Bruno and select the "Local" environment

3. Run the "Health Check" request to verify the server is running

4. As more endpoints are implemented, add new `.bru` files to test them

## Adding New Requests

Create a new `.bru` file in the appropriate folder:

```bru
meta {
  name: Request Name
  type: http
  seq: 1
}

get {
  url: {{apiUrl}}/endpoint
  body: none
  auth: none
}

docs {
  # Documentation here
}
```
