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
- `src/models/User.js` — exists, has `email` and `name` fields, no `password` field yet
- `package.json` — `bcrypt`, `jsonwebtoken` not installed

**Dispatch plan:** `install-deps` → `update-user-model` → [`create-auth-routes`, `create-auth-middleware`] → `mount-routes` → `run-tests`

---

**Agent brief example (one of several):**

**`create-auth-routes`** (parallel with `create-auth-middleware`)
- Objective: Create `src/routes/auth.js` with `POST /register` and `POST /login`
- Context: uses `User` model, `bcrypt` for hashing, `jsonwebtoken` for token signing
- Constraints: `JWT_SECRET` from `process.env.JWT_SECRET`; token expiry 24h; return `{ token }` on success
- Output: `src/routes/auth.js`

Each agent receives: **Objective**, **Context**, **Constraints**, **Output spec**. HERALD never passes raw user input.
