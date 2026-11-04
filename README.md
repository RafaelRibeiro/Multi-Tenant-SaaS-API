# Multi-Tenant SaaS API

REST API for a multi-tenant SaaS platform built with **Ruby on Rails 7.1**, **PostgreSQL**, **JWT authentication** and **Docker**.

The application allows multiple organizations to use the same platform while keeping their data isolated.

## Technologies

- Ruby on Rails 7.1
- PostgreSQL 16
- JWT authentication
- RSpec
- Docker and Docker Compose

## Features

- Organization management
- User authentication with JWT
- Memberships and organization association
- Role-based access control
- Client management
- Project management
- Organization context and tenant data isolation
- Automated request, model, policy and service tests

## Running locally

### Prerequisites

- Docker Desktop
- Docker Compose

### 1. Clone the repository

```bash
git clone https://github.com/RafaelRibeiro/Multi-Tenant-SaaS-API.git
cd Multi-Tenant-SaaS-API
```

### 2. Configure environment variables

Create a `.env` file based on the example:

```bash
cp .env.example .env
```

Configure the required variables:

```env
DATABASE_PASSWORD=your_database_password
JWT_SECRET_KEY=your_jwt_secret
```

Use your own local values. Do not commit the `.env` file.

### 3. Build and start the application

```bash
docker compose up --build -d
```

### 4. Prepare the database

```bash
docker compose exec web bundle exec rails db:create db:migrate
```

### 5. Run the tests

```bash
docker compose exec web bundle exec rspec
```

## Application

The API runs locally at:

```text
http://localhost:3000
```

## Testing

The project uses RSpec for automated testing of models, controllers, policies, services and API requests.

Current test suite: **113 examples, 0 failures**.

## License

This project is available for educational and portfolio purposes.
