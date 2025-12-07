# Turf Backend API

Express.js REST API for the Turf booking platform with Supabase database integration.

## Setup

### Prerequisites
- Node.js 20+
- Supabase project

### Installation

```bash
npm install
```

### Environment Variables

Create `.env` file with:
```env
NODE_ENV=development
PORT=3000
API=/api
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
JWT_SECRET=your_jwt_secret
```

### Development

```bash
npm run dev
```

Server runs on `http://localhost:3000`

### Production

```bash
npm start
```

## API Documentation

Swagger UI available at `/api/docs`

## Deployment

Deployed on AWS Elastic Beanstalk (us-east-1)
- Production URL: `http://turf-backend-env.eba-wkdqipjt.us-east-1.elasticbeanstalk.com`
- Health check: `/api/health`

## Features

- JWT authentication
- Supabase integration
- Swagger API documentation
- CORS support
- Health monitoring

## Tech Stack

- **Framework**: Express.js
- **Database**: Supabase (PostgreSQL)
- **Auth**: JWT
- **Validation**: Joi
- **Documentation**: Swagger UI
