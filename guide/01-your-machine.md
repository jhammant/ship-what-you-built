# Your machine

**This page gets you a working terminal with the right tools in it — about 20
minutes on macOS or Linux, 30–45 on Windows.**

Nothing here touches your project or costs money — it's groundwork, and once
it's done you never do it again. Most of the Windows time is a reboot and a
download bar.

If you already have a terminal you're comfortable in, skip to
[the tools](#the-tools) and run [the check-everything script](#check-everything-at-once).

---

## What a terminal actually is

A terminal is a window where you type the name of a program and it runs. That's
the whole idea. Your desktop shows you programs as icons you click; the terminal
shows you programs as words you type. The same computer, the same files, a
different door in.

Inside that window is a **prompt** — a bit of text sitting at the left waiting
for you, usually ending in `$` or `%` or `>`. It often tells you who you are and
which folder you're in, like `you@laptop ~/projects $`. You type a command after
it, press **Enter**, and the computer does the thing. When it's finished, the
prompt comes back, which is how you know it's done.

This guide uses a terminal for a reason that isn't stubbornness: the things you
are about to do — buying a domain, pushing code, deploying a site — all have
web dashboards, and those dashboards get redesigned every few months. A command
is stable, copy-pasteable, and repeatable. It also means that when something
breaks at 11pm, you can paste the exact command and the exact error into Claude
Code and get a real answer, instead of describing a button you clicked.

### Five things that catch people out

- **No output usually means it worked.** Unix tools — Unix being the decades-old
  family of systems that macOS and Linux both descend from — are silent on
  success and noisy on failure. If you run a command and get nothing back but a
  fresh prompt, that is the good outcome, not a hang.
- **Pasting is not always Ctrl+V.** Use **Cmd+V** on macOS and
  **Ctrl+Shift+V** on Linux. In Git Bash it's **right-click** or
  **Shift+Insert**. Windows Terminal is the friendly one: Ctrl+V,
  Ctrl+Shift+V and right-click all paste.
- **Ctrl+C usually means "stop", not "copy".** In most terminals it interrupts
  the thing that's currently running, and the safe way to copy is
  **Ctrl+Shift+C** (Cmd+C on macOS). Windows Terminal is the exception — there,
  Ctrl+C copies when you have text selected and interrupts when you don't.
  Learning Ctrl+C as "stop" is genuinely useful: it's how you get out of a
  command that's sitting there doing nothing.
- **The up arrow brings back your last command.** Press it repeatedly to walk
  back through your history. This saves an enormous amount of retyping.
- **Tab completes.** Type the first few letters of a folder or file name and
  press Tab; the terminal fills in the rest. It also means you can't typo a
  filename that doesn't exist.

Two commands worth knowing before anything else: `pwd` prints the folder you're
currently in ("print working directory"), and `cd some-folder` moves you into
one. `cd ..` goes back up one level. If you're ever lost, `pwd` tells you where
you are.

---

## Windows

This section is long, and deliberately so. A **shell** is the program running
inside the terminal window that reads what you type and decides what it means —
different shells understand slightly different languages. **This guide is
written in bash**, the shell macOS and Linux use, and Windows does not have bash
out of the box. That gap is where most Windows readers give up, so here is the
whole thing.

### PowerShell and Command Prompt are not bash

Windows gives you two terminals already: **Command Prompt** (`cmd`, the older
one) and **PowerShell** (the modern one). Both are real, capable shells. Neither
of them speaks bash, and the difference is not cosmetic — commands from this
guide will fail in them, sometimes loudly and sometimes silently, which is
worse.

Four concrete examples, because "it's different" isn't useful:

| Thing this guide does | bash | PowerShell |
|---|---|---|
| Write a file inline: <br>`cat > f.json <<EOF` … `EOF` | Creates the file | `The '<' operator is reserved for future use` — heredocs don't exist |
| Literal text: `'{"Name":"a"}'` | Passed through exactly | Single quotes are literal in PowerShell too, but PowerShell then re-parses the argument when handing it to a native `.exe`, and JSON comes out mangled |
| A variable: `$BUCKET` and `export BUCKET=x` | Sets and reads a variable | `$BUCKET` is a PowerShell variable with different rules; `export` doesn't exist (it's `$env:BUCKET = "x"`) |
| Continue a long command on the next line with a trailing `\` | Joins the lines | The `\` is treated as text; PowerShell uses a backtick `` ` `` instead. The command runs half-finished |

