# DegreePlus

Initial implementation for Feature 1 and Feature 2 from `Database plan.md`.

## Included Features

- Login authentication with JWT.
- Student registration endpoint with BCrypt password hashing.
- Academic progress tracking with course attempts, retake history, CGPA, completed credits, and completed semester counts.
- Course eligibility checks using recursive prerequisites and minimum completed-credit rules.
- Minimal Next.js and Tailwind CSS UI for login, progress, history, adding attempts, and eligibility.

## Manual Database Setup

Run the SQL in `sql/schema.sql` manually in MySQL. No migration tool is used.

The SQL schema now follows the provided schema diagram table-for-table, including `USER`, `STUDENT`, `ADVISOR`, `ADMIN`, `FACULTY`, `COURSE`, `COURSE_SECTION`, `Days`, `SEMESTER_PLAN`, `CONTAINS_SECTION`, `WISHLIST_PERIOD`, `STUDENT_WISHLIST`, `SELECTS_WISHLIST_COURSE`, `RISK_ALERT`, `ADVISING_MESSAGE`, `REQUIRES`, and `TAKES`.

`USER` does not store a `Role` column because the diagram does not show one. The backend derives the user's role from the matching subtype table.

Demo login after seeding:

- Email: `student@degreeplus.test`
- Password: `password123`

## Backend

Install Maven if it is not already available, then run:

```bash
cd backend
mvn spring-boot:run
```

Environment variables:

- `DB_URL`, default `jdbc:mysql://localhost:3306/degreeplus?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC`
- `DB_USERNAME`, default `root`
- `DB_PASSWORD`, default empty
- `JWT_SECRET`, use a long random string in real use

## Frontend

Install Node.js, then run:

```bash
cd frontend
npm install
npm run dev
```

The frontend expects the backend at `http://localhost:8080`. Override with:

```bash
NEXT_PUBLIC_API_BASE_URL=http://localhost:8080 npm run dev
```
