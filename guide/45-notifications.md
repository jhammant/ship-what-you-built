# Reaching your users

**This page gets you three ways to send a message to someone who uses your
project — email, SMS and browser push — and when each one is worth it.
About an hour for the first channel, fifteen minutes for each one after.**

Your thing is live and people are using it. Now you want to reach them when
something happens — a reminder, an alert, a weekly digest. This is different
from receiving email at your own domain, which is covered in
[Getting more from one domain](70-your-domain.md#email-at-your-own-domain).
That page is about `you@yourthing.com` arriving in your inbox. This page is
about your *project* sending a message to someone else.

---

## Which channel, and when

Before writing any code, pick the right channel for the job. Getting this wrong
wastes money (SMS) or goodwill (too many emails).

| Use case | Channel | Why |
|---|---|---|
| Weekly digest, report, summary | Email | Long-form, permanent, expected |
| Welcome message, onboarding | Email | No character limit, can include links |
| Time-sensitive alert (event today, something broke) | SMS | Highest open rate, arrives even when offline |
| One-off notification the user should see now | Push | Free, instant, no phone number needed |
| "Hey, we still exist" | Nothing | Don't. If you don't have something to say, don't say it |

**The honest version:** most personal projects need at most one of these. If
your thing is a reminder service, SMS or push is the product. If it sends a
weekly digest, email is the product. Very few projects need all three, and
adding a channel nobody asked for is a good way to lose the users you have.

---

## Email — sending from your project

You want your project to send mail as `yourproject@yourthing.com`, not from
your personal inbox. The messages are transactional — triggered by something
the user did or something that happened — not marketing.

### The provider

**[Resend](https://resend.com)** does one thing: send transactional email via
an API. No templates, no drag-and-drop editor, no CRM. You give it HTML and
an address; it delivers.

| Tier | Emails/day | Emails/month | Cost |
|---|---|---|---|
| Free | 100 | 3,000 | nothing |
| Pro | unlimited | 50,000 | check [resend.com/pricing](https://resend.com/pricing) |

The free tier stops sending at the cap — no surprise bill. For a personal
project doing reminders or digests, 100 a day is a lot of users.

### One-time setup

**1. Verify your domain.** Resend dashboard → Domains → add `yourthing.com`.
It gives you three DNS records:

| Record | What it does |
|---|---|
| TXT (SPF) | Authorises Resend to send as you |
| CNAME (DKIM) | Proves messages weren't tampered with |
| CNAME (DKIM) | Second signing key — Resend uses two |

Add them in your DNS provider (Cloudflare, Route 53, wherever your domain
lives). Verify. This is the same kind of work as the MX records in
[Your domain](70-your-domain.md#the-records-youll-be-adding), and for the
same reason — without them, your messages land in spam.

> **If you already have SPF for incoming email,** you need to merge the
> records rather than replacing one with the other. An SPF record is a single
> TXT record listing everyone allowed to send as your domain. Two separate
> SPF records is invalid and will cause deliverability problems. Resend's
> docs explain how to combine them.

**2. Create an API key.** Resend dashboard → API Keys → Create. Scope it to
your domain. Copy it once — it won't be shown again.

**3. Store the key as a secret.** On Cloudflare:

```bash
# If using Wrangler (Workers)
wrangler secret put RESEND_API_KEY
```

Or: Pages project → Settings → Variables and Secrets → Add → Production →
Encrypt.

**Never put the key in your code, your `.env` in git, or your front-end
JavaScript.** If this sounds familiar, it's the same rule as
[Keys and access](05-keys-and-access.md).

### The code

A function that sends one email. Copy it, change the `FROM` line, and call it
from wherever you need:

```javascript
// functions/api/send-email.js  (or a helper you import)
const FROM = "Your Project <yourproject@yourthing.com>";

async function sendEmail(apiKey, to, subject, html) {
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ from: FROM, to: [to], subject, html }),
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Resend ${res.status}: ${body}`);
  }
}
```

Guard the call so it doesn't crash in local development where the secret
isn't set:

```javascript
if (context.env.RESEND_API_KEY) {
  await sendEmail(context.env.RESEND_API_KEY, user.email, "Subject", "<p>Hello.</p>");
}
```

### Sending on a schedule

If your project sends a weekly digest or daily reminder, you need a cron
trigger. In `wrangler.toml`:

```toml
[triggers]
crons = ["0 18 * * 5"]   # every Friday at 6pm UTC
```

The scheduled handler runs on Cloudflare's side, not yours — your laptop
doesn't need to be open.

### What goes in the email

Keep it simple. Email clients are not browsers — half of them strip your
CSS, most of them ignore your fonts, and none of them run your JavaScript.

- **Inline styles only.** No `<style>` block, no `<link>` to a stylesheet.
- **Max width 600px.** Wider than that and mobile clients add a horizontal
  scroll.
- **Always include an unsubscribe link.** This is a legal requirement
  under CAN-SPAM and GDPR, not a courtesy. Resend can generate one for you,
  or you build your own — either way, every message needs one.
- **Plain text too.** Some clients prefer it, and spam filters penalise
  HTML-only. Resend accepts a `text` field alongside `html`.

### What goes wrong

| Symptom | What's happening |
|---|---|
| Messages land in spam | SPF or DKIM records missing, or not propagated yet |
| "Address not verified" error | Domain not verified in Resend, or API key scoped to a different domain |
| Nothing happens in production | `RESEND_API_KEY` not set in production environment — same failure mode as [the Stripe lesson](60-money.md#subscriptions-and-the-mistake-worth-learning-from-mine) |
| Emails stop at 100/day | Free tier cap. Resend returns a 429, not a bill |

---

## SMS — for the things that can't wait

SMS costs real money per message, arrives on a phone that might be in someone's
pocket, and has a near-100% open rate. That combination means it's the right
channel for genuinely urgent, short alerts — and the wrong channel for almost
everything else.

**If you're considering SMS for a newsletter or a weekly update, use email
instead.** SMS is for "your bin is out tomorrow" or "the event you're tracking
starts in an hour".

### Pick a provider

| Provider | Outbound SMS (UK) | Phone number | Best for |
|---|---|---|---|
| **Twilio** | ~4p/msg | ~£1/mo | Widest documentation, most examples online |
| **Telnyx** | ~3p/msg | ~40p/mo | Cheaper per-message, good API |
| **AWS SNS** | ~4p/msg | no number needed | One-way alerts if you're already on AWS |

Check [twilio.com/sms/pricing](https://www.twilio.com/en-us/sms/pricing/gb)
and [telnyx.com/pricing/messaging](https://telnyx.com/pricing/messaging) for
current numbers. The prices above are shapes, not quotes, and they change.

### Setup (Twilio)

1. Sign up at [twilio.com](https://www.twilio.com). The trial account includes
   credit to test with.
2. Buy a phone number — Messaging → Phone Numbers → Buy a number. Pick one
   that can send SMS in the countries you care about.
3. Store your credentials:

```bash
wrangler secret put TWILIO_ACCOUNT_SID
wrangler secret put TWILIO_AUTH_TOKEN
wrangler secret put TWILIO_FROM_NUMBER
```

### The code (Twilio)

```javascript
async function sendSms(accountSid, authToken, from, to, body) {
  const res = await fetch(
    `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`,
    {
      method: "POST",
      body: new URLSearchParams({ To: to, From: from, Body: body }),
      headers: {
        "Authorization": "Basic " + btoa(`${accountSid}:${authToken}`),
        "Content-Type": "application/x-www-form-urlencoded",
      },
    }
  );

  if (!res.ok) {
    const error = await res.text();
    throw new Error(`Twilio ${res.status}: ${error}`);
  }
}
```

### The code (Telnyx)

If you'd rather save a penny per message:

```javascript
async function sendSms(apiKey, from, to, text) {
  const res = await fetch("https://api.telnyx.com/v2/messages", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ from, to, text }),
  });

  if (!res.ok) {
    const error = await res.text();
    throw new Error(`Telnyx ${res.status}: ${error}`);
  }
}
```

### UK-specific things

- **Phone numbers must be in E.164 format:** `+447700900123`, not
  `07700 900123`. Store them with the country code from the start, or you'll
  be reformatting later.
- **Alphanumeric sender IDs.** Twilio lets you register a name (like
  `YourApp`) so messages show that instead of a phone number. Free to set up,
  and it looks considerably more trustworthy. The recipient can't reply to it,
  which is fine for alerts.
- **Consent is not optional.** UK regulations require explicit opt-in before
  sending marketing or promotional SMS. A "notify me" button the user
  actively clicks is consent. Pre-ticked checkboxes and buried terms are not.
  This is PECR, not just GDPR, and the fines are real.

### What goes wrong

| Symptom | What's happening |
|---|---|
| "Unverified number" error | Twilio trial accounts can only send to verified numbers. Verify the number or upgrade the account |
| Message never arrives | Wrong country code format, or the number is a landline |
| Delivered but shows as unknown sender | No alphanumeric sender ID registered |
| Bill higher than expected | Sending more messages than you think — add logging and check |

---

## Push notifications — the free one

Browser push notifications appear on the user's device even when your site
isn't open. They cost nothing to send, require no phone number or email
address, and the user opts in with one click.

The tradeoff: they only work in browsers that support the Push API (all
major desktop and Android browsers; Safari on iOS since version 16.4), and
the user has to have granted permission. You cannot reach someone who hasn't
opted in, and you cannot reach them when they've cleared their browser data.

### How it works

1. Your page registers a **service worker** and asks the user to subscribe
2. The browser returns a **push subscription** — an endpoint URL and keys
3. You store that subscription (in KV, D1, or whatever you use for data)
4. When something happens, your worker sends an encrypted payload to the
   browser's push service, which wakes the service worker and shows the
   notification

### Libraries that work on Cloudflare Workers

The standard `web-push` npm package uses Node.js crypto and **will not work**
on Workers. Use one of these instead:

- **[PushForge](https://github.com/draphy/pushforge)** — zero dependencies,
  built for edge runtimes
- **[webcrypto-web-push](https://github.com/block65/webcrypto-web-push)** —
  uses Web Crypto APIs available on Workers

### Setup

1. Generate VAPID keys:

```bash
npx web-push generate-vapid-keys
```

2. Store the private key as a Worker secret. Put the public key in your
   front-end code (it's meant to be public).

3. In your page, register the service worker and subscribe:

```javascript
const registration = await navigator.serviceWorker.register("/sw.js");
const subscription = await registration.pushManager.subscribe({
  userVisibleOnly: true,
  applicationServerKey: YOUR_PUBLIC_VAPID_KEY,
});

