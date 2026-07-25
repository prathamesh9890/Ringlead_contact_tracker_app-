# Ringlead Website

Public marketing site + admin panel for Ringlead, built with React (Vite) and a neomorphic (soft-UI) design system.
This is the frontend half of the MERN stack — it talks to the Express/MongoDB API in [`../backend`](../backend).

## Structure

```
src/
  api/client.js          axios instance, JWT attach + auto-refresh on 401
  context/AuthContext.jsx login/logout, admin session state
  components/ui/          neomorphic primitives: NeoButton, NeoCard, NeoInput, NeoToggle, NeoBadge, Spinner
  components/layout/       PublicLayout + navbar/footer, AdminLayout + sidebar
  components/ProtectedRoute.jsx  guards /admin/* routes (requires role === 'admin')
  pages/public/            Home, Pricing, Contact
  pages/admin/             Login, Dashboard (stats), Users (list/search/edit), UserDetail
  styles/theme.css         neomorphic design tokens (light + dark, prefers-color-scheme aware)
```

## Getting started

```bash
cd website
npm install
cp .env.example .env      # point VITE_API_URL at your backend
npm run dev                # http://localhost:3000
```

The backend must be running (see `../backend/README.md`) with `CORS_ORIGIN` including `http://localhost:3000`.

## Admin access

Only users with `role: "admin"` on the User model can sign in through `/admin/login`. Promote a user to admin
directly in MongoDB (there's no self-serve admin signup):

```js
db.users.updateOne({ email: "you@example.com" }, { $set: { role: "admin" } })
```

## Build

```bash
npm run build      # outputs to dist/
npm run preview
```
