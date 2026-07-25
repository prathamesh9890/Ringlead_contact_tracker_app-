# Ringlead API

Node.js + Express + MongoDB (Mongoose) + JWT backend for the Ringlead app.

## Setup

```bash
cd backend
npm install
cp .env.example .env   # then fill in MONGODB_URI and JWT secrets
npm run dev
```

Requires a MongoDB instance — either install MongoDB Community Server locally
(`mongodb://127.0.0.1:27017/ringlead`) or create a free cluster on
[MongoDB Atlas](https://www.mongodb.com/atlas) and use its connection string.

## Structure

MVC-style layout:

- `src/models` — Mongoose schemas
- `src/controllers` — request handlers (business logic)
- `src/routes` — Express routers + input validation, wired to controllers
- `src/middlewares` — auth (JWT), admin role check, validation, centralized error handling
- `src/utils` — ApiError/ApiResponse response shapes, asyncHandler, JWT + password helpers
- `src/config` — env loading and MongoDB connection

## API

All endpoints are under `/api`. See the auth/user/subscription/admin route
files for the full request/response shape of each one.

- `POST /api/auth/register` — { email, password, businessName, phone? }
- `POST /api/auth/login` — { email, password }
- `POST /api/auth/refresh` — { refreshToken }
- `POST /api/auth/logout` — { refreshToken }
- `GET /api/users/me` (auth required)
- `PATCH /api/users/me` (auth required) — { businessName?, phone? }
- `GET /api/subscription/me` (auth required)
- `PATCH /api/subscription/me` (auth required) — { plan } — placeholder until
  Razorpay is wired up; don't expose this to end users unguarded in production
- `GET /api/admin/users` (admin only) — ?page&limit&search
- `GET /api/admin/users/:id` (admin only)
- `PATCH /api/admin/users/:id` (admin only) — { subscriptionPlan?, isActive? }
- `GET /api/admin/stats` (admin only) — includes `newContactMessages`
- `POST /api/contact` — { name, email, message } — public, rate-limited (website contact form)
- `GET /api/admin/contacts` (admin only) — ?page&limit&status
- `GET /api/admin/contacts/:id` (admin only)
- `PATCH /api/admin/contacts/:id` (admin only) — { status: 'new' | 'resolved' }

To create the first admin account, register normally through `/api/auth/register`
then flip that user's `role` to `"admin"` directly in MongoDB.

## Not included yet

- Razorpay payment integration (the subscription update endpoint is a
  placeholder for it)
- The admin panel UI itself — this is only the API it will call
- Wiring the Flutter app's Login screen to this API (it currently still uses
  its own local UI-only stub)
