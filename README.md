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

## Building the Android APK (one-time setup)

The Android job wraps your live GitHub Pages URL as a TWA (Trusted Web Activity) — a full-screen Chrome-based app. No Gradle project, no Android Studio.

### Step 1 — Generate your signing key (local, one time)

```bash
npx @bubblewrap/cli init \
  --manifest https://vpradhap.github.io/splittab/manifest.json \
  --directory ./twa
```

Note the **SHA256 fingerprint** printed at the end.

### Step 2 — Update assetlinks.json

Paste your SHA256 fingerprint into `.well-known/assetlinks.json`, replacing the placeholder. Commit and push.

### Step 3 — Add GitHub Secrets

| Secret name | Value |
|---|---|
| `KEYSTORE_BASE64` | `base64 -w0 android.keystore` output |
| `KEYSTORE_PASSWORD` | the password you chose during init |

### Step 4 — Push a tag

Same as Windows — the same `git tag` + `git push --tags` triggers both jobs.

### Alternative: skip CI, use pwabuilder.com

Visit **pwabuilder.com**, paste `https://vpradhap.github.io/splittab`, click **Package for stores → Android**. Download the APK in ~30 seconds with no setup.

---

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
