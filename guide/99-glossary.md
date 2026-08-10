# Every term, explained

Every word in this guide in plain English — about fifteen seconds a look-up, and
not a page anyone reads end to end.

Each entry links to the page where the term actually matters. Look up the word
that stopped you, then go back to what you were doing.

If a term you hit isn't here, that's a bug in the guide.
[Open an issue](../../../issues) and it gets added.

---

## Index

- **A** — [A record](#a-record) · [AAAA record](#aaaa-record) · [Absolute and relative URL](#absolute-and-relative-url) · [Access key](#access-key) · [ACM](#acm) · [ALIAS record](#alias-record) · [Anon key](#anon-key) · [Apex domain](#apex-domain) · [API](#api) · [API key](#api-key) · [apt](#apt) · [ARN](#arn) · [Audience claim](#audience-claim) · [Auth code](#auth-code) · [Authentication and authorisation](#authentication-and-authorisation) · [AWS account ID](#aws-account-id)
- **B** — [bash](#bash) · [Binding](#binding) · [Blast radius](#blast-radius) · [Branch](#branch) · [Browser cache and hard reload](#browser-cache-and-hard-reload) · [Bucket](#bucket) · [Budget alarm](#budget-alarm) · [Build command](#build-command) · [Build step](#build-step)
- **C** — [Cache](#cache) · [Cache invalidation](#cache-invalidation) · [Case sensitivity](#case-sensitivity) · [CDN](#cdn) · [Certificate](#certificate) · [Certificate authority](#certificate-authority) · [CI and CD](#ci-and-cd) · [Claim](#claim) · [CLI](#cli) · [Clone](#clone) · [Cloudflare Pages](#cloudflare-pages) · [CloudFront](#cloudfront) · [CNAME](#cname) · [CNAME flattening](#cname-flattening) · [Cold start](#cold-start) · [Commit](#commit) · [Cost Explorer](#cost-explorer) · [Credential](#credential) · [curl](#curl)
- **D** — [D1](#d1) · [Delegation](#delegation) · [Deploy](#deploy) · [dig](#dig) · [Distribution](#distribution) · [DNS](#dns) · [Domain](#domain) · [Domain validation](#domain-validation) · [Durable Objects](#durable-objects)
- **E** — [Edge](#edge) · [Endpoint](#endpoint) · [.env](#env) · [Environment variable](#environment-variable) · [ETag](#etag) · [Eventual consistency](#eventual-consistency)
- **F** — [Favicon](#favicon) · [Force-push](#force-push) · [Fork](#fork) · [Free tier](#free-tier) · [Function URL](#function-url)
- **G** — [gh](#gh) · [git](#git) · [Git Bash](#git-bash) · [.gitignore](#gitignore) · [GitHub](#github) · [GitHub Actions](#github-actions) · [GitHub secret](#github-secret) · [GitHub variable](#github-variable)
- **H** — [Headless browser](#headless-browser) · [Heredoc](#heredoc) · [History rewriting](#history-rewriting) · [Homebrew](#homebrew) · [Hostname](#hostname) · [HSTS](#hsts) · [HTML, CSS and JavaScript](#html-css-and-javascript) · [HTTP](#http) · [HTTP header](#http-header) · [HTTP status code](#http-status-code) · [HTTPS](#https)
- **I** — [IAM](#iam) · [IAM Identity Center](#iam-identity-center) · [IAM user](#iam-user) · [ICANN](#icann) · [Identity provider](#identity-provider) · [Infrastructure as code](#infrastructure-as-code) · [IP address](#ip-address) · [Issue](#issue)
- **J** — [jq](#jq) · [JSON](#json) · [JWT](#jwt)
- **L** — [Lambda](#lambda) · [Least privilege](#least-privilege) · [Let's Encrypt](#lets-encrypt) · [Licence](#licence) · [localhost](#localhost) · [Lockfile](#lockfile)
- **M** — [main](#main) · [Managed platform](#managed-platform) · [Merge](#merge) · [MFA](#mfa) · [MIT licence](#mit-licence) · [MX record](#mx-record)
- **N** — [Nameserver](#nameserver) · [NAT gateway](#nat-gateway) · [Node.js](#nodejs) · [node_modules](#node_modules) · [npm](#npm) · [NS record](#ns-record) · [NXDOMAIN](#nxdomain)
- **O** — [Object](#object) · [OIDC](#oidc) · [Open Graph](#open-graph) · [Open source](#open-source) · [Origin (git)](#origin-git) · [Origin (hosting)](#origin-hosting) · [Origin Access Control](#origin-access-control) · [Output directory](#output-directory)
- **P** — [Package manager](#package-manager) · [Pages Functions](#pages-functions) · [Personal access token](#personal-access-token) · [Policy](#policy) · [Port](#port) · [PowerShell](#powershell) · [Premium domain](#premium-domain) · [Preview deployment](#preview-deployment) · [Principal](#principal) · [Propagation](#propagation) · [Pull request](#pull-request) · [Push](#push) · [Push protection](#push-protection)
- **R** — [R2](#r2) · [README](#readme) · [Region](#region) · [Registrar](#registrar) · [Registry](#registry) · [Remote](#remote) · [Repository](#repository) · [Resolver](#resolver) · [Role](#role) · [Rollback](#rollback) · [Root account](#root-account) · [Rotate a key](#rotate-a-key) · [Route 53](#route-53) · [Row Level Security](#row-level-security) · [Runner](#runner) · [Runtime](#runtime)
- **S** — [S3](#s3) · [Secret](#secret) · [Secret scanning](#secret-scanning) · [Secrets Manager](#secrets-manager) · [Server](#server) · [Serverless](#serverless) · [Shell](#shell) · [Shell variable](#shell-variable) · [SNI](#sni) · [SOA record](#soa-record) · [SPA](#spa) · [SPF, DKIM and DMARC](#spf-dkim-and-dmarc) · [Stage](#stage) · [Static site](#static-site) · [Static site generator](#static-site-generator) · [STS and AssumeRole](#sts-and-assumerole) · [Subdomain](#subdomain) · [Subject claim](#subject-claim) · [Supabase](#supabase)
- **T** — [Terminal](#terminal) · [TLD](#tld) · [TLS and SSL](#tls-and-ssl) · [Topics](#topics) · [Trust policy](#trust-policy) · [TTL](#ttl) · [TXT record](#txt-record)
- **U** — [UPSERT](#upsert) · [URL](#url)
- **V** — [Virtual machine](#virtual-machine)
- **W** — [WHOIS](#whois) · [winget](#winget) · [Workers](#workers) · [Workers KV](#workers-kv) · [Workflow](#workflow) · [wrangler](#wrangler) · [WSL](#wsl)
- **Z** — [zip](#zip) · [Zone](#zone)

---

## Domains and DNS

### A record

A [DNS](#dns) record that maps a name to an IPv4 address — `yourthing.com` →
`104.21.5.12`. It is the most basic answer DNS can give, and on
[Track B](20-aws.md#44-point-the-domain-at-it) your domain's A record is a
special [alias](#alias-record) one pointing at CloudFront rather than a literal
number.

### AAAA record

The same idea as an [A record](#a-record) but for an IPv6 address (the longer,
colon-separated kind). Pronounced "quad-A". You rarely add these by hand — your
host adds them alongside the A record if it supports IPv6.

### ALIAS record

A non-standard record type that behaves like a [CNAME](#cname) but is allowed at
the [apex](#apex-domain), where a real CNAME is forbidden.
[Route 53](#route-53) calls it an ALIAS; other providers call it ANAME. See
[the apex problem](06-four-layers.md#the-apex-problem--the-one-gotcha-worth-knowing-in-advance).

### Apex domain

The bare domain with nothing in front of it — `yourthing.com`, not
`www.yourthing.com`. Also called the root domain, the naked domain or the zone
apex. It matters because the DNS specification forbids a [CNAME](#cname) there,
which is why hosts invent [ALIAS](#alias-record) records and
[CNAME flattening](#cname-flattening).

### Auth code

A one-time password your current [registrar](#registrar) gives you so a
different registrar is allowed to take over the domain. Also called an EPP code
or transfer code. Transfers take around five days and your site stays up
throughout, because the [nameservers](#nameserver) don't change.

### CNAME

A DNS record meaning "don't ask me, go and look up this *other* name instead" —
`www.yourthing.com` → `your-project.pages.dev`. It is what modern hosts hand you
instead of an IP address, so that when their addresses change your site doesn't
notice. See [layer 2](06-four-layers.md#layer-2--dns).

### CNAME flattening

Cloudflare's answer to [the apex problem](#apex-domain): you add what looks like
a CNAME at the apex, and Cloudflare quietly resolves it and serves an
[A record](#a-record) instead. You don't configure it — it just happens, which
is why [Track A](10-cloudflare.md#4-put-it-on-your-domain) never mentions the
problem at the point it would otherwise bite.

### Delegation

The moment the [registry](#registry) for your [TLD](#tld) publishes your
[nameservers](#nameserver), so the rest of the internet knows who to ask about
your domain. A brand-new registration is **not delegated instantly**, and until
it is, your DNS records are correct but invisible — which is exactly why
[a certificate can hang](20-aws.md#42-the-certificate--us-east-1-always) on a
freshly bought domain. Check with `dig NS yourthing.com +short`; empty means not
yet.

### `dig`

The standard command-line tool for asking DNS a question directly, rather than
trusting your browser. `dig NS yourthing.com +short` shows the nameservers;
`dig @1.1.1.1 yourthing.com` bypasses your own cache. macOS has it; on Ubuntu
install `dnsutils` (called `bind9-dnsutils` on newer releases); Windows without
[WSL](#wsl) has no `dig` — use
`nslookup -type=NS yourthing.com` or [dnschecker.org](https://dnschecker.org).
See [seeing it for yourself](06-four-layers.md#see-it-for-yourself).

### DNS

The Domain Name System — the global phone book that turns a name people can
remember into an address machines can use. It is
[layer 2](06-four-layers.md#layer-2--dns) of the four, and it is far and away
the layer people get stuck on.

### Domain

The name you rent, like `yourthing.com`. **A domain is not a website and not
hosting** — this is the single most common confusion in the whole subject. The
domain is only a name plus the right to say who answers questions about it; the
files live somewhere else entirely, which is why you can change host without
changing domain. See [the three layers](06-four-layers.md).

### Hostname

One specific name in DNS, including everything in front of the domain.
`yourthing.com` and `www.yourthing.com` are **two different hostnames**, each
needing its own record and its own place in the [certificate](#certificate).
That single fact explains the classic "works with `www`, not without"
([troubleshooting](90-troubleshooting.md#works-with-www-not-without-or-vice-versa)).

### ICANN

The non-profit that oversees the domain name system. Two things it does affect
you directly: a small fixed fee added to most registrations, and a rule that you
must **click the verification email** after registering or the domain gets
suspended after roughly a fortnight ([Track B](20-aws.md#31-buy-it)). Both apply
to `.com`-style endings; country ones like `.uk` set their own rules.

### MX record

A DNS record saying which server receives email for the domain. It matters here
for one reason: when you
[move DNS to Cloudflare](10-cloudflare.md#2b-you-already-own-a-domain-elsewhere)
and the MX records don't come across, your email silently stops. Check them
before you switch nameservers, not after.

### Nameserver

A machine that holds your [zone](#zone) and answers DNS questions about it. Your
[registrar](#registrar) stores a short list of them against your domain, and
changing that list is how you move your entire DNS to a different provider. It
is the one registrar setting that genuinely matters.

### NS record

The record type that lists your [nameservers](#nameserver). `dig NS
yourthing.com +short` is usually the first command to run when something is
broken, because it tells you which provider is actually in charge — often not
the one whose dashboard you've been editing.

### NXDOMAIN

DNS's way of saying "that name doesn't exist". In a browser it shows up as
"Server not found". It means the failure is at
[layer 1 or 2](06-four-layers.md#when-it-breaks-which-layer-is-it) — the name
never resolved, so nothing has even tried to reach your host yet.

### Premium domain

A name the [registry](#registry) has flagged as desirable and priced at ten to a
hundred times normal, often with a renewal to match. Route 53 refuses to
register premium names at all, which makes it a
[free premium detector](20-aws.md#31-buy-it): if it offers you the name at a
normal price, it isn't premium.

### Propagation

The folklore that DNS changes take 24–48 hours. Mostly untrue — a record with a
short [TTL](#ttl) is visible worldwide in minutes. What is genuinely slow is a
[nameserver](#nameserver) change, and what fools you is your own machine's
cache. See ["propagation" — mostly a myth](06-four-layers.md#dns-propagation--mostly-a-myth).

### Registrar

The company you buy the domain from — Cloudflare, Namecheap, Route 53 Domains,
GoDaddy, Gandi. You're buying a lease, usually annual, plus the right to set the
[nameservers](#nameserver). This is
[layer 1](06-four-layers.md#layer-1--the-registrar) and the least sticky thing
you own.

### Registry

The organisation that runs an entire [TLD](#tld) — Verisign for `.com`, Nominet
for `.uk`. You never deal with it directly; your [registrar](#registrar) does.
It sets the wholesale price, which is why `.com` costs roughly the same
everywhere and why some newer extensions renew at fifteen times their first-year
price.

### Resolver

The DNS server your computer actually asks — usually your router's or your
internet provider's, sometimes a public one like Cloudflare's `1.1.1.1` or
Google's `8.8.8.8`.
Resolvers cache answers, which is why `dig @1.1.1.1 yourthing.com` is the fastest
way to prove ["it works for everyone but me"](90-troubleshooting.md#it-works-for-everyone-but-me)
is your own machine's fault.

### Route 53

AWS's DNS service, and also an AWS [registrar](#registrar). It is the only piece
of [Track B](20-aws.md) that costs money whether or not anyone visits — around
$0.50 a month per [hosted zone](#zone) — which is why
[turning it off properly](20-aws.md#part-9--turning-it-off) has its own section.

### SOA record

The "start of authority" record that sits at the top of every [zone](#zone),
carrying administrative settings. You never create or edit it; it appears
automatically, and the only time you'll notice it is when
[deleting a hosted zone](20-aws.md#part-9--turning-it-off), where SOA and
[NS](#ns-record) records are the two you must leave alone.

### SPF, DKIM and DMARC

Three [TXT record](#txt-record) conventions that between them tell the world
which servers may send email as your domain. Values start `v=spf1`, or live
under names containing `_domainkey` or `_dmarc`. If you receive email at your
domain, these must survive a
[DNS move](10-cloudflare.md#2b-you-already-own-a-domain-elsewhere) intact.

### Subdomain

Anything in front of the domain: `www.yourthing.com`, `api.yourthing.com`,
`blog.yourthing.com`. Subdomains are free and unlimited once you own the domain,
and a second project on one costs nothing extra —
[Track B notes](20-aws.md#part-8--worth-doing-next) it takes about ten minutes
once the [zone](#zone) exists.

### TLD

Top-level domain — the last part of the name: `.com`, `.co.uk`, `.dev`,
`.online`. The TLD decides both the price and some behaviour: `.dev`, for
instance, is on the [HSTS](#hsts) preload list, so browsers refuse plain HTTP on
it entirely.

### TTL

Time-to-live, in seconds — a note attached to every DNS record saying "you may
cache this answer for this long". A 300-second TTL means the world sees your
change within five minutes. **Lower the TTL before a change you know is coming**,
not after ([layer 2](06-four-layers.md#dns-propagation--mostly-a-myth)).

### TXT record

A DNS record holding arbitrary text. Its real use is proving you control a
domain: [certificate authorities](#certificate-authority) and services like
Google ask you to publish a specific string, and read it back to confirm. Also
where [SPF, DKIM and DMARC](#spf-dkim-and-dmarc) live.

### UPSERT

The word Route 53 uses in its JSON change files meaning "create this record, or
overwrite it if it already exists". It appears throughout
[Track B](20-aws.md#44-point-the-domain-at-it) and matters because it makes
those commands safe to run twice.

### WHOIS

The public directory of who owns which domain. Registration would otherwise
publish your name and home address; **privacy protection** replaces them with
the registrar's details and is free at every registrar this guide mentions.
Leave it on.

### Zone

Your slice of DNS — the complete set of records answering questions about your
domain. AWS calls it a **hosted zone** and charges monthly for it; Cloudflare
just calls it your domain and doesn't. Records live inside a zone, and editing
records in a zone that isn't [delegated](#delegation) is a popular way to spend
an hour changing nothing.

---

## Security and certificates

### ACM

AWS Certificate Manager — the service that issues and auto-renews free
[certificates](#certificate) for AWS. One rule catches everybody: **a
certificate used by [CloudFront](#cloudfront) must be issued in the `us-east-1`
region**, whatever region you or your users are in
([Track B](20-aws.md#42-the-certificate--us-east-1-always)).

### Certificate

A file proving that whoever is serving `yourthing.com` really controls
`yourthing.com`, so the browser shows a padlock rather than a red warning. It is
[layer 4](06-four-layers.md#layer-4--the-certificate), it is free, and in both
tracks it is issued and renewed for you.

### Certificate authority

An organisation browsers trust to issue [certificates](#certificate) — [Let's
Encrypt](#lets-encrypt), [ACM](#acm), and others. Before issuing, it must verify
you control the domain, which is why certificate setup so often sits waiting on
a DNS record. See [domain validation](#domain-validation).

### Domain validation

The proof step a [certificate authority](#certificate-authority) demands: it
gives you a specific [TXT](#txt-record) or [CNAME](#cname) record to publish, or
a file to serve, and issues only once it can read it back. A certificate stuck
on *"pending validation"* is
[layer 4 waiting on layer 2](90-troubleshooting.md#the-certificate-is-stuck-pending)
— check the record actually resolves with [`dig`](#dig).

### HSTS

A rule a site (or an entire [TLD](#tld)) can publish saying "only ever reach me
over HTTPS". Browsers then refuse plain HTTP with no click-through. The whole
`.dev` TLD is on the preload list, so a half-finished `.dev` setup looks
completely broken rather than partly working ([Track B](20-aws.md#32-find-your-hosted-zone)).

### HTTPS

HTTP with the connection encrypted, using [TLS](#tls-and-ssl) and a
[certificate](#certificate). Browsers now warn on sites without it, so it isn't
optional — but both tracks give it to you automatically, and neither charges for
it.

### Let's Encrypt

The non-profit [certificate authority](#certificate-authority) that made
certificates free in 2015, after which everyone else followed. You probably
won't use it directly here — Cloudflare and AWS issue their own — but it's the
reason [layer 4](06-four-layers.md#layer-4--the-certificate) costs nothing.

### Row Level Security

A setting in Postgres — the open-source database [Supabase](#supabase) is built
on — controlling which rows each user may read or write. It is the *only* thing
standing between a public
[anon key](#anon-key) and your entire database. If you built on
[Supabase](#supabase), confirm RLS is on and the policies are right
[before the repo goes public](07-github.md#3-what-counts-as-a-secret).

### SNI

Server Name Indication — the part of the [TLS](#tls-and-ssl) handshake where the
browser says which hostname it wants, so one server can hold certificates for
many sites. You'll only ever see it as `"SSLSupportMethod": "sni-only"` in the
[CloudFront config](20-aws.md#43-cloudfront-with-a-private-bucket). Leave it as
written.

### TLS and SSL

The encryption that puts the S in [HTTPS](#https). **They are the same thing
under two names:** SSL is the old protocol, TLS the modern replacement, and the
industry never stopped saying "SSL" out of habit. When a dashboard says SSL and
a command says TLS, they mean each other.

---

## Hosting and the cloud

### ARN

Amazon Resource Name — the long unique identifier AWS gives every single thing
it owns, like
`arn:aws:iam::123456789012:role/github-deploy`. You'll copy them constantly on
[Track B](20-aws.md); the useful habit is reading them left to right as
service, account, then thing.

### Binding

Cloudflare's word for connecting a resource — a database, a
[KV](#workers-kv) store, an [R2](#r2) bucket — to your code, so it appears on
`context.env` at runtime with no connection string to manage. Added under
Settings → Bindings ([Track A](10-cloudflare.md#if-you-need-to-store-data)).

### Bucket

A container for files in [S3](#s3) — think "a folder with a globally unique
name". Yours stays completely private in this guide; only
[CloudFront](#cloudfront) is allowed to read it. **Never put dots in the name**,
for a [TLS](#tls-and-ssl) reason explained at
[Track B, 4.1](20-aws.md#41-the-bucket).

### Budget alarm

An AWS setting that emails you when spending crosses a threshold. It is the
seatbelt for [Track B](20-aws.md#13-a-budget-alarm--also-now), because this
guide's whole setup should cost under a pound a month — so a $5 alarm means
*something is wrong*, not *you're being frugal*. Set it before you build
anything ([accounts](04-accounts.md#2-set-a-budget-alarm--before-you-build-anything)).

### Build command

The command your host runs to turn your source into servable files, almost
always `npm run build`. Static sites with no [build step](#build-step) leave it
empty. Getting it wrong shows up as a failed build with a readable log; getting
the [output directory](#output-directory) wrong shows up as a *successful* build
and a blank site, which is much more confusing.

### Build step

The stage where source code becomes plain files a browser can read — React, Vue,
Svelte, Vite and Astro projects all have one; a folder of hand-written HTML does
not. Whether you have one decides several answers in
[the chooser](02-start-here.md#shape-1--a-static-site).

### Cache

A stored copy of something, kept so it needn't be fetched again. There are at
least four caches between your files and a visitor's eyes — your browser, your
[resolver](#resolver), the [CDN](#cdn), and the host — and "old version still
showing" is nearly always one of them rather than a failed deploy
([troubleshooting](90-troubleshooting.md#old-version-still-showing)).

### Cache invalidation

Telling a [CDN](#cdn) to throw away its stored copies so it fetches fresh ones.
Cloudflare calls it **Purge Everything**; CloudFront calls it an invalidation
(`aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"`),
and it takes a couple of minutes. Clear the browser first — it's free and it's
the answer more often.

### CDN

Content delivery network — a fleet of servers around the world that keep copies
of your files so visitors are served from somewhere near them. Cloudflare and
[CloudFront](#cloudfront) are both CDNs. It is also the thing that serves an old
version of your site after you deploy, which is the price of the speed.

### Cloudflare Pages

Cloudflare's hosting product for static sites and [Pages
Functions](#pages-functions): you connect a GitHub repo, it builds on every
[push](#push) and serves the result worldwide with a [certificate](#certificate)
included. It's the whole of [Track A](10-cloudflare.md#3-deploy-the-site).

### CloudFront

AWS's [CDN](#cdn). On [Track B](20-aws.md#43-cloudfront-with-a-private-bucket)
it does three jobs at once: holds your domain name, handles the encrypted
[HTTPS](#https) connection using the [ACM](#acm) certificate (the jargon for
that is "terminating TLS"), and reads files from a private [S3](#s3) bucket that
nobody else can touch.

### Cold start

The extra delay on the first request to a [serverless](#serverless) function
after it has been idle, while the platform starts a copy of it — typically a
fraction of a second. It's the honest trade for paying nothing when nobody
visits, and at personal-project scale it is not worth engineering around.

### Cost Explorer

The AWS screen that breaks your bill down by service. When a charge appears you
don't recognise, group by service there first — it's usually the
[hosted zone](#zone) or a [NAT gateway](#nat-gateway) created by accident
([troubleshooting](90-troubleshooting.md#track-b--aws-specifics)).

### D1

Cloudflare's managed SQL database — SQLite, the small single-file database
engine, run for you — attached to your code as a [binding](#binding). The right
choice on [Track A](10-cloudflare.md#if-you-need-to-store-data)
when you need real tables and queries rather than simple key-value storage.

### Deploy

Making the version of your project that's on your machine become the version
strangers see. After both tracks are set up, deploying is `git push` and nothing
else — the [workflow](#workflow) or the host does the rest.

### Distribution

CloudFront's word for one CDN configuration — which [origin](#origin-hosting) to
read from, which domain names to answer for, which
[certificate](#certificate) to present. Its ID (`E1ABCDEF…`) is what you pass to
[invalidation](#cache-invalidation) commands, and it's
[safe to publish](07-github.md#3-what-counts-as-a-secret).

### Durable Objects

Cloudflare's answer for things that must remember where they got to and keep a
connection open rather than answering one request and forgetting — a chat room,
multiplayer, a live game. (The open-connection technique is called a
*websocket*.) Mentioned once in this guide as the advanced escape hatch for
[Shape 3](02-start-here.md#the-honest-note-about-shape-3); it's a step beyond a
first deploy.

### Edge

Shorthand for "the CDN servers near your visitors", as opposed to the single
place your files are stored. "Runs at the edge" means your code executes in a
data centre close to whoever asked, which is how
[Workers](#workers) respond quickly worldwide without you deploying anywhere.

### Eventual consistency

The property that a change to a cloud service may take a few seconds to become
visible everywhere. It's why [Track B](20-aws.md#52-a-role-for-it) has a literal
`sleep 10` after creating an IAM [role](#role): the role exists, Lambda just
can't see it yet, and the error blames the role rather than the timing.

### Free tier

The amount of a paid service you can use for nothing. Two shapes worth telling
apart: Cloudflare's free tiers generally **stop serving** when exhausted, while
AWS's generally **start charging** — which is the real reason
[the chooser](02-start-here.md#question-2--which-track) treats bill-shock risk as
a temperament question. Always check the live pricing page; published limits
change.

### Function URL

An HTTPS address AWS gives a [Lambda](#lambda) so it can be called directly.
The older way needed API Gateway — a separate, more configurable AWS service
that sits in front of a function and routes requests to it — which a first
project can happily skip. Creating a function URL is two commands, not one: the
URL alone returns [403](#http-status-code) until you also
[add the permission](20-aws.md#53-deploy-it-and-give-it-a-url).

### Infrastructure as code

Describing your cloud setup in files you commit, instead of clicking around a
provider's web dashboard (AWS calls its dashboard **the console**) — AWS SAM,
CDK and Terraform are the usual tools. Worth looking at *after* you've done this
guide by hand twice, because then you'll understand what the tool generates
instead of copying a template you can't debug.

### Lambda

AWS's [serverless](#serverless) compute: your code runs when a request arrives,
then stops. You pay per request, the free allowance is large, and it's how
[Track B adds a backend](20-aws.md#part-5--adding-a-backend-shape-2). The
equivalent on Track A is a [Pages Function](#pages-functions).

### Managed platform

A host that runs a whole always-on process for you — Fly.io, Railway, Render,
Streamlit Community Cloud, Hugging Face Spaces. (Supabase and Neon are the same
idea for a database rather than for your code.) Neither track's free tier suits
[Shape 3](02-start-here.md#the-honest-note-about-shape-3), so this is where a
Flask app or a Discord bot should go; the domain and DNS parts of this guide
still apply unchanged.

### NAT gateway

An AWS networking component that costs real money per hour and is easy to create
by accident when following an unrelated tutorial. Named here only so that if an
unexplained charge appears in [Cost Explorer](#cost-explorer), you recognise the
usual suspect.

### Object

What S3 calls a file. A [bucket](#bucket) holds objects, each with a key (its
path) and its contents. The distinction only matters when reading AWS
documentation, which never says "file".

### Origin (hosting)

The place a [CDN](#cdn) fetches from when it doesn't have a copy — your
[S3 bucket](#bucket), or a [Lambda](#lambda) behind `/api/*`. **This word means
something completely different in git** — see [origin (git)](#origin-git) — and
they appear on the same pages of this guide, which is genuinely confusing rather
than your misunderstanding.

### Origin Access Control

The CloudFront feature that lets a [distribution](#distribution) read a private
[S3 bucket](#bucket) that is closed to everybody else. Usually written OAC. It
is what makes ["private bucket, public site"](20-aws.md#43-cloudfront-with-a-private-bucket)
possible, and it's paired with a bucket [policy](#policy) naming your specific
distribution.

### Output directory

The folder your [build step](#build-step) produces — `dist/`, `build/`, `out/`,
`_site/`, `public/`. Point the host at the wrong one and you get a green build
and a blank site, the most common non-error failure in this guide. To find it,
run the build locally and look at which folder appears
([Track A](10-cloudflare.md#3-deploy-the-site)).

### Pages Functions

Cloudflare Pages' built-in backend: any file in a `functions/` folder at the
**repo root** becomes an API [endpoint](#endpoint) matching its path, with no
separate deploy. `functions/api/ask.js` answers at `/api/ask`. Put the folder
inside `src/` and your API returns your HTML instead
([Track A](10-cloudflare.md#5-only-if-you-have-a-backend-shape-2)).

### Preview deployment

A complete, separately-addressed copy of your site built from a
[pull request](#pull-request), so you can look at a change before merging it.
Cloudflare Pages does this automatically for every PR, and it's one of the
genuinely nice things you get for free ([Track A](10-cloudflare.md#6-from-now-on)).

### R2

Cloudflare's file storage, compatible with the [S3](#s3) API and — the reason
people choose it — with no charge for data leaving it. Good for user uploads and
images ([Track A](10-cloudflare.md#if-you-need-to-store-data)).

### Region

The physical location of an AWS service — `eu-west-2` is London, `us-east-1` is
Northern Virginia. Mostly you pick one near you and forget it, with two
exceptions on [Track B](20-aws.md): [ACM](#acm) certificates for CloudFront
**must** be in `us-east-1`, and bucket creation in `us-east-1` needs the
`--create-bucket-configuration` flag omitted or it fails with
`InvalidLocationConstraint`.

### Rollback

Putting a previous version back as the live one. On Cloudflare Pages it's a
button next to any past deployment and takes effect immediately without touching
your git history ([Track A](10-cloudflare.md#6-from-now-on)).

### Runtime

The language version a [Lambda](#lambda) runs on, written like `nodejs24.x`.
Runtimes go stale and AWS eventually refuses the old ones, so if a
`create-function` call rejects your runtime string, check the
[supported list](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html)
before debugging anything else.

### S3

AWS's file storage, and where your site's files live on
[Track B](20-aws.md#part-4--hosting-your-files-shape-1). Files go in a
[bucket](#bucket); the bucket stays private; [CloudFront](#cloudfront) is the
only thing allowed to read it.

### Serverless

Code that runs per request and then stops, on machines you never see or manage.
There are still servers — you just don't own, patch or pay for idle ones. Both
tracks' backends ([Workers](#workers), [Lambda](#lambda)) are serverless, which
is why a personal project's backend rounds to free.

### SPA

Single-page app — a site where JavaScript rewrites the page as you navigate,
rather than the server sending a new document (React Router and Vue Router are
the usual signs). It has one deployment consequence: deep links like
`/about` [return 404](20-aws.md#43-cloudfront-with-a-private-bucket) because
there's no `about.html`, until you configure 403 and 404 to serve
`/index.html` with status 200.

### Static site

A site made only of files — HTML, CSS, JavaScript, images — with nothing running
on the server. It's the cheapest and most robust thing to host, and it includes
anything with a [build step](#build-step) that outputs a folder. See
[Shape 1](02-start-here.md#shape-1--a-static-site).

### Static site generator

A tool that turns templates and content into a folder of plain files — Astro,
Eleventy, Hugo, Jekyll, Next.js in static-export mode. From the host's point of
view the result is just a [static site](#static-site); all you need to know is
its [build command](#build-command) and [output directory](#output-directory).

### Supabase

A hosted Postgres (open-source database) platform with logins and live updates
built in, commonly
paired with either track. Its **anon key** is designed to be public — but only
safely so if [Row Level Security](#row-level-security) is on and your policies
are correct ([05-github](07-github.md#3-what-counts-as-a-secret)).

### Virtual machine

A whole computer you rent, that stays on and that you're responsible for
patching. Sometimes the honest answer for
[Shape 3](02-start-here.md#the-honest-note-about-shape-3) — a Discord bot or a
game server — and unlike everything else in this guide it costs money whether or
not anyone visits.

### Workers

Cloudflare's [serverless](#serverless) platform, running your code at the
[edge](#edge). [Pages Functions](#pages-functions) are Workers with the
configuration hidden; Cloudflare is gradually merging the two products, which is
why documentation may push you towards Workers when Pages is
[simpler for a first deploy](10-cloudflare.md#3-deploy-the-site).

### Workers KV

Cloudflare's key-value store: you save a value under a name and fetch it back by
that name. Good for settings, sessions and counters; no good for anything where
you need to search or combine records. Attached to your code as a
[binding](#binding); for real tables use [D1](#d1).

### `wrangler`

Cloudflare's command-line tool, used for logging in and for deploying Workers.
Run it with `npx wrangler …` rather than installing it globally, so you always
get a current version. Like the AWS CLI, it holds its own login — which is why
you never paste a Cloudflare secret into a chat.

---

## Git and GitHub

### Branch

A named line of development. `main` is the one that deploys; making a branch
lets you work on something without touching what's live, and a
[pull request](#pull-request) is how it comes back. For a solo project you can
happily work on `main` for a long time.

### CI and CD

Continuous integration and continuous deployment — jargon for "a server runs
your checks and your deploy automatically when you push". You get CD in this
guide the moment [GitHub Actions](#github-actions) or Cloudflare Pages starts
building on push; you don't need to say the words to use it.

### Clone

Making a local copy of a [repository](#repository) that stays connected to the
original, with `git clone` or `gh repo clone`. Distinct from a [fork](#fork),
which makes a copy *on GitHub* under your own account.

### Commit

A saved snapshot of your project, with a message describing it. **Commits are
effectively permanent**: a secret committed and deleted in the next commit is
still in the history and still fetchable, which is why
[`.gitignore` comes first](07-github.md#2-write-gitignore-before-your-first-commit).

### Fork

Your own copy of somebody else's [repository](#repository), on GitHub, under
your account. It's what GitHub offers when you try to edit a repo you don't own,
and it's step one of adding yourself to
[the showcase](30-share-it.md#3-add-yourself-to-the-showcase) — you're editing
your copy, not mine, and you can't break anything.

### Force-push

Overwriting the [repository](#repository)'s history with a different version of
it, needed after any [history rewriting](#history-rewriting). It breaks every
existing [clone](#clone) and [fork](#fork), so it's painless on a repo nobody
else has and disruptive on one they do.

### `gh`

GitHub's official command-line tool. It creates repos, sets
[secrets](#github-secret) and watches [workflow](#workflow) runs without you
opening a browser, and `gh auth login` handles authentication properly so you
never deal with a [personal access token](#personal-access-token)
([05-github](07-github.md#1-install-the-two-tools)).

### `git`

The program on your machine that tracks changes to your files. **git is not
GitHub** — git is the tool and works entirely offline; [GitHub](#github) is a
website that stores copies of git repositories. Almost every "I don't understand
git" moment starts with that conflation.

### `.gitignore`

A file listing patterns git should never track — `.env`, `node_modules/`,
`dist/`, `*.pem`. It must exist **before your first commit**, because it only
prevents things being added, and cannot remove what's already in the history
([05-github](07-github.md#2-write-gitignore-before-your-first-commit)).

### GitHub

The website that hosts git [repositories](#repository), plus everything built
around them — [pull requests](#pull-request), [Actions](#github-actions),
[issues](#issue), [secret scanning](#secret-scanning). Both tracks deploy *from*
a GitHub repo, which is why [05-github](07-github.md) comes before either.

### GitHub Actions

GitHub's built-in automation: you commit a [workflow](#workflow) file, and
GitHub runs it on a machine it provides whenever the trigger fires. On
[Track B](20-aws.md#63-the-workflow) it's what makes `git push` deploy to AWS;
it's also a free way to run a scheduled job.

### GitHub secret

An encrypted value stored on your repository, readable by
[workflows](#workflow) as `${{ secrets.NAME }}` and never displayable again in
the UI. [Track B](20-aws.md#63-the-workflow) puts the
[AWS account ID](#aws-account-id) here — not because it's a credential, but
because it's reconnaissance you needn't hand out.

### GitHub variable

The same idea as a [secret](#github-secret) but not hidden — you can read it
back, and it's for values that are effectively public anyway, like a
[bucket](#bucket) name or a [distribution](#distribution) ID. Referenced as
`${{ vars.NAME }}`.

### History rewriting

Editing past [commits](#commit) to remove something — usually a leaked secret —
with [`git-filter-repo`](https://github.com/newren/git-filter-repo) or
[BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/). It requires a
[force-push](#force-push), and it is always the *second* step: **rotate the key
first**, because a public commit is scraped within seconds
([05-github](07-github.md#6-if-youve-already-leaked-something)).

### Issue

A numbered discussion thread on a repository — a bug report, a question, a
suggestion. Opening one is how you tell this guide it's wrong, and how you'd
report a broken step or an out-of-date price.

### Licence

The file saying what others may legally do with your code. Without one, "public"
means "you may look and nothing else" — nobody may use, [fork](#fork) or build
on it. See [MIT](#mit-licence); GPL-3.0 if you want changes shared back;
Unlicense if you genuinely don't care.

### `main`

The default [branch](#branch) name on GitHub, and by convention the one that
deploys. Older repositories and documentation call it `master`; they are the
same thing under an older name.

### Merge

Combining one [branch](#branch) into another — usually accepting a
[pull request](#pull-request) into [`main`](#main). On a repo with automatic
deploys, merging to `main` is what makes the change go live.

### MIT licence

The standard "do what you like, don't sue me" [licence](#licence), and what most
personal projects use, including this one. It's three paragraphs long; you edit
the year and your name and you're done
([05-github](07-github.md#add-a-licence)).

### Open source

Publishing your code under a [licence](#licence) that lets other people use and
change it. It is a legal state, not a quality bar — half-finished things that
work are entirely welcome, and adding yourself to
[the showcase](30-share-it.md#3-add-yourself-to-the-showcase) may well be your
first contribution to someone else's.

### Origin (git)

The default name for the [remote](#remote) your repository was cloned from or
first pushed to — in practice, "the copy on GitHub". **This is a completely
different meaning from [origin in a CDN](#origin-hosting)**, and both appear in
this guide. If a sentence mentions pushing, it's this one; if it mentions
caching, it's the other.

### Personal access token

A long-lived password-substitute some tools want for GitHub. You shouldn't need
one: `gh auth login` uses a browser flow and stores credentials properly for
both [`gh`](#gh) and [`git`](#git). If something is asking you to create a
token, check whether `gh auth login` would do instead.

### Pull request

A proposal to merge one [branch](#branch) into another, with a place to discuss
it first. Often shortened to PR. It is also how you contribute to somebody
else's project, and [the showcase](30-share-it.md#3-add-yourself-to-the-showcase)
walks through making one entirely in the browser, with no terminal.

### Push

Sending your local [commits](#commit) to the [remote](#remote), with `git push`.
Once either track is set up, this is your deploy — everything that follows
happens without you.

### Push protection

A GitHub feature that **blocks a [push](#push)** containing something matching a
known credential format, before it ever reaches the server. Free on public
repos, enabled with one `gh repo edit` flag, and it has saved an enormous number
of people from a very bad afternoon
([05-github](07-github.md#turn-on-the-safety-nets)).

### README

The file GitHub shows on your repository's front page. People decide in seconds
whether to keep reading, so it leads with one sentence, a live link and a
screenshot —
[30-share-it](30-share-it.md#2-write-a-readme-worth-reading) gives the running
order.

### Remote

A copy of your [repository](#repository) that lives somewhere else, referred to
by a short name. You'll almost always have exactly one, called
[`origin`](#origin-git), pointing at GitHub.

### Repository

A project tracked by [git](#git) — your files plus their entire history. Often
shortened to repo. Both tracks treat the repo as the source of truth: what's on
`main` is what's live.

### Runner

The temporary machine GitHub provides to execute a [workflow](#workflow), named
in the file as `runs-on: ubuntu-latest`. Two consequences bite people: it's
Linux, so [filename case matters](#case-sensitivity), and it starts empty, so
anything your build needs must be installed or committed.

### Secret scanning

GitHub scanning your repository for strings that look like credentials and
alerting you. Free on public repos. Its more useful sibling is
[push protection](#push-protection), which stops the secret arriving in the
first place.

### Stage

Marking changes to be included in the next [commit](#commit), with `git add`.
The gap between staging and committing exists precisely so you can run
`git status` and *actually look* before anything becomes permanent
([05-github](07-github.md#5-make-the-repository)).

### Topics

Keyword tags on a GitHub repository, set from the gear next to *About*. They're
most of how anyone discovers a repo, so pick five or six that genuinely describe
it — the language, the kind of thing it is, where it runs
([30-share-it](30-share-it.md#2-write-a-readme-worth-reading)).

### Workflow

A [YAML](#json) file in `.github/workflows/` describing what
[GitHub Actions](#github-actions) should run and when. Track B's is a dozen
lines: check out the code, build it, assume an AWS [role](#role) via
[OIDC](#oidc), sync to [S3](#s3), invalidate
[CloudFront](#cache-invalidation).

---

## Keys and identity

### Access key

An AWS credential in two parts: an **access key ID** (starts `AKIA…`,
semi-public) and a **secret access key**, shown exactly once and never
recoverable. Together they let the CLI act as you. Never create one for the
[root account](#root-account), never commit one, and
[rotate on suspicion](#rotate-a-key)
([03-keys-and-access](05-keys-and-access.md#the-three-legitimate-homes-for-a-key)).

### Anon key

A key deliberately designed to sit in browser code — Supabase's anon key,
Stripe's `pk_` publishable key. Safe to publish **only** if the service's access
rules are correct behind it; for Supabase that means
[Row Level Security](#row-level-security)
([05-github](07-github.md#3-what-counts-as-a-secret)).

### API key

A string that identifies and authorises your app when it calls somebody else's
service. It is a password with a bill attached: whoever holds it can spend your
money. This is why it lives in an [environment variable](#environment-variable)
on the server and never in browser code
([03-keys-and-access](05-keys-and-access.md#1-what-an-api-key-actually-is)).

### Audience claim

The `aud` field in a [JWT](#jwt), naming who the token is *for* — in
[Track B's OIDC setup](20-aws.md#62-a-role-only-your-repo-can-assume) it must
equal `sts.amazonaws.com`. Along with the [subject claim](#subject-claim), it's
one half of what the [trust policy](#trust-policy) checks.

### Authentication and authorisation

**Authentication is who you are; authorisation is what you're allowed to do.**
They're both shortened to "auth", which is why error messages are confusing: a
403 usually means you authenticated fine and simply aren't permitted, and
retyping your password will not help.

### AWS account ID

The twelve-digit number identifying your AWS account. Not a credential — it
appears in every [ARN](#arn) — but it is useful reconnaissance for an attacker,
so this guide puts it in a [GitHub secret](#github-secret) rather than a
[variable](#github-variable).

### Blast radius

How much damage a credential could do if it were misused. Track B scopes the
deploy [role](#role) to exactly one [bucket](#bucket) and one
[distribution](#distribution), so the worst case is "overwrite my site" rather
than "empty my bank account" ([20-aws](20-aws.md#62-a-role-only-your-repo-can-assume)).

### Claim

One statement inside a [JWT](#jwt) — "this token is for GitHub Actions", "it
came from repository X, branch main". AWS reads the claims to decide whether to
hand back credentials, which is why the fix for a failing
[OIDC](#oidc) setup is to *print the claims* rather than guess at them.

### Credential

Anything that proves identity to a system: a password, an
[access key](#access-key), an [API key](#api-key), a private key file. The
distinguishing test for this guide is simple — if publishing it would let a
stranger act as you, it's a credential and it never touches your repo.

### `.env`

A plain text file of `NAME=value` lines holding your local secrets, read by your
app at startup. It must be in [`.gitignore`](#gitignore) from the very
beginning. Its committed sibling `.env.example` lists the *names* with fake
values so anyone cloning your repo knows what to fill in
([03-keys-and-access](05-keys-and-access.md#the-three-legitimate-homes-for-a-key)).

### Environment variable

A named value handed to a program by whatever started it, rather than written
inside it. It's how the same code runs with a real key in production and a test
key locally. Two things catch people: variables are read at build or start time,
so **a change needs a redeploy**, and setting one in a terminal lasts only for
that terminal
([03-keys-and-access](05-keys-and-access.md#what-an-environment-variable-actually-is)).

### IAM

Identity and Access Management — AWS's system of [users](#iam-user),
[roles](#role) and [policies](#policy) deciding who may do what. Nearly every
confusing AWS error is an IAM error wearing a different hat.

### IAM Identity Center

AWS's newer login system, where `aws sso login` grants short-lived credentials
and nothing durable sits on disk. Genuinely better than an
[access key](#access-key), and more moving parts than a first project needs —
[Track B](20-aws.md#24-check-it-and-save-your-account-id) says start simple and
upgrade later.

### IAM user

A named identity inside your AWS account, separate from the
[root account](#root-account), with its own credentials. You create one for the
CLI so that a leaked key can be deleted without losing the account itself
([accounts](04-accounts.md#what-an-iam-user-is-and-why-you-make-one)).

### Identity provider

A system another system agrees to trust for authentication. Track B registers
GitHub as one in AWS, which is what makes
[keyless deploys](20-aws.md#61-trust-github-as-an-identity-provider) possible:
AWS believes GitHub when it vouches for a workflow run.

### JWT

JSON Web Token — a signed blob of [JSON](#json) asserting facts
([claims](#claim)) about who is calling. GitHub mints one per workflow run and
AWS verifies it. The parts you may print — `sub`, `aud`, `repository` — are not
secret, but **the whole token is a credential**, so never log it
([20-aws](20-aws.md#62-a-role-only-your-repo-can-assume)).

### Least privilege

Granting exactly the permissions needed and no more. This guide deliberately
breaks it once, using `AdministratorAccess` on a personal account, and says why:
fighting permission errors all afternoon is a worse outcome than relying on
[MFA](#mfa) and a [budget alarm](#budget-alarm) as the real guardrails
([20-aws](20-aws.md#21-an-iam-user)).

### MFA

Multi-factor authentication, also written 2FA — a code from an app on top of
your password. Turn it on for GitHub, Cloudflare and especially the AWS
[root account](#root-account) before anything else, because it removes an entire
category of disaster for two minutes' work
([accounts](04-accounts.md#3-turn-on-two-factor-authentication)).

### OIDC

OpenID Connect — the standard letting GitHub prove a workflow run's identity to
AWS directly, so AWS can hand back credentials that expire in minutes. The point
is that **no AWS key exists in GitHub at all**
([20-aws](20-aws.md#part-6--deploys-without-storing-a-key)).

### Policy

A JSON document listing permitted actions and the resources they apply to. Two
kinds appear in this guide: permission policies attached to a [role](#role)
saying what it may *do*, and [trust policies](#trust-policy) saying who may
*become* it.

### Principal

The "who" in an AWS [policy](#policy) — an account, a [role](#role), or an AWS
service such as `cloudfront.amazonaws.com` or `lambda.amazonaws.com`. Every
`Principal` block in [Track B](20-aws.md) is naming who is allowed to do the
thing described next to it.

### Role

An AWS identity that can be *assumed* temporarily, rather than logged into. A
[Lambda](#lambda) runs as one; a GitHub workflow assumes one via
[OIDC](#oidc). Roles are how AWS avoids long-lived keys, and are the single most
useful IAM concept to actually understand.

### Root account

The email and password you created an AWS account with. It can do anything,
including close the account and spend without limit. Give it
[MFA](#mfa) immediately, never create an [access key](#access-key) for it, and
use an [IAM user](#iam-user) for daily work
([accounts](04-accounts.md#the-root-account-plainly)).

### Rotate a key

Delete a credential and issue a replacement. Do it **on suspicion, not proof** —
it takes thirty seconds, and it's the first step when anything leaks, before any
tidying of git history
([03-keys-and-access](05-keys-and-access.md#6-when-a-key-leaks)).

### Secret

Any value that would let someone act as you or spend your money. The line is
drawn concretely in [05-github](07-github.md#3-what-counts-as-a-secret) — source
code, domain names and bucket names are fine to publish; `.env` files, `AKIA…`
keys, `sk_` keys and `.pem` files never are.

### Secrets Manager

AWS's dedicated store for secrets, with per-secret monthly pricing. Worth
graduating to for anything you'd genuinely mind leaking, because
[Lambda](#lambda) environment variables are visible to anyone with console read
access to the function ([20-aws](20-aws.md#54-secrets-for-the-function)).

### STS and AssumeRole

STS is AWS's Security Token Service — the thing that hands out temporary
credentials. `sts:AssumeRole` is asking to become a [role](#role);
`sts:AssumeRoleWithWebIdentity` is the [OIDC](#oidc) variant GitHub uses.
`aws sts get-caller-identity` is also the quickest way to check your CLI is
working at all.

### Subject claim

The `sub` [claim](#claim) in GitHub's [JWT](#jwt), identifying which repository
and branch the workflow ran in. It is the security boundary of the whole
keyless-deploy setup. Since mid-2026 GitHub gives every newly created, renamed
or transferred repository an **ID-qualified** (GitHub calls it *immutable*)
subject — `repo:you@8456990/your-repo@1329892525:ref:refs/heads/main`, where the
numbers are the permanent account and repository IDs — so a repo you make while
following this guide almost certainly has one, and patterns you guessed from an
older tutorial won't match. Print the real value rather than guessing, and never
widen it with wildcards
([20-aws](20-aws.md#62-a-role-only-your-repo-can-assume)).

### Trust policy

The [policy](#policy) attached to a [role](#role) saying *who may assume it* —
as opposed to what it can do once assumed. Track B's trust policy is what
restricts an AWS role to workflows from one specific GitHub repository, and a
mismatch there produces `Not authorized to perform
sts:AssumeRoleWithWebIdentity`.

---

## Web and general

### Absolute and relative URL

A relative URL (`/preview.png`) is interpreted against the page it appears on;
an absolute one (`https://yourthing.com/preview.png`) works from anywhere. It
matters most for [Open Graph](#open-graph) images: the machine fetching your
page to build a link preview isn't on your site, so a relative path means
nothing to it and the preview comes out blank
([30-share-it](30-share-it.md#1-make-the-link-look-like-something-when-its-shared)).

### API

An interface one program uses to talk to another, over the web in this guide's
sense. Your page calls *your* API at `/api/ask`, and your API calls somebody
else's — Anthropic's, say — with an [API key](#api-key) the browser never sees.

### `apt`

The [package manager](#package-manager) on Debian and Ubuntu, and therefore
inside [WSL](#wsl). `sudo apt install git jq curl zip dnsutils` installs most of
what this guide needs ([00-start-here](02-start-here.md#what-you-need-on-your-machine)).

### `bash`

The shell language this guide's commands are written in — the default on Linux
and inside [WSL](#wsl), and available on macOS. **Its syntax is not
PowerShell's**, which is why Windows users are pointed at WSL or
[Git Bash](#git-bash) before Track B in particular
([00-start-here](02-start-here.md#what-you-need-on-your-machine)).

### Browser cache and hard reload

Your browser keeps its own copies of pages, scripts and images, separately from
any [CDN](#cdn). A hard reload — **Cmd/Ctrl + Shift + R** — fetches fresh
copies, and a private window sidesteps the cache entirely. Do this *before*
suspecting a deploy failed; it's five seconds and it's the answer more often
than not.

### Case sensitivity

Linux treats `Header.jsx` and `header.jsx` as different files; macOS and Windows
usually don't. Since builds [run on Linux](#runner), a filename whose case
doesn't match the import produces "module not found" for a file you can plainly
see ([troubleshooting](90-troubleshooting.md#the-build-works-locally-but-fails-on-the-host)).

### CLI

Command-line interface — a program you drive by typing rather than clicking, in
a [terminal](#terminal). `git`, `gh`, `aws` and `wrangler` are all CLIs. They
tend to be more reliable to follow in a guide than dashboards, because a
dashboard's menus get renamed and a command doesn't.

### `curl`

A command-line tool for fetching a URL, used throughout this guide to check
things from outside a browser. `curl -sI https://yourthing.com | head -1` prints
just the [status line](#http-status-code) — the fastest way to tell whether your
site is actually answering.

### Endpoint

One addressable URL that does something — `/api/ask`, `/api/save`. On
[Track A](10-cloudflare.md#5-only-if-you-have-a-backend-shape-2) each file in
`functions/` becomes one; on Track B a [Lambda](#lambda) behind `/api/*` does.

### ETag

A short identifier for the current version of a resource, used so that changes
can't overwrite each other. It matters in exactly one place here:
[deleting a CloudFront distribution](20-aws.md#part-9--turning-it-off) requires
a *fresh* ETag with each modification, and reusing a stale one fails.

### Favicon

The small icon shown in a browser tab, conventionally `favicon.ico` or a PNG
linked from your `<head>`. Not required for anything to work, but its absence
is the difference between a site that looks finished and one that doesn't —
worth adding alongside your [Open Graph](#open-graph) image
([30-share-it](30-share-it.md#1-make-the-link-look-like-something-when-its-shared)).

### Git Bash

A [bash](#bash) shell for Windows that comes with
[Git for Windows](https://gitforwindows.org/). Fine for Track A and for getting
onto GitHub; Track B's [heredocs](#heredoc) mostly work but path handling
occasionally bites, so [WSL](#wsl) is the better answer there.

### Headless browser

A real browser running with no window, driven by a script. It's how the guide's
`og-image.sh` renders a card to an exact 1200×630 PNG
([30-share-it](30-share-it.md#make-the-image)) — the same rendering as your
screen, just captured instead of displayed.

### Heredoc

The `cat > file <<EOF … EOF` shape used throughout [Track B](20-aws.md#part-4--hosting-your-files-shape-1)
to write a config file. **It is one command, not three** — paste the whole block
including the closing `EOF`. Paste it line by line and you'll sit at a bare `>`
prompt with no output and no error, waiting for the `EOF`; press `Ctrl-C` and
start again.

### Homebrew

The package manager most people use on macOS, installed with the one-line script
in [00-start-here](02-start-here.md#what-you-need-on-your-machine). After it,
`brew install git gh jq awscli` gets you everything both tracks need.

### HTML, CSS and JavaScript

The three languages a browser understands: HTML is the content and structure,
CSS the appearance, JavaScript the behaviour. A [static site](#static-site) is
these three plus images, and everything else in web development eventually
produces them.

### HTTP

The protocol browsers use to ask for pages and receive them. Plain HTTP is
unencrypted; [HTTPS](#https) is the same thing with [TLS](#tls-and-ssl) around
it. Both tracks redirect HTTP to HTTPS for you.

### HTTP header

A name-and-value line attached to a request or response, carrying things the
body doesn't — `content-type: application/json`, an API key, a cache
instruction. `curl -sI` shows you a response's headers without its body.

### HTTP status code

The three-digit number in every HTTP response saying how it went. The ones this
guide runs into:

| Code | Means | Usually because |
|---|---|---|
| 200 | Fine | Nothing to do |
| 403 | Forbidden | You're identified but not permitted — a bucket [policy](#policy), or a [function URL](#function-url) missing its `add-permission` |
| 404 | Not found | Wrong [output directory](#output-directory), or an [SPA](#spa) deep link with no error-page rule |
| 429 | Too many requests | A [free tier](#free-tier) limit — Cloudflare's failure mode instead of a bill |
| 500 | Server error | Your code threw — usually a missing [environment variable](#environment-variable) |
| 502 | Bad gateway | The thing in front couldn't reach the thing behind — e.g. CloudFront failing TLS to a dotted [bucket](#bucket) name |

### IP address

The numeric address of a machine on the internet — `104.21.5.12` (IPv4) or the
longer colon-separated IPv6 form. [DNS](#dns) exists to save you from ever
typing one, and [CNAME](#cname) records exist so your host can change theirs
without telling you.

### `jq`

A command-line tool for reading and reshaping [JSON](#json). Track B uses it to
pull IDs out of AWS responses and to build change files, which is why it's in
the install list ([00-start-here](02-start-here.md#what-you-need-on-your-machine)).

### JSON

A plain-text format for structured data — objects in braces, lists in brackets.
Nearly every AWS command returns it, every API in this guide speaks it, and
[YAML](#workflow) (used by GitHub Actions) is the same shapes with indentation
instead of punctuation.

### `localhost`

The name your computer uses for itself. `http://localhost:3000` is a server
running on your own machine, reachable by nobody else — which is precisely the
problem this guide exists to solve.

### Lockfile

A file recording the exact version of every dependency actually installed —
`package-lock.json` for [npm](#npm). **It must be committed**, because it's what
`npm ci` reads on the build machine; without it, the host resolves different
versions from yours and "works locally, fails on the host" follows.

### Node.js

The program that runs JavaScript outside a browser — used by build tools,
[Workers](#workers) and [Lambda](#lambda). Its version matters: a build that
works locally and fails on the host is most often a version mismatch, fixed by
setting `NODE_VERSION` (Track A) or `node-version` (Track B) to match your
`node -v`.

### `node_modules`

The folder holding your installed dependencies. It is enormous, machine-specific
and rebuildable from the [lockfile](#lockfile), so it belongs in
[`.gitignore`](#gitignore) and never in a [commit](#commit).

### `npm`

Node's [package manager](#package-manager). Three commands cover this guide:
`npm install` adds dependencies, `npm ci` installs exactly what the
[lockfile](#lockfile) says (what build machines use), and `npm run build` runs
your [build command](#build-command).

### Open Graph

The `<meta property="og:…">` convention every social platform reads to build a
link preview card. Four tags — title, description, image, url — decide whether a
shared link looks like something or like a bare blue link nobody clicks. Get it
right *before* you post, because platforms cache the first version they see
([30-share-it](30-share-it.md#1-make-the-link-look-like-something-when-its-shared)).

### Package manager

A tool that installs software and its dependencies for you:
[Homebrew](#homebrew) on macOS, [apt](#apt) on Ubuntu, [winget](#winget) on
Windows for system tools; [npm](#npm) for your project's JavaScript libraries.
Same idea, different scopes.

### Port

The numbered door on a machine that a particular program listens at — the
`:3000` in `http://localhost:3000`. Once your project is deployed you stop
thinking about ports, because the web uses 80 and 443 and the host handles both.

### PowerShell

Windows' own shell. **This guide's commands are [bash](#bash) and will not all
work in it** — the [heredocs](#heredoc) and quoting in Track B especially. Use
[WSL](#wsl), or [Git Bash](#git-bash), or take Track A, which needs far less
terminal ([00-start-here](02-start-here.md#what-you-need-on-your-machine)).

### Server

A program (on a machine somewhere) that waits for requests and answers them. The
useful distinction for this guide is between a [static site](#static-site),
where no program of yours runs at all, and a backend, where one does — and
between [serverless](#serverless), which starts one per request, and a
[virtual machine](#virtual-machine), which keeps one running.

### Shell

The program inside a [terminal](#terminal) that reads what you type and runs it.
[bash](#bash) and zsh are shells; [PowerShell](#powershell) is a different one
with different syntax. "Open a shell" and "open a terminal" are used
interchangeably in practice.

### Shell variable

A named value in your current terminal, set with `export NAME=value` and read
back as `$NAME`. The catch that bites hardest on
[Track B](20-aws.md#25-keep-your-variables-somewhere-that-survives): **it lasts
only as long as that window**. A new tab, and every variable is an empty string
— and commands then fail with something baffling like
`Invalid length for parameter` rather than "that's empty". Keep them in a file
and `source` it.

### Terminal

The window where you type commands. macOS has Terminal and iTerm; Windows has
Windows Terminal; Linux has several. It is only a window — the thing
interpreting your typing is the [shell](#shell)
([01-your-machine](03-your-machine.md)).

### URL

The full address of something on the web:
`https://yourthing.com/api/ask` is protocol, [hostname](#hostname), path.
Getting your project one — a real one, that you own — is the entire point of
this guide.

### `winget`

Windows' built-in [package manager](#package-manager).
`winget install Git.Git GitHub.cli` installs [git](#git) and [gh](#gh)
([05-github](07-github.md#1-install-the-two-tools)).

### WSL

Windows Subsystem for Linux — a real Ubuntu terminal inside Windows, installed
with `wsl --install` from an administrator PowerShell. It's the recommended
Windows setup here because every command in the guide then works exactly as
written, [heredocs](#heredoc) included
([00-start-here](02-start-here.md#what-you-need-on-your-machine)).

### `zip`

The command that packages files into a `.zip`, used to bundle a
[Lambda](#lambda) before uploading it. Preinstalled on macOS; on Ubuntu or WSL,
`sudo apt install zip` ([20-aws](20-aws.md#53-deploy-it-and-give-it-a-url)).

---

**Next:** [When it breaks →](90-troubleshooting.md) if something is failing
right now — otherwise back to [Start here](02-start-here.md).