A **heredoc** — the `cat > file <<EOF` pattern — is how this guide writes config
files and AWS policy documents. [Track B](20-aws.md) uses it repeatedly. If your
shell can't do heredocs, large parts of Track B simply won't work as written.

So you need a bash. There are two routes.

### Route 1 — WSL (recommended)

**WSL** stands for Windows Subsystem for Linux: a real Ubuntu Linux running
inside Windows, sharing your files and your network, with no dual-boot and no
virtual machine to manage. You open it like any other app. Every command in this
guide then works exactly as written, because you are genuinely on Linux.

It works on Windows 11 and on Windows 10 version 2004 or later. **Windows Home
is fine** — you do not need Pro, despite what older articles say.

> **On a work laptop?** WSL needs hardware virtualisation, which some corporate
> IT policies switch off and lock. If the steps below fail with a policy error,
> don't fight it — use [Git Bash](#route-2--git-bash) and
> [Track A](10-cloudflare.md), which between them need very little terminal.

#### Step 1 — Open PowerShell as Administrator

Installing WSL changes Windows features, so it needs administrator rights.

1. Press the **Windows key**, or click **Start**.
2. Type `powershell`.
3. In the results, **right-click** "Windows PowerShell" and choose **Run as
   administrator**. (On the newer Start menu, "Run as administrator" also
   appears in the panel on the right.)
4. A **User Account Control** box appears asking *"Do you want to allow this app
   to make changes to your device?"* — click **Yes**.

You'll know it worked because the window's title bar starts with
**Administrator:**. If it doesn't, you're in a normal PowerShell and step 2 will
fail with an access-denied error.

> On Windows 11 there's a shortcut: right-click the **Start** button itself and
> choose **Terminal (Admin)**.

#### Step 2 — Install it

```powershell
wsl --install
```

That single command turns on two Windows features, downloads the Linux kernel,
and installs Ubuntu. It prints progress lines like `Installing: Virtual Machine
Platform`, `Installing: Windows Subsystem for Linux`, `Downloading: Ubuntu`, and
finishes with something close to:

```text
The requested operation is successful. Changes will not be effective until the system is rebooted.
```

The download is a few hundred megabytes, so on a slow connection this takes a
while and the progress percentage can appear to stall. Let it.

#### Step 3 — Reboot

Actually reboot. Not "close the lid" — a real restart, from Start → Power →
Restart. WSL will not work until you do, and the error you get if you skip it
looks unrelated and will waste your evening.

#### Step 4 — Set your Linux username and password

After the reboot, an Ubuntu window usually opens by itself and says `Installing,
this may take a few minutes...`. If it doesn't appear, open **Start** and click
**Ubuntu**.

Then it asks two things:

```text
Enter new UNIX username:
```

Type a short, lowercase name with no spaces. It does **not** have to match your
Windows username and it isn't shown to anyone. `jon` is fine.

```text
New password:
```

> **The password shows nothing as you type. Not even asterisks.** The cursor
> does not move. This is not a broken keyboard and the window has not frozen —
> Unix has hidden password input since the 1970s and it panics everyone the
> first time. Type your password, press Enter, type it again when it asks to
> confirm, press Enter.

**Write this password down.** It is not your Windows password, it is not your
Microsoft account, and there's no "forgot password" link. You'll need it every
time you run a command starting with `sudo` — which means "run this one command
with administrator rights".

When it's done you get a prompt that looks like this, and you are on Linux:

```text
jon@DESKTOP-4F2K1:~$
```

#### Step 5 — Confirm it's healthy

Back in PowerShell (a normal one is fine now):

```powershell
wsl -l -v
```

Expected shape — the important column is `VERSION`, which should say `2`:

```text
  NAME      STATE           VERSION
* Ubuntu    Running         2
```

If it says `1`, run `wsl --set-version Ubuntu 2`. Version 1 is the older
implementation and some things behave differently.

#### Opening Ubuntu from now on

Three ways, all equivalent:

- **Start menu → Ubuntu.** The simplest.
- **Windows Terminal** — the modern tabbed terminal app, already installed on
  Windows 11 and free from the Microsoft Store on Windows 10. Click the small
  **v** chevron next to the `+` on the tab bar and choose **Ubuntu**. This is
  the nicest option: proper copy-paste, tabs, and it remembers your settings.
