# my_diary Backend (minimal)

This folder contains a minimal Node.js + Express backend that connects to a PostgreSQL database using the schema provided.

Quick start

1. Ensure `.env` exists in this folder and set values (the example uses DB_PASSWORD=Kiet2004 and DB_DATABASE=Health). By default the backend listens on port 60491; you can change `PORT` in `.env` if needed.

2. Install dependencies:

```powershell
cd backend
npm install
```

3. Create the database and run the migration SQL (you can use psql):

```powershell
# assuming psql is available and user has privileges
psql -h $env:DB_HOST -U $env:DB_USER -d postgres -f migrations/schema.sql
# or connect to the Health DB and run the file
psql -h localhost -U postgres -d Health -f migrations/schema.sql
```

4. Start the server (defaults to port 60491):

```powershell
npm start
```

Endpoints

- GET /health  (e.g. http://localhost:60491/health)
- GET /users
- GET /users/:id
- POST /users  (body: { full_name?, email, password, age?, gender?, height_cm?, weight_kg? })

Notes

- The project intentionally keeps secrets out of the repo; use `.env` for real credentials.
- For production, use migrations tooling (e.g. node-pg-migrate, knex, or Flyway) and stronger password policies.

