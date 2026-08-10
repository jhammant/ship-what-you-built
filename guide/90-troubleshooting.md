# When it breaks

Deploys break. It's normal, it's usually one of about fifteen things, and the
trick is narrowing down *where* before you start changing settings.

---

## First: which layer?

Before anything else, ask which of [the four layers](01-three-layers.md) is
failing. Two commands tell you almost every time:

```bash
dig yourthing.com                        # layers 1 & 2 — does the name resolve?
curl -sI https://yourthing.com | head -1 # layers 3 & 4 — does the server answer?
```

| What you get | Layer | Meaning |
|---|---|---|
| `NXDOMAIN`, no answer section | 1 or 2 | DNS. The name doesn't resolve at all |
| An IP, but `curl` hangs or refuses | 3 | DNS is fine; the host isn't serving |
| An IP, and an SSL error | 4 | Certificate missing, expired, or for the wrong name |
| `HTTP/2 404` | 3 | Host is serving, but not your file |
| `HTTP/2 200` but the page is wrong | 3 | Cache, or you deployed the wrong folder |

Fixing DNS when the problem is caching wastes an hour. Ninety seconds of
narrowing pays for itself.

---

## The ones that catch nearly everyone

### "It works for everyone but me"

Your own DNS cache. You are almost always the last person on the planet seeing
the old value.

```bash
dig @1.1.1.1 yourthing.com +short      # ask Cloudflare's resolver directly
dig @8.8.8.8 yourthing.com +short      # and Google's
```

If those look right, the internet is fine and your machine is behind.

```bash
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder   # macOS
ipconfig /flushdns                                              # Windows
resolvectl flush-caches                                         # Linux (systemd)
```

Then a browser hard-reload: **Cmd/Ctrl + Shift + R**. Browsers cache DNS
*separately* from the OS, which is why this sometimes needs both.

### "Old version still showing"

Layer 3, and there are usually **two** caches between you and the truth. Clear
them in this order and re-check after each — most people only clear one and
conclude the deploy failed.

1. **Your browser.** Hard-reload, or open a private window. Rules out the most
   common cause in five seconds.
2. **The CDN.** Track A: Cloudflare → **Caching** → **Purge Everything**.
   Track B: `aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"`
   (takes a couple of minutes).
3. **The deploy itself.** Did it actually run and succeed? `gh run list --limit 3`,
   or look at the deployments list in your host's dashboard. Plenty of "cache
   problems" are a build that failed twenty minutes ago.

### "Works with `www`, not without" (or vice versa)

Layer 2. `yourthing.com` and `www.yourthing.com` are **different hostnames** and
each needs its own DNS record and its own place in the certificate. Add both.
Both tracks tell you to; it's the step people skip.

### "My API key stopped working after I deployed"

It was in a file that `.gitignore` excluded, so it never left your laptop.
Correct behaviour — that's the whole point. Set it as an environment variable in
your host's dashboard (Track A: Pages → Settings → Environment variables. Track
B: `aws lambda update-function-configuration --environment`) and **redeploy**,
because variables are read at build/start time.

### "The certificate is stuck pending"

Layer 4 waiting on layer 2. The certificate authority wants a DNS record to
appear and it hasn't. Check the exact record it's asking for actually resolves:

```bash
dig +short _abc123.yourthing.com CNAME
```

Empty means the record wasn't added, or was added to a different zone — a
classic when you have the domain in two DNS providers at once and are editing
the one that isn't authoritative. `dig NS yourthing.com` tells you which one is
in charge.

### "It deployed, but the site is blank"

The build produced nothing, or you pointed the host at the wrong folder.

```bash
npm run build && ls -la dist/   # or build/, or out/
```

Whatever folder appears with an `index.html` in it — that's your output
directory. Set it in Pages, or in the `aws s3 sync` path.

### "The build works locally but fails on the host"

In descending order of likelihood:

1. **Node version.** `node -v` locally vs the host's default. Track A: set
   `NODE_VERSION` in environment variables. Track B: `node-version` in the
   workflow.
2. **A dependency was gitignored.** `node_modules/` should be ignored, but
   `package-lock.json` must be **committed** — it's what `npm ci` reads.
3. **Case sensitivity.** macOS and Windows don't care about `Header.jsx` vs
   `header.jsx`. Linux, which your build runs on, cares enormously. This one
   produces a genuinely baffling "module not found" for a file you can plainly
   see.

---

## Track A — Cloudflare specifics

| Symptom | Cause |
|---|---|
| Custom domain stuck "pending" | The domain isn't in this Cloudflare account, or nameservers haven't switched. `dig NS yourthing.com` |
| `/api/…` returns your HTML | The `functions/` folder must be at the **repo root**, not inside `src/` |
| Function returns 500 | Usually a missing environment variable. Real-time logs are under the project's **Functions** tab |
| Env var change had no effect | They apply at build time — redeploy |
| Email stopped after moving DNS | `MX` records didn't import. Copy them from your old provider |
| Deploy succeeded, 404 on every page | Output directory wrong, or `index.html` isn't at its root |

## Track B — AWS specifics

| Symptom | Cause |
|---|---|
| CloudFront won't accept the certificate | Cert isn't in `us-east-1`. It must be. Recreate it there |
| `AccessDenied` from CloudFront | Bucket policy missing, or `AWS:SourceArn` doesn't match the distribution |
| `InvalidLocationConstraint` on bucket create | You're in `us-east-1` — omit `--create-bucket-configuration` |
| 403 from a Lambda URL | The `add-permission` step after creating the URL was skipped |
| Deep links 404 on a single-page app | Add custom error responses: 403 and 404 → `/index.html`, status 200 |
| `sts:AssumeRoleWithWebIdentity` denied | The role's trust policy `sub` doesn't match `owner/repo` exactly |
| `Credentials could not be loaded` in Actions | Workflow missing `permissions: id-token: write` |
| `InvalidClientTokenId` | Access key wrong or deleted. `aws configure` again |
| Domain suspended after two weeks | ICANN verification email never clicked |
| A charge you don't recognise | Cost Explorer → group by service. Usually the hosted zone, or a NAT gateway you created by accident |

---

## Getting unstuck faster

**Paste the whole error.** Not a summary, not "it says something about
permissions". These failures routinely *look* like permission problems and
*are* configuration problems, and the distinguishing detail is always in the
part people trim off.

A prompt that works:

> This is failing. Here's the complete error:
>
> ```text
> <paste everything>
> ```
>
> I'm on Track A/B of the guide, at step N. Before changing anything, tell me
> which of the four layers you think this is and why.

Asking for the diagnosis before the fix is worth doing. It stops the shotgun
approach where six settings change at once and you end up unable to tell which
one mattered — or worse, with a working site and no idea why.

**Still stuck?** [Open an issue](../../../issues) with the error and which track
you're on. Someone else has almost certainly hit the same thing, and if the
guide caused it, the guide should be fixed.