- Type `wsl` in any PowerShell window.

#### Where your files are

This is the bit that confuses everyone, so here it is plainly. You now
effectively have two filesystems that can see each other.

| Where | Path inside Ubuntu | Path in Windows Explorer |
|---|---|---|
| Your Linux home folder | `~` (which is `/home/jon`) | `\\wsl.localhost\Ubuntu\home\jon` (older builds: `\\wsl$\Ubuntu\home\jon`) |
| Your Windows C: drive | `/mnt/c` | `C:\` |
| Your Windows Desktop | `/mnt/c/Users/YourName/Desktop` | the Desktop |

So if your project is currently sitting on your Windows desktop, you can reach
it from Ubuntu:

```bash
cd "/mnt/c/Users/Your Name/Desktop/my-project"
```

Note the quotes — Windows usernames often contain a space, and without quotes
bash reads that as two separate arguments and reports `No such file or
directory`.

> **Strong advice: move your project into the Linux home folder.**
>
> ```bash
> cp -r "/mnt/c/Users/Your Name/Desktop/my-project" ~/
> cd ~/my-project
> ```
>
> Reading and writing files across the `/mnt/c` boundary goes through a
> translation layer, and it is **slow** — not "a bit slow", but ten times slower
> in a way you will feel. `git status` on a large repo takes seconds instead of
> being instant, and `npm install` can take minutes instead of moments. Keep the
> files on the Linux side and everything is fast. This is the single biggest
> quality-of-life difference in WSL.

To open your Linux folder in Windows Explorer, run this from inside Ubuntu:

```bash
explorer.exe .
```

The `.` means "this folder". You can drag files in and out of that window
normally. If you use **VS Code**, install its *WSL* extension and then `code .`
from the Ubuntu prompt opens the editor properly attached to Linux.

#### When `wsl --install` goes wrong

| What you see | What it means | What to do |
|---|---|---|
| `wsl : The term 'wsl' is not recognized...` | Windows is too old (pre-2004) | Press Windows+R, type `winver`, press Enter. You need version 2004 / build 19041 or later. Run Windows Update, possibly twice |
| `Invalid command line option: --install` | Windows 10, old enough to have `wsl` but not `--install` | Update Windows. If you genuinely can't, use [Microsoft's manual steps](https://learn.microsoft.com/windows/wsl/install-manual) |
| `Please enable the Virtual Machine Platform Windows feature and ensure virtualization is enabled in the BIOS`, or error `0x80370102` | Hardware virtualisation is switched off in your firmware | See [virtualisation](#virtualisation-disabled-in-the-bios) below |
| `WslRegisterDistribution failed with error: 0x800701bc` | The WSL2 Linux kernel is missing or out of date | In admin PowerShell: `wsl --update`, then `wsl --shutdown`, then reopen Ubuntu |
| `WslRegisterDistribution failed with error: 0x8007019e` | The WSL Windows feature never got enabled | See [enabling the features by hand](#enabling-the-features-by-hand) below |
| `WslRegisterDistribution failed with error: 0x80370114` | Virtual Machine Platform is enabled but blocked — often Core Isolation / Memory Integrity, or another virtualisation product (VirtualBox, VMware) holding the hardware | Turn off Memory Integrity in Windows Security → Device security → Core isolation, reboot, try again |
| It installs, then Ubuntu closes instantly with no message | Almost always a failed first-run setup | Run `wsl --unregister Ubuntu` then `wsl --install -d Ubuntu` to start clean. This deletes the Linux filesystem, which is empty at this point anyway |
| Everything fails and you're on a managed work laptop | Group policy — rules your IT department pushes to the machine, which you can't override | Stop here. Use [Git Bash](#route-2--git-bash) |

##### Virtualisation disabled in the BIOS

WSL2 uses your CPU's virtualisation feature, and a surprising number of laptops
ship with it switched off. First check whether it's actually off: open **Task
Manager** (Ctrl+Shift+Esc) → **Performance** → **CPU**, and look for
**Virtualization**. If it says `Disabled`, that's your problem.

To turn it on you need your computer's firmware settings (the "BIOS" or "UEFI"),
which is a menu that appears before Windows starts. The reliable way in:

1. **Settings** → **System** → **Recovery** → **Advanced startup** → **Restart
   now**.
2. **Troubleshoot** → **Advanced options** → **UEFI Firmware Settings** →
   **Restart**.
3. In the firmware menu, find the setting. It's called **Intel VT-x**,
   **Intel Virtualization Technology**, **AMD-V**, or **SVM Mode**, usually
   under Advanced, CPU Configuration, or Security. Set it to **Enabled**.
4. Save and exit — usually **F10**.

> Firmware menus differ per manufacturer and none of them are pretty. Searching
> for "enable virtualization" plus your laptop's exact model is genuinely the
> fastest route, and it is a normal, safe, reversible setting.

##### Enabling the features by hand

If the automatic install left the Windows features off, turn them on explicitly.
In **PowerShell as Administrator**:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

Reboot, then:

```powershell
wsl --update
wsl --install -d Ubuntu
```

### Route 2 — Git Bash

**Git Bash** is a small bash shell that comes bundled with
[Git for Windows](https://gitforwindows.org/). Install Git for Windows, accept
the defaults, and you get a "Git Bash" entry in your Start menu that opens a
genuine bash prompt with `git`, `ls`, `cat`, `grep`, `curl`, `ssh`, `sed` and
friends already in it.

It's much lighter than WSL — a single installer, no reboot, no virtualisation —
and it's the right answer if WSL is blocked or you want to get moving now.

**What works:** everything in [Get it on GitHub](05-github.md), heredocs, single
quotes, `$VAR`, backslash line continuations, and effectively all of
[Track A](10-cloudflare.md).

**What doesn't:**

- **No Linux package manager.** There's no `apt` — the command Ubuntu users type
  to install things. Tools like `jq` and the AWS CLI get installed as normal
  Windows programs instead, using `winget` (Windows' own built-in installer
  command, present on Windows 10 and 11), and then happen to be visible from Git
  Bash.
- **No `dig`.** DNS lookups go through Windows, so you use `nslookup` instead.
  [The three layers](04-three-layers.md) shows both.
- **No `sudo`.** Commands in this guide that use it need an Administrator
  terminal instead.
- **Path translation surprises.** Git Bash rewrites arguments that look like
  Unix paths into Windows paths, which is helpful right up until it isn't — an
  AWS command with an argument like `/aws/lambda/my-function` can arrive at the
  far end as `C:/Program Files/Git/aws/lambda/my-function`. The fix is to prefix
  the command with `MSYS_NO_PATHCONV=1`, but you have to know to do it, and
  that's the sort of thing that costs an hour.

That last point is why Track B is listed as "risky" below rather than "fine".

### What works where

| Task | PowerShell | Git Bash | WSL |
|---|---|---|---|
| Paste a `bash` command from this guide and have it run | No | Yes | Yes |
| Heredocs (`cat > file <<EOF`) | No | Yes | Yes |
| `$VAR` / `export VAR=value` | No — different syntax | Yes | Yes |
| Backslash `\` at end of line to continue | No — uses a backtick | Yes | Yes |
| `git`, `gh` | Yes | Yes | Yes |
| `curl` | `curl.exe` yes; bare `curl` is an alias for a different tool in Windows PowerShell 5 | Yes | Yes |
| `dig` | No — use `nslookup` | No — use `nslookup` | Yes |
| `jq`, `zip` | Install separately | Install separately | `sudo apt install` |
| `aws` (AWS CLI) | Yes | Yes, with path-translation quirks | Yes |
| `sudo` | No — "Run as administrator" instead | No | Yes |
| [Track A — Cloudflare](10-cloudflare.md) end to end | Mostly; it's dashboard-heavy | Yes | Yes |
| [Track B — AWS](20-aws.md) end to end | No | Risky | Yes |

**The recommendation, plainly:** install WSL. It's twenty minutes and a reboot,
and afterwards every instruction in this guide and in most of the internet's
tutorials applies to you unchanged. Take Git Bash if WSL is blocked, or if you
know you're doing Track A and want to start in the next five minutes.

> Everything you install in Windows and everything you install in WSL are
> **separate**. Installing the AWS CLI in Windows does not put `aws` inside
> Ubuntu, and vice versa. If you take the WSL route, do all the installs in the
> next section from the **Ubuntu** prompt using the Linux instructions — not the
> Windows ones.

---

## macOS

macOS already has a terminal: **Terminal.app**, in Applications → Utilities.
Press **Cmd+Space**, type `terminal`, press Enter. It opens on a shell called
**zsh**, which is close enough to bash that everything in this guide works
unchanged.

What it doesn't have is a way to install things. That's Homebrew.

### Homebrew

A **package manager** is a program whose job is installing other programs: it
knows where each tool lives, downloads the right version for your machine, puts
it somewhere your terminal can find it, and updates it later with one command.
Without one you're hunting for download pages, and nothing knows what you've
already got. **Homebrew** is the one macOS uses.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Two things will happen that surprise people:

1. **It asks for your Mac login password.** Homebrew needs to create folders
   your normal user can't write to. Same rule as before — **nothing appears as
   you type**. Type it, press Enter.

2. **A dialog box appears offering to install the Xcode Command Line Tools.**
   Click **Install** and accept the licence. This is Apple's set of developer
   tools — the compiler, plus `git` itself — and Homebrew needs it. It's a
   download of a gigabyte or two and takes several minutes on a good connection.
   If the dialog doesn't appear, run `xcode-select --install` yourself.

### The bit people skip, and then `brew` isn't found

When Homebrew finishes it prints a block headed `==> Next steps:` with two or
three commands in it. **Run them.** On Apple Silicon Macs, Homebrew installs to
`/opt/homebrew`, which your shell does not look in by default, so if you skip
this you'll open a fresh terminal tomorrow and get `brew: command not found`
despite having installed it.

The commands look like this:

```bash
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

