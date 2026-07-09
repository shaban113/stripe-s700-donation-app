# Netlify Deployment Guide - MIB Gala 2025 Donation App

## Overview
- **Frontend:** Hosted on Netlify at `donate.mosqueofislamicbrotherhood.org`
- **Backend:** Hosted on Render at `api.mosqueofislamicbrotherhood.org`
- **DNS/SSL:** Managed through Cloudflare

---

## Step 1: Sign Up for Netlify

1. Go to [netlify.com](https://netlify.com)
2. Click **Sign Up**
3. Use GitHub, GitLab, Google, or email
4. Verify your account

---

## Step 2: Deploy Your Frontend

### Option A: Drag & Drop (Easiest)

1. In Netlify dashboard, go to **Sites**
2. Drag and drop the folder: `c:\Stripe\stripe-s700-donation-app\client\build`
3. Netlify auto-deploys and gives you a temporary URL like `https://clever-name-12345.netlify.app`

### Option B: Connect Git Repo (Recommended for future updates)

1. Push your code to GitHub:
```powershell
cd c:\Stripe\stripe-s700-donation-app
git init
git add .
git commit -m "MIB Gala 2025 donation app"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/stripe-s700-donation-app.git
git push -u origin main
```

2. In Netlify, click **Add new site → Import an existing project**
3. Select GitHub, authorize, and choose your repo
4. Build settings:
   - Base directory: `client`
   - Build command: `npm run build`
   - Publish directory: `client/build`
5. Deploy

---

## Step 3: Add Your Custom Domain

1. In your Netlify site dashboard, go to **Domain settings**
2. Click **Add custom domain**
3. Enter: `donate.mosqueofislamicbrotherhood.org`
4. Netlify shows you a DNS target (usually a `*.netlify.app` address or IP)

---

## Step 4: Update Cloudflare DNS Records

In Cloudflare, add the records for your subdomains:

### If Netlify gives you a CNAME:
Add a CNAME record:
- **Name:** `donate`
- **Value:** The Netlify target (e.g., `clever-name-12345.netlify.app`)
- **TTL:** 3600

### For the API subdomain:
Add a CNAME or target record for Render:
- **Name:** `api`
- **Value:** The Render service target
- **TTL:** 3600

**Wait 15-30 minutes** for DNS to propagate.

---

## Step 5: Wait for SSL Certificate

Netlify automatically provisions a free SSL certificate. Wait for the status to show:
```
✅ DNS configured - SSL certificate generating
✅ SSL certificate ready
```

---

## Step 6: Test Your Frontend

Visit: `https://donate.mosqueofislamicbrotherhood.org`

You should see:
- ✅ Donation form loads
- ✅ "MIB Gala 2025" title displays
- ✅ Logo loads correctly
- ✅ Buttons are styled and clickable

---

## Step 7: Test the Full Integration

1. **Test API endpoint from frontend:**
   - Open browser DevTools (F12)
   - Go to **Console** tab
   - Type:
   ```javascript
   fetch('https://api.mosqueofislamicbrotherhood.org/api/connection_token', {method: 'POST'})
     .then(r => r.json())
     .then(d => console.log(d))
   ```
   - Should see a response containing `secret`

2. **Test full donation flow:**
   - Connect S700 terminal (if available)
   - Enter amount
   - Click "Create Gala Donation"
   - Check Stripe Dashboard for transaction

---

## Step 8: Link from WordPress

1. In WordPress.com dashboard, go to **Menus**
2. Create or edit menu
3. Add **Custom Link:**
   - URL: `https://donate.mosqueofislamicbrotherhood.org`
   - Label: `Donate Today` (or whatever you want)
4. Save and assign to your menu location

---

## Troubleshooting

### "Domain not found" error
- Wait 20-30 minutes for DNS to fully propagate
- Check your DNS record is correct: `nslookup donate.mosqueofislamicbrotherhood.org`

### "SSL certificate pending"
- Wait up to 1 hour for Netlify to provision certificate
- Check Netlify dashboard for status

### API calls return 404
- Verify backend is live: `https://api.mosqueofislamicbrotherhood.org/api/connection_token`
- Check browser Console for actual error message

### Logo not showing
- Make sure `assets/logo.jpg.webp` exists in build folder
- Path in HTML should be relative: `assets/logo.jpg.webp`

---

## Your Final URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Frontend | https://donate.mosqueofislamicbrotherhood.org | Donation form & UI |
| Backend API | https://api.mosqueofislamicbrotherhood.org/api/* | Stripe terminal payments |
| WordPress | https://mosqueofislamicbrotherhood.org | Main site |

---

## Netlify Free Tier Limits

- ✅ Unlimited bandwidth
- ✅ Automatic SSL
- ✅ Continuous deployment from Git
- ✅ Form submissions (if you add them)
- 💡 Perfect for your use case!

---

## Future Updates

If you change your code and pushed to GitHub:
1. Netlify auto-deploys when you push to `main` branch
2. No need to rebuild or re-upload manually
3. Deploy logs visible in Netlify dashboard

---

## Need Help?

- Netlify Docs: https://docs.netlify.com/
- DNS Issues: https://docs.netlify.com/domains-https/custom-domains/
- Render Docs: https://render.com/docs/web-services