// Send the subscription to your backend to store it
await fetch("/api/subscribe", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify(subscription),
});
```

4. In your service worker (`sw.js`):

```javascript
self.addEventListener("push", (event) => {
  const data = event.data?.json() ?? {};
  event.waitUntil(
    self.registration.showNotification(data.title ?? "Update", {
      body: data.body,
      icon: "/icon.png",
    })
  );
});
```

### When to use push instead of SMS or email

| Factor | Push | SMS | Email |
|---|---|---|---|
| Cost per message | Free | 3–4p | Free (up to cap) |
| Needs phone number | No | Yes | No |
| Needs email address | No | No | Yes |
| Works offline / app closed | Yes (if browser running) | Yes | Yes |
| Survives browser clear | No | Yes | Yes |
| Open rate | High | Very high | Low-medium |

**Push is best when:** the alert is timely, the user is likely on the device
they subscribed from, and you don't have (or don't want to ask for) a phone
number or email address.

### What goes wrong

| Symptom | What's happening |
|---|---|
| "Registration failed" | Service worker must be served over HTTPS |
| Subscription works, no notification appears | The push payload must be encrypted — this is what the libraries handle |
| Works on desktop, not on mobile | iOS Safari requires the site to be added to home screen first (before iOS 18) |
| Notifications stop after a while | Subscriptions expire. Re-subscribe on each visit |

---

## Storing subscribers

Whichever channel you use, you need somewhere to keep the list of people who
opted in. On Cloudflare, **Workers KV** is the simplest choice for this — it's
a key-value store that's free at personal scale and available in your function
via a binding.

Store each subscriber keyed by their identifier (email, phone, or push
endpoint), and include when they subscribed and whether they've confirmed.
When someone unsubscribes, delete the key — don't flag it, delete it.

> **A subscriber list is personal data.** GDPR applies to UK and EU users
> regardless of where your server is. The practical minimum: let people see
> what you store about them, let them delete it, and don't keep it longer
> than you need it. For a personal project this isn't onerous — it's mostly
> "have an unsubscribe that works".

---

## The realistic sequence

1. **Start with nothing.** If your project doesn't need to reach people
   proactively, don't add a notification channel because you can. Build the
   thing first; add reach when there's something to reach them about.
2. **Email first,** because it's free, universally reachable, and people
   expect it. 100 emails a day on Resend's free tier is more than most
   personal projects will ever need.
3. **Push second,** if the alerts are timely and you want to avoid asking
   for contact details. Free and quick to add.
4. **SMS last,** because it costs money per message and requires a phone
   number, which is the highest-friction piece of personal data to ask for.
   Reserve it for things that genuinely need to interrupt someone's day.

---

**Next:** [Getting it found →](50-getting-found.md)