That appends one line to your shell's startup file so every future terminal
knows where Homebrew lives, then applies it to the current one.

On **Intel** Macs, Homebrew installs to `/usr/local`, which is already on the
path, and there's nothing to do. Not sure which you have? Apple menu → **About
This Mac**: "Chip: Apple M…" is Apple Silicon, "Processor: Intel…" is Intel. Or
in the terminal, `uname -m` prints `arm64` or `x86_64`.

Then install everything at once:

```bash
brew install git gh jq awscli
```

`curl`, `dig` and `zip` ship with macOS already.

---

## Linux

You already have a terminal and a package manager. The only question is which
one, and that depends on your **distribution** — the particular flavour of Linux
you installed, such as Ubuntu or Fedora:

| Distribution | Command |
|---|---|
| Ubuntu, Debian, Linux Mint, Pop!_OS, **WSL's default Ubuntu** | `sudo apt install …` |
| Fedora, RHEL, CentOS, Rocky | `sudo dnf install …` |
| Arch, Manjaro | `sudo pacman -S …` |
| openSUSE | `sudo zypper install …` |

`sudo` means "run this one command as the administrator". It asks for your own
login password the first time you use it in a session, and — you know this by
now — **shows nothing as you type**.

On Debian, Ubuntu or WSL, get most of the way in one line:

