# Explore with SG — Admin Panel

Admin portal for **www.explorewithsg.com**, accessible at:

```
https://www.explorewithsg.com/admin/
```

---

## File structure

```
admin/
├── index.html       ← Login page  (explorewithsg.com/admin/)
├── dashboard.html   ← Main admin dashboard (protected)
└── README.md        ← This file
```

---

## Default login credentials

| Field    | Value          |
|----------|----------------|
| Username | `admin`        |
| Password | `sg@admin2026` |

> **Change these before going live.** See the *Upgrading to real auth* section below.

---

## How the session works (current setup)

- On login, a session token is stored in `sessionStorage` with an 8-hour expiry.
- Every time `dashboard.html` loads, a guard script runs *before* the page renders and redirects back to `index.html` if no valid session exists.
- Closing the browser tab clears the session automatically (`sessionStorage` is tab-scoped).
- The logout button in the sidebar footer clears the session and returns to the login page.

This is a **client-side guard** — suitable for a private, low-risk admin tool. For production security, upgrade to server-side auth (see below).

---

## Deploying to GitHub Pages

### 1. Create the repository

```bash
git init
git remote add origin https://github.com/YOUR_USERNAME/explorewithsg-admin.git
```

### 2. Push the files

```bash
git add .
git commit -m "Initial admin panel"
git push -u origin main
```

### 3. Enable GitHub Pages

1. Go to your repository on GitHub
2. Settings → Pages
3. Source: **Deploy from a branch**
4. Branch: `main` / `/ (root)`
5. Save

GitHub will give you a URL like `https://YOUR_USERNAME.github.io/explorewithsg-admin/`

### 4. Point your domain's `/admin` path to this

In your domain registrar / DNS / hosting panel (wherever `explorewithsg.com` is hosted), add a **path redirect** or subdirectory config:

```
explorewithsg.com/admin  →  YOUR_USERNAME.github.io/explorewithsg-admin
```

If you're using a host that supports subdirectory publishing (Netlify, Vercel, Cloudflare Pages), deploy there instead and set the base path to `/admin`.

---

## Upgrading to real authentication (recommended before launch)

The current login is client-side only. For production, replace with **Supabase Auth** — it's free, takes ~30 minutes to set up, and requires only small changes to `index.html`.

### Step 1 — Create a Supabase project

1. Go to [supabase.com](https://supabase.com) and create a free project
2. Note your **Project URL** and **Anon Key** from Project Settings → API

### Step 2 — Create an admin user

In your Supabase dashboard → Authentication → Users → Invite user  
Enter your email and set a password.

### Step 3 — Replace the login JS in `index.html`

Replace the `handleLogin` function with:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
  const { createClient } = supabase;
  const sb = createClient('YOUR_SUPABASE_URL', 'YOUR_ANON_KEY');

  async function handleLogin(e) {
    e.preventDefault();
    setLoading(true);
    const email = document.getElementById('username').value.trim();
    const pass  = document.getElementById('password').value;
    const { error } = await sb.auth.signInWithPassword({ email, password: pass });
    if (error) {
      setLoading(false);
      showError(error.message);
    } else {
      window.location.href = 'dashboard.html';
    }
  }
</script>
```

### Step 4 — Update the session guard in `dashboard.html`

Replace the guard script with:

```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
  const { createClient } = supabase;
  const sb = createClient('YOUR_SUPABASE_URL', 'YOUR_ANON_KEY');
  sb.auth.getSession().then(({ data: { session } }) => {
    if (!session) window.location.replace('index.html');
  });
</script>
```

And update the logout function:

```js
async function logout() {
  if (confirm('Sign out of the admin panel?')) {
    await sb.auth.signOut();
    window.location.href = 'index.html';
  }
}
```

---

## Tech stack

| Layer       | Technology                              |
|-------------|----------------------------------------|
| Frontend    | Vanilla HTML / CSS / JS (no framework) |
| Auth (now)  | Client-side session guard              |
| Auth (prod) | Supabase Auth (recommended)            |
| Hosting     | GitHub Pages                           |
| Domain      | explorewithsg.com (custom domain)      |
| Database    | Supabase (next phase)                  |

---

## Next steps

- [ ] Connect to Supabase database (enquiries, drivers, packages tables)
- [ ] Build public-facing booking wizard at `explorewithsg.com`
- [ ] WhatsApp notification on booking confirmation
- [ ] PWA manifest so admin panel installs as an app on mobile

---

*Built for SG Taxis & Leisure · explorewithsg.com*
