# 💸 SplitTab v2 — Setup Guide

> Bill splitting app with cloud sync, email auth, and native app builds (Android, iOS, Windows, Mac)

---

## 📋 What's in this repo

```
SplitTab/
├── index.html              ← Main app (edit SUPABASE_URL + SUPABASE_ANON_KEY here)
├── www/                    ← Built output (auto-generated, don't edit)
├── supabase/
│   └── schema.sql          ← Run once to set up your database
├── electron/
│   └── main.js             ← Desktop app entry point
├── scripts/
│   └── build.js            ← Build step (copies index.html → www/)
├── capacitor.config.json   ← Mobile app config
├── package.json
└── .github/workflows/
    └── build.yml           ← Auto-build exe/apk on GitHub push
```

---

## 🌐 OPTION A — Supabase Cloud (Free, no server needed)

### Step 1 — Create Supabase project
1. Go to [supabase.com](https://supabase.com) → **New Project**
2. Choose a name, region, and strong database password → **Create**
3. Wait ~2 minutes for setup

### Step 2 — Set up the database
1. In your Supabase project → **SQL Editor** → **New Query**
2. Paste the contents of `supabase/schema.sql`
3. Click **Run**

### Step 3 — Configure auth
1. **Authentication → Providers → Email** → make sure it's **enabled**
2. For development: uncheck **"Confirm email"** so users can log in immediately
3. For production: leave it checked (sends a confirmation email)
4. **Authentication → URL Configuration** → set **Site URL** to your hosted URL

### Step 4 — Get your API keys
1. **Project Settings → API**
2. Copy:
   - **Project URL** (e.g. `https://abcdefgh.supabase.co`)
   - **anon / public key** (starts with `eyJ...`)

### Step 5 — Add keys to index.html
Open `index.html`, find lines near the top of `<script>`:
```js
const SUPABASE_URL      = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```
Replace with your actual values.

### Step 6 — Host the HTML
Pick any free host — drag & drop `index.html`:
- **Netlify**: [netlify.com](https://netlify.com) → **Add new site → Deploy manually** → drag file
- **Vercel**: `npx vercel` in this folder
- **GitHub Pages**: push to repo → Settings → Pages → Deploy from branch

---

## 🐳 OPTION B — Self-Hosted Supabase (Docker, your own server)

### Prerequisites
- A Linux server (VPS, home server, etc.)
- Docker + Docker Compose installed

### Step 1 — Clone Supabase
```bash
git clone --depth 1 https://github.com/supabase/supabase
cd supabase/docker
cp .env.example .env
```

### Step 2 — Configure .env
Edit `.env` — the critical fields:
```env
POSTGRES_PASSWORD=your-super-secret-db-password
JWT_SECRET=your-super-secret-jwt-secret-at-least-32-chars
ANON_KEY=          # generate at: https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys
SERVICE_ROLE_KEY=  # same tool
SITE_URL=https://your-domain.com
```
> Generate ANON_KEY and SERVICE_ROLE_KEY using the JWT tool at the link above — paste your JWT_SECRET in.

### Step 3 — Start Supabase
```bash
docker compose up -d
```
Supabase Studio will be at `http://your-server-ip:8000`

### Step 4 — Set up the database
- Open Studio → SQL Editor → paste `supabase/schema.sql` → Run

### Step 5 — Add keys to index.html
Your self-hosted keys:
```js
const SUPABASE_URL      = 'http://your-server-ip:8000';
const SUPABASE_ANON_KEY = 'your-generated-anon-key';
```

---

## 📱 Building native apps (Android APK / iOS / Windows exe)

### One-time setup
```bash
npm install
npm run build          # copies index.html → www/
```

### Android APK
```bash
npm run cap:add:android      # first time only
npm run cap:sync
npm run cap:open:android     # opens Android Studio
```
In Android Studio: **Build → Generate Signed APK** or **Build → Build Bundle**

> **Requirements**: Android Studio + Android SDK installed

### iOS (Mac only)
```bash
npm run cap:add:ios          # first time only
npm run cap:sync
npm run cap:open:ios         # opens Xcode
```
In Xcode: **Product → Archive** → upload to App Store or export IPA

> **Requirements**: Mac + Xcode + Apple Developer account ($99/yr for App Store)

### Windows .exe
```bash
npm run electron:build:win
```
Output: `dist-electron/SplitTab Setup.exe`

### macOS .dmg
```bash
npm run electron:build:mac
```
Output: `dist-electron/SplitTab.dmg`

---

## 🤖 Automated builds via GitHub Actions

Push your code to GitHub, then:
```bash
git tag v2.0.0
git push --tags
```
GitHub Actions will automatically build Windows `.exe` and Android `.apk` and make them available as downloadable artifacts under **Actions → your workflow run → Artifacts**.

---

## 🔄 Migrating existing local data

If you used the old single-file SplitTab and have data in localStorage:
1. Open the old HTML file in your browser
2. Open DevTools → Console, paste:
```js
const data = {
  trips: localStorage.getItem('splittab_trips'),
  categories: localStorage.getItem('splittab_categories')
};
console.log(JSON.stringify(data));
```
3. Copy the output
4. Log into the new SplitTab → DevTools → Console, paste:
```js
const data = /* paste output */;
if(data.trips) localStorage.setItem('splittab_trips', data.trips);
```
Then use the **📂 Data Manager** → Import to load it into your cloud account.

---

## 🛡️ Security notes

- Each user's data is protected by **Row Level Security** — no user can read another's data
- The `anon` key in the HTML is safe to be public — it has zero permissions without a valid user JWT
- For production, enable email confirmation in Supabase Auth settings
- Consider setting up a **custom SMTP provider** in Supabase for reliable email delivery
