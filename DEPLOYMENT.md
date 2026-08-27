# DegreePlus Cloud Deployment Guide

This guide moves the whole project online so it can be opened from a university lab PC.

## Target Setup

- Database: Aiven MySQL
- Backend: Render Web Service, or Railway if you prefer
- Frontend: Vercel

You will still keep the local project files, but the running app will use cloud services.

## Step 1: Create Cloud MySQL

1. Create a free Aiven MySQL service.
2. Copy the service connection values:
   - Host
   - Port
   - Database name
   - Username
   - Password
3. Open Aiven's SQL console or connect with MySQL Workbench.
4. Run the full SQL from `sql/schema.sql`.
5. Confirm:

```sql
USE degreeplus;
SHOW TABLES;
SELECT * FROM `USER`;
SELECT * FROM COURSE;
SELECT * FROM TAKES;
```

## Step 2: Push Project To GitHub

Most hosting platforms deploy from GitHub.

From the project root:

```bash
git init
git add .
git commit -m "Initial DegreePlus implementation"
git branch -M main
git remote add origin YOUR_GITHUB_REPO_URL
git push -u origin main
```

Do not commit real passwords. Use hosting environment variables for secrets.

## Step 3: Deploy Backend

On Render:

1. Create a new Web Service from your GitHub repo.
2. Set root directory:

```text
backend
```

3. Set build command:

```bash
mvn clean package
```

4. Set start command:

```bash
java -jar target/degreeplus-backend-0.0.1-SNAPSHOT.jar
```

5. Add environment variables:

```text
DB_URL=jdbc:mysql://YOUR_AIVEN_HOST:YOUR_AIVEN_PORT/YOUR_AIVEN_DATABASE?sslMode=REQUIRED&serverTimezone=UTC
DB_USERNAME=YOUR_AIVEN_USERNAME
DB_PASSWORD=YOUR_AIVEN_PASSWORD
JWT_SECRET=replace-with-a-long-random-secret-at-least-64-characters-long
JWT_EXPIRATION_MINUTES=120
CORS_ALLOWED_ORIGINS=http://localhost:3000
```

After deployment, Render gives you a backend URL like:

```text
https://degreeplus-backend.onrender.com
```

Test it:

```text
https://degreeplus-backend.onrender.com/api/auth/login
```

Opening this directly in the browser may show an error because login requires POST. That is normal.

## Step 4: Deploy Frontend

On Vercel:

1. Import the same GitHub repo.
2. Set root directory:

```text
frontend
```

3. Add environment variable:

```text
NEXT_PUBLIC_API_BASE_URL=https://YOUR_BACKEND_DOMAIN
```

4. Deploy.

Vercel gives you a frontend URL like:

```text
https://degreeplus.vercel.app
```

## Step 5: Update Backend CORS

After Vercel gives you the frontend URL, go back to the backend hosting environment variables and update:

```text
CORS_ALLOWED_ORIGINS=http://localhost:3000,https://YOUR_FRONTEND_DOMAIN
```

Redeploy the backend after changing this.

## Step 6: Final Test From Any PC

Open the Vercel frontend URL from any browser and login:

```text
student@degreeplus.test
password123
```

Confirm:

- Login works.
- Progress dashboard loads.
- Eligibility list loads.
- Adding a course attempt updates progress.

## Common Problems

If login works locally but not on Vercel, check `NEXT_PUBLIC_API_BASE_URL`.

If the frontend loads but API calls fail, check `CORS_ALLOWED_ORIGINS`.

If the backend fails to start, check `DB_URL`, `DB_USERNAME`, and `DB_PASSWORD`.

If Aiven pauses the free database after inactivity, open Aiven and power the service back on.
