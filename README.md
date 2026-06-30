# 💸 SplitTab

Split bills with your group. Cloud sync via Supabase. Ships as Web, Windows EXE, and Android APK.

---

## Stack

| Layer | Tool | Why |
|---|---|---|
| Web | Plain HTML + GitHub Pages | Zero build, free hosting |
| Desktop (Windows) | **Tauri v2** | ~5 MB installer vs Electron's ~150 MB |
| Mobile (Android) | **PWABuilder / Bubblewrap** | Wraps live PWA as TWA — no Android Studio or Gradle needed |
| iOS | PWA (Add to Home Screen) | Safari → Share → Add to Home Screen |
| Database | Supabase | Free tier, real-time, auth built-in |

---

## Quick Start (Web only)

1. Go to `supabase.com` → create a project called `splittab`
2. Run `supabase/schema.sql` in the SQL Editor
3. Copy your **Project URL** and **anon key** from Project Settings → API
4. Open `index.html`, find the top of the `<script>` block, and replace:

```js
const SUPABASE_URL      = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

5. Push to GitHub, enable GitHub Pages → live at `https://vpradhap.github.io/splittab`

---

## Building the Windows installer

Push a tag to trigger GitHub Actions:

```bash
git tag v1.0.0
git push origin main --tags
```

Actions → completed run → Artifacts → **SplitTab-Windows**

Contains two installer types:
- `SplitTab_1.0.0_x64-setup.exe` — NSIS wizard installer (Next → Install → Finish)
- `SplitTab_1.0.0_x64_en-US.msi` — Windows Installer (.msi) wizard

**WebView2 note**: Required at runtime. Pre-installed on all Windows 11 machines and Windows 10 machines updated since late 2020. If missing, the installer will automatically download it (controlled by `"webviewInstallMode": "downloadBootstrapper"` in `tauri.conf.json`).

---

## Building the Android APK (100% GitHub Actions — no local commands)

**Why this is different:** bubblewrap's password prompts require a real terminal (TTY) and cannot be automated in any CI system — that's a hard limitation, not a config issue. So this project doesn't use bubblewrap at all for Android. Instead, `android-twa/` is a small, hand-authored Android project using Google's official `androidbrowserhelper` TWA library — the same library bubblewrap generates code around, just without the broken interactive wrapper. It's already included in this zip. You never run anything locally.

### Step 1 — Generate your signing keystore (GitHub Actions, one-time)

1. Push/commit this repo to GitHub first (web UI commit is fine — see GitHub's "Upload files" button if you don't want a local terminal at all).
2. Go to your repo → **Actions** tab → select **"Generate Android Keystore (run ONCE)"** in the left sidebar → **Run workflow**.
3. Type a password of your choice in the input box → **Run workflow**.
4. Wait ~30 seconds, then click into the completed run → expand **"Show SHA-256 fingerprint"** and **"Base64-encode keystore"** steps → copy both values shown.

Run this workflow **exactly once**. Re-running it generates a *different* key, which would break future app updates on anyone's phone.

### Step 2 — Add GitHub Secrets

Repo → **Settings → Secrets and variables → Actions → New repository secret**

| Secret name | Value |
|---|---|
| `KEYSTORE_BASE64` | The long base64 block copied from Step 1 |
| `KEYSTORE_PASSWORD` | The password you typed into the workflow input in Step 1 |

### Step 3 — Update assetlinks.json (via GitHub web editor)

1. In your repo, navigate to `.well-known/assetlinks.json`.
2. Click the pencil (✏️) **Edit** icon — this opens GitHub's web-based file editor, no local tools needed.
3. Replace `REPLACE_WITH_YOUR_SHA256_CERT_FINGERPRINT` with the SHA-256 fingerprint from Step 1.
4. Click **Commit changes** directly in the browser.

### Step 4 — Trigger the build

Repo → **Actions** tab → **"Build SplitTab"** workflow → **Run workflow** (or push a tag the normal way if you do use git). This builds both the Windows EXE and Android APK using your stored secrets — fully automated from here on.

### Updating the app later

You never need to repeat Steps 1–3. For any future code change, just trigger **Build SplitTab** again — the same keystore signs every release automatically.

### Alternative: skip all of this, use pwabuilder.com

Visit **pwabuilder.com**, paste `https://vpradhap.github.io/splittab`, click **Package for stores → Android**. Download a signed APK in ~30 seconds, zero setup, zero CI, zero GitHub Secrets.
## Project structure

```
splittab/
├── index.html                  ← entire app (HTML + CSS + JS)
├── manifest.json               ← PWA manifest
├── .well-known/
│   └── assetlinks.json         ← TWA domain association (Android)
├── supabase/
│   └── schema.sql              ← DB schema (run once in Supabase SQL Editor)
├── src-tauri/                  ← Tauri desktop shell
│   ├── tauri.conf.json         ← window size, installer targets
│   ├── Cargo.toml
│   ├── build.rs
│   └── src/
│       ├── main.rs
│       └── lib.rs
├── scripts/
│   └── build.js                ← copies index.html → www/
├── .github/workflows/
│   └── build.yml               ← CI: Tauri (Windows) + Bubblewrap (Android)
├── package.json
└── .gitignore
```

---

## License

MIT · github.com/vpradhap/splittab