```bash
sudo apt update
sudo apt install -y git curl jq zip unzip dnsutils
```

`sudo apt update` refreshes the catalogue of what's available; without it you
can get "package not found" for something that plainly exists. `-y` answers yes
to the "do you want to continue?" prompt.

Package names differ slightly per distribution:

| Tool | Debian / Ubuntu / WSL | Fedora | Arch |
|---|---|---|---|
| `dig` | `dnsutils` (or `bind9-dnsutils` on newer releases) | `bind-utils` | `bind` |
| everything else | the obvious name | the obvious name | the obvious name |

`gh` and `aws` aren't in the default repositories in a usable version — they get
their own instructions below.

---

## The tools

Nine things. Install them now rather than discovering each one missing halfway
through a step at a point where you've lost your thread.

For each one: what it is, how to install it, and **the command that proves it
worked**. Version numbers below are illustrative — yours will be higher and
that's fine. What you're checking is that the command runs at all and prints
something of roughly the right shape, rather than `command not found`. Any word
here you don't recognise is in [the glossary](99-glossary.md).

### git — tracks your changes

Git records every version of your project and is how your code gets to GitHub.
Both tracks deploy *from* a GitHub repository, so nothing else in this guide
happens without it.

```bash
# macOS — comes with the Xcode Command Line Tools; this gets a newer one
brew install git

# Debian / Ubuntu / WSL
sudo apt install -y git

# Windows without WSL — Git for Windows, which is also where Git Bash comes from
winget install Git.Git
```

```bash
git --version
```

```text
git version 2.43.0
```

### gh — GitHub from the command line

