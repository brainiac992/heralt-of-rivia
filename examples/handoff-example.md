# HERALD Handoff — Example

This is an example of what HERALD produces before any agent executes.

---

**Raw user input:**
> "Add a user authentication system to my Express app"

---

## HERALD Handoff

**Intent:** Add JWT-based user authentication (register, login, protected routes) to an existing Express.js application.

**Goal:** Working `/auth/register` and `/auth/login` endpoints returning signed JWTs, plus middleware that protects existing routes — all tests passing.

**Constraints:**
- Must not modify existing route logic
- Use existing User model if present, otherwise create one
- Passwords must be hashed (bcrypt)
- Tokens expire in 24h
- No third-party auth services (Auth0, Firebase, etc.)

**Context loaded:**
- `src/app.js` — Express entry point, middleware stack identified
- `src/routes/` — 3 existing route files, none auth-related
- `src/models/User.js` — exists, has `email` and `name` fields, no `password` field yet
- `package.json` — `express`, `mongoose` present; `bcrypt`, `jsonwebtoken` not installed
- No existing auth middleware found

**Dependencies:**
- Packages: `bcrypt`, `jsonwebtoken` (must install first)
- Files to create: `src/routes/auth.js`, `src/middleware/authenticate.js`
- Files to modify: `src/models/User.js` (add `password` field), `src/app.js` (mount auth routes)
- No conflicts detected

**Dispatch plan:** `install-deps` → `update-user-model` → [`create-auth-routes`, `create-auth-middleware`] → `mount-routes` → `run-tests`

---

**Agent briefs:**

**`install-deps`**
- Objective: Install `bcrypt` and `jsonwebtoken`
- Command: `npm install bcrypt jsonwebtoken`
- Output: updated `package.json` and `package-lock.json`

**`update-user-model`**
- Objective: Add `password` field to `src/models/User.js`
- Context: existing schema has `email` (String, required, unique) and `name` (String)
- Constraints: field must be `String`, `required: true`; do not add hashing logic to the model
- Output: updated `src/models/User.js`

**`create-auth-routes`** (parallel with `create-auth-middleware`)
- Objective: Create `src/routes/auth.js` with `POST /register` and `POST /login`
- Context: uses `User` model, `bcrypt` for hashing, `jsonwebtoken` for token signing
- Constraints: `JWT_SECRET` from `process.env.JWT_SECRET`; token expiry 24h; return `{ token }` on success
- Output: `src/routes/auth.js`

**`create-auth-middleware`** (parallel with `create-auth-routes`)
- Objective: Create `src/middleware/authenticate.js` — verifies Bearer token, attaches `req.user`
- Constraints: reject with `401` if token missing or invalid; do not throw, use `res.status(401).json()`
- Output: `src/middleware/authenticate.js`

**`mount-routes`**
- Objective: Mount auth router in `src/app.js`
- Constraints: add `app.use('/auth', require('./routes/auth'))` after existing middleware, before existing routes
- Output: updated `src/app.js`

**`run-tests`**
- Objective: Run test suite, confirm no regressions
- Command: `npm test`
- Output: pass/fail report