GitHub's own tool. It creates repositories (a **repository**, or "repo", is one
project's folder of code as GitHub stores it), sets permissions, and — most
usefully — logs you in properly, so you never have to generate or paste a
**personal access token**: a long secret string GitHub can issue in place of a
password, which is fiddly to make and easy to leak.
[05 — Get it on GitHub](05-github.md) uses it throughout.

```bash
# macOS
brew install gh

# Windows without WSL
winget install GitHub.cli

# Debian / Ubuntu / WSL — GitHub's own repository, because the built-in one lags
(type -p curl >/dev/null || sudo apt install -y curl) \
  && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update && sudo apt install -y gh
```

That last block looks alarming. It is four steps: fetch GitHub's signing key,
save it, tell `apt` about GitHub's package repository and that this key vouches
for it, then install. The signing key is what stops someone substituting a fake
package.

```bash
gh --version
```

```text
gh version 2.88.1 (2026-03-12)
https://github.com/cli/cli/releases/tag/v2.88.1
```

You'll log in with `gh auth login` in [05](05-github.md) — not yet.

### curl — fetches a URL

`curl` asks a web address for its contents and prints them. In this guide it's
how you check a site is actually live, and what **headers** it's returning — the
handful of labels a server sends alongside the page saying what it is, how long
it may be cached and whether the request succeeded. `curl` shows you the real
answer, without your browser's cache lying to you about it.

Already present on macOS, on every Linux, in Git Bash, and in modern Windows.

```bash
curl --version
```

```text
curl 8.7.1 (x86_64-apple-darwin23.0) libcurl/8.7.1 (SecureTransport) LibreSSL/3.3.6
Protocols: dict file ftp ftps gopher gophers http https imap imaps ...
```

> **PowerShell warning.** In Windows PowerShell 5.1 — the version most Windows
> 10 and 11 machines open by default — `curl` is an *alias* for a completely
> different PowerShell tool that takes different flags. `curl -I https://…` will
> not do what this guide expects. Write `curl.exe` explicitly, or use WSL or Git
> Bash, where `curl` is the real thing.

### dig — asks DNS a question directly

DNS is the layer that turns `yourthing.com` into an address, and it's where most
"my site isn't working" turns out to live. `dig` asks a DNS server a question
and shows you the raw answer, which is the only way to see past your own
computer's cache. [The three layers](04-three-layers.md) explains what to ask it.

```bash
# macOS — already installed

# Debian / Ubuntu / WSL
sudo apt install -y dnsutils          # newer releases: bind9-dnsutils
```

```bash
dig +short example.com
```

```text
104.20.23.154
172.66.147.243
```

One or more IP addresses means it works. The exact addresses change over time
and some names answer with several, so don't compare yours against the ones
above — what matters is that you get addresses at all. No output means the
lookup failed, usually a network problem rather than a `dig` problem.

> **No `dig` on Windows outside WSL.** Use `nslookup example.com` instead, which
> is built in and answers the same basic question with a different layout. For
> anything more involved, [dnschecker.org](https://dnschecker.org) shows you
> what the rest of the world sees, which is often more useful than what your own
> machine sees.

### jq — reads JSON

AWS commands answer in **JSON** — a structured text format full of braces that
is precise and unreadable in bulk. `jq` pulls single values out of it and
pretty-prints the rest. [Track B](20-aws.md) uses it constantly; Track A barely
needs it.

```bash
# macOS
brew install jq

# Debian / Ubuntu / WSL
sudo apt install -y jq

# Windows without WSL
winget install jqlang.jq
```

```bash
jq --version
```

```text
jq-1.7.1
```

A better proof, because it shows it actually parses:

```bash
echo '{"live":true,"visits":3}' | jq .visits
```

```text
3
```

### zip — packages files into one archive

**AWS Lambda** — Amazon's service for running a small piece of your code on
demand, with no server for you to look after — takes that code as a `.zip` file.
So [Track B](20-aws.md) needs `zip` if, and only if, your project has a
**backend**: code that runs on a server rather than in the visitor's browser.
Track A never uses it.

```bash
# macOS — already installed

# Debian / Ubuntu / WSL
sudo apt install -y zip unzip
```

```bash
zip --version
```

The output is a wall of copyright text starting with `Copyright (c) 1990-2008
Info-ZIP`. That's a healthy answer — it's an old tool with old manners.

### aws — the AWS command line

The tool that drives your AWS account from the terminal: creating **buckets**
(an S3 bucket is just a named folder in Amazon's storage that a website can be
served out of), uploading files, and clearing the **CDN** cache — a CDN, or
content delivery network, being the layer of copies of your site kept near your
visitors so pages load fast. **[Track B](20-aws.md) only** — skip this entirely
if you're taking [Track A](10-cloudflare.md).

```bash
# macOS
brew install awscli
```

```bash
# Linux and WSL — AWS's own install script, because distribution packages are old.
# It picks the right build for Intel or ARM machines by itself.
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash
```

> That script installs into your own home folder (`~/.local/bin`) and needs no
> `sudo`. If `aws` isn't found afterwards, close the terminal and open a new one
> — see [when it doesn't work](#when-it-doesnt-work) below.

```powershell
# Windows without WSL
winget install Amazon.AWSCLI
```

```bash
aws --version
```

```text
aws-cli/2.34.15 Python/3.13.12 Darwin/25.5.0 source/arm64
```

The `aws-cli/2.` at the start matters — this guide assumes version 2. If you see
`aws-cli/1.…` you have an old install (often from `pip`, Python's package
installer) shadowing the new one; remove it, or fix your **`PATH`** so version 2
comes first. `PATH` is the ordered list of folders your shell searches when you
type a command name — the first match wins, which is exactly how an old copy
keeps answering.

You'll connect it to your account in [Track B](20-aws.md), after
[keys and access](03-keys-and-access.md). Don't run `aws configure` yet.

### node and npm — only if your project builds

**Node.js** runs JavaScript outside a browser, and **npm** is its package
manager, installed alongside it. You need these **only if your project has a
build step** — if you run something like `npm run build` and get a `dist/` or
`build/` folder out of it. React, Vue, Svelte, Vite, Astro and Next all work
this way. A hand-written HTML page does not.

Not sure? Look in your project folder for a file called `package.json`. If it's
there, you need Node.

```bash
# macOS
brew install node

# Debian / Ubuntu / WSL — the distribution version is usually too old.
# nvm lets you install and switch Node versions per project.
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash
# then close and reopen your terminal, and:
nvm install --lts

# Windows without WSL
winget install OpenJS.NodeJS.LTS
```

```bash
node --version
npm --version
```

```text
v22.14.0
10.9.2
```

> The `nvm` install prints instructions and then **does nothing until you open a
> new terminal**. If `nvm: command not found` immediately after installing, that
> is why — close the window, open a new one, try again.

### Claude Code — the agent that reads this guide with you

Every page in this guide is written to be handed to Claude Code, which can run
the commands and explain what it's doing. You don't have to use it — the guide
stands alone — but the prompts scattered through it assume you might.

The current install instructions live at
[code.claude.com/docs/en/setup](https://code.claude.com/docs/en/setup), and they
change more often than anything else on this page, so check there rather than
trusting a command in a Markdown file. As of writing:

```bash
# macOS, Linux, WSL
curl -fsSL https://claude.ai/install.sh | bash

# macOS, via Homebrew
brew install --cask claude-code

# or, if you already have Node
npm install -g @anthropic-ai/claude-code
```

```bash
claude --version
```

```text
2.1.226 (Claude Code)
```

Then run `claude` in your project folder to start it. It'll walk you through
signing in the first time. There's also `claude doctor`, which checks its own
install and tells you what's wrong.

> **On Windows, prefer installing Claude Code inside WSL**, from the Ubuntu
> prompt. It does run natively on Windows from PowerShell — there's an official
> installer for it — but this guide's commands are bash, and Claude Code is a
> great deal happier when the shell underneath it is bash too.
>
> Claude Code needs a paid Claude plan (Pro, Max, Team or Enterprise) or a
> Console account with API credit; the free Claude.ai plan doesn't include it.
> Prices and plan limits change, so check
> [claude.com/pricing](https://www.claude.com/pricing) rather than any number
> you read in a guide.

---

## Check everything at once

Paste this whole block into your terminal and press Enter. It prints one line
per tool with a tick or a cross, and it changes nothing.

```bash
for tool in git gh curl dig jq zip aws node npm claude; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '  ✓  %-6s  %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '  ✗  %-6s  not installed\n' "$tool"
  fi
done
```

A healthy result looks roughly like this:

```text
  ✓  git     /opt/homebrew/bin/git
  ✓  gh      /opt/homebrew/bin/gh
  ✓  curl    /usr/bin/curl
  ✓  dig     /usr/bin/dig
  ✓  jq      /opt/homebrew/bin/jq
  ✓  zip     /usr/bin/zip
  ✓  aws     /opt/homebrew/bin/aws
  ✓  node    /opt/homebrew/bin/node
  ✓  npm     /opt/homebrew/bin/npm
  ✓  claude  /Users/you/.local/bin/claude
```

**Crosses are not automatically a problem.** Read them against what you're
actually doing:

| Tool | Needed for |
|---|---|
| `git`, `gh`, `curl` | Everything. A cross here is a real problem |
| `dig` | Useful everywhere; essential when DNS misbehaves. On Windows outside WSL, use `nslookup` and ignore the cross |
| `jq`, `zip`, `aws` | [Track B — AWS](20-aws.md). Ignore entirely on [Track A](10-cloudflare.md) |
| `node`, `npm` | Only if your project has a `package.json` |
| `claude` | Only if you want Claude Code to drive |

The second column of the output — the path — is worth a glance too. If a tool
shows up somewhere you don't expect (an `aws` under `/usr/local/bin` when you
installed via Homebrew, say), you have two copies and the wrong one is winning.

---

## When it doesn't work

| What you see | What's actually going on | What to do |
|---|---|---|
| `command not found` for something you just installed | Your terminal built its list of programs when it opened and hasn't noticed the new one | **Close the terminal window and open a new one.** This fixes it perhaps four times out of five. If it doesn't, the tool went somewhere your `PATH` doesn't cover — see the next two rows |
| `brew: command not found` on a Mac, even though Homebrew installed fine | Apple Silicon puts Homebrew in `/opt/homebrew`, which isn't searched by default, and you skipped the "Next steps" block | Run `eval "$(/opt/homebrew/bin/brew shellenv)"` now, and add it to `~/.zprofile` so it sticks — see [Homebrew above](#the-bit-people-skip-and-then-brew-isnt-found) |
| `command not found` and reopening didn't help | `PATH` — the list of folders your shell searches — doesn't include where the tool landed | Find it with `ls /usr/local/bin`, `ls ~/.local/bin` or the installer's own output, then add that folder: `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc` (use `~/.bashrc` on Linux and WSL). Reopen the terminal |
| `Permission denied` | You're writing somewhere your user doesn't own, usually a system folder | Prefix with `sudo` — but only for install commands. If you're getting this inside your *own* project folder, `sudo` is the wrong answer and something else owns your files: `sudo chown -R $(whoami) .` fixes that |
| `Permission denied` running a script you downloaded | The file isn't marked executable | `chmod +x thescript.sh`, then `./thescript.sh` |
| `running scripts is disabled on this system` in PowerShell | Windows blocks unsigned scripts by default | In PowerShell: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`, answer `Y`. This allows scripts you wrote locally and signed ones from elsewhere, which is the sensible middle setting. It only affects your own user |
| `sudo: command not found` | You're in Git Bash or PowerShell, which have no `sudo` | Close it and open an **Administrator** terminal (right-click → Run as administrator) — or use WSL, where `sudo` works normally |
| `apt: command not found` on a Mac | You ran the Linux instructions | Use the macOS ones — `brew install …` |
| `brew: command not found` on Linux or WSL | You ran the macOS instructions | Use `sudo apt install …` |
| You installed something in Windows and WSL can't see it | They're separate systems that happen to share a screen | Install it again, inside Ubuntu, using the Linux instructions |
| `aws-cli/1.x` when you installed version 2 | An old copy from `pip` is earlier in your `PATH` | `pip uninstall awscli`, reopen the terminal, check again |
| Everything is fine but the terminal feels hostile | Entirely normal on day one | You need about six commands total for this guide, and every one of them is written out for you. Paste, read the output, move on |

Anything not covered here goes in [90 — When it breaks](90-troubleshooting.md),
and any word you don't recognise is in [the glossary](99-glossary.md).

And the genuinely fastest route when a command fails: copy **the command you
ran** and **the entire error message**, paste both into Claude Code, and add
what you were trying to do. Error messages are written for people who already
know the answer, and translating them is something an agent is very good at.

---

**Next:** [Accounts you'll need →](02-accounts.md)
