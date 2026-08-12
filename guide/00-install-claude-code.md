# Get an AI coding agent

**This page gets you a working AI coding agent on your own machine, signed in,
with one small thing already built by it — about 20 minutes, most of which is a
download bar and a browser login.**

You don't need to have written code before. You do need a terminal window open;
if that phrase means nothing to you, read [Your machine](03-your-machine.md)
first and come back — it takes you from zero to a prompt you can type into.

---

## What an AI coding agent actually is

You have probably used a chat window that can write code: you ask, it prints
some code, you copy it somewhere. An **agent** is the same model with a
different job. It runs as a program **on your computer**, inside a folder you
point it at. Within that folder it can *read* your files, *write* new ones, and
*run commands* — the same commands you could type yourself.

That last part is the whole difference. A chat window can describe how to buy a
domain and deploy a site. An agent can create the files, run the deploy command,
read the error that comes back, work out what's wrong, and try again. It's the
difference between someone reading you a recipe down the phone and someone
standing in your kitchen. Everything the rest of this guide asks for — a
repository, a domain, a certificate, a live URL — is something an agent can
actually do, which is why this guide starts here.

### It asks first, and you should read what it asks

By default the agent **stops and asks you before it changes a file or runs a
command**. You'll see the proposed change — the actual file contents, the actual
command — and a prompt with options along the lines of "yes" / "yes, and don't
ask again for this" / "no, tell it what to do differently".

Read those. Not because the agent is malicious, but because it is confident, and
confidence and correctness are different things. It can delete the wrong file,
`git push` something you meant to keep private, or spend money on a cloud
service, and every one of those arrives as a permission prompt you could have
declined. The habit worth building on day one: **if you don't recognise what it's
proposing, type "no" and ask it to explain first.** That is always allowed and it
never costs you anything.

Pressing `Shift+Tab` inside a session cycles between those modes: the default
(shown as **Manual**), one that auto-approves file edits, and a **plan** mode
where it proposes without touching anything. Leave it on the default until you
have a feel for it.

---

## Which agent

Two good options, and this guide works with either:

- **Claude Code** — Anthropic's agent. **The examples, prompts and the skill in
  this guide are written for it**, so it is the path of least friction here.
- **Codex** — OpenAI's agent. Same shape, same idea, different company.
  [Covered below](#codex-if-youd-rather-use-that).

If you already pay for one of Claude or ChatGPT, use the one you already pay for.
If you pay for neither, either will need a subscription or billing set up — see
[the money question](#signing-in-and-the-money-question).

---

## Install Claude Code

> The commands below were checked against Anthropic's official install
> documentation in August 2026:
> **<https://code.claude.com/docs/en/setup>**. Install commands do change. If one
> of these doesn't behave as described, that page is the authority, not this one.

Claude Code needs macOS 13 or later, Windows 10 version 1809 or later (or
Windows Server 2019+), or a mainstream Linux — Ubuntu 20.04+, Debian 10+, Alpine
3.19+ — on a 64-bit processor (x64 or ARM64), with 4 GB of RAM and an internet
connection.

### The recommended route: the native installer

"Native" here means it installs a self-contained program, with no other software
required first. This is the route to take unless you have a reason not to.

**macOS, Linux, or WSL** (WSL being Windows Subsystem for Linux — a real Linux
running inside Windows; see [Your machine](03-your-machine.md)):

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Windows, in PowerShell:**

```powershell
irm https://claude.ai/install.ps1 | iex
```

**Windows, in Command Prompt (`cmd`):**

```text
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

Those last two are not interchangeable, and mixing them up is the single most
common Windows stumble. Your prompt tells you which one you're in: PowerShell
shows `PS C:\Users\You>`, Command Prompt shows `C:\Users\You>` with no `PS`. Run
the PowerShell line in `cmd` and you get `'irm' is not recognized as an internal
or external command`. Run the `cmd` line in PowerShell and you get `The token
'&&' is not a valid statement separator`. Neither is a broken install — it's the
wrong window.

Native installs update themselves quietly in the background.

### If you'd rather use a package manager

These do the same job; the trade-off is that **none of them auto-update by
default**, so you have to run the upgrade yourself occasionally.

```bash
# macOS or Linux, with Homebrew
brew install --cask claude-code
# upgrade later with: brew upgrade claude-code
```

There are two Homebrew casks: `claude-code` follows the stable channel, which
runs roughly a week behind and skips releases with known major regressions, and
`claude-code@latest` takes every release as it ships. Stable is the quieter
choice; upgrade whichever one you installed.

```powershell
# Windows, with WinGet
winget install Anthropic.ClaudeCode
# upgrade later with: winget upgrade Anthropic.ClaudeCode
```

```bash
# Any platform, with npm — Node.js 22 or later
npm install -g @anthropic-ai/claude-code
# upgrade later with: npm install -g @anthropic-ai/claude-code@latest
```

The npm package downloads the same self-contained program the native installer
does, so `claude` doesn't actually run on Node once it's installed — Node is only
needed to fetch it. Upgrade with the `@latest` line above rather than
`npm update -g`, which can leave you on an older release.

**Do not put `sudo` in front of the npm command.** `sudo` runs it as the
computer's administrator, and it leaves you with files your normal account can't
write to — which surfaces later as update failures you can't explain. If the npm
install fails on permissions, use the native installer instead; it doesn't need
elevated rights.

Anthropic also publishes signed `apt`, `dnf` and `apk` repositories for Debian,
Ubuntu, Fedora, RHEL and Alpine. Those are on the
[setup page](https://code.claude.com/docs/en/setup) — worth using if you manage
a Linux machine and want updates to arrive with everything else.

### On Windows specifically

You have two routes, and this matters for the rest of the guide:

| Route | What you get | The catch |
|---|---|---|
| **Native Windows** | Install from PowerShell or `cmd`, run `claude` from any terminal | Later chapters of this guide are written in bash. Installing [Git for Windows](https://git-scm.com/downloads/win) gives Claude Code a bash to run commands in, which helps a great deal |
| **WSL** | A real Ubuntu inside Windows. Open the WSL terminal and run the macOS/Linux installer *there* | Twenty minutes of setup first |

**[Your machine](03-your-machine.md) walks through WSL properly**, including what
to do when corporate IT has virtualisation switched off. If you're on Windows and
have any choice in the matter, WSL is the route that makes the rest of this guide
work exactly as written.

### Prove it worked

Close your terminal, open a fresh one — installers change your PATH (the list of
folders your terminal searches for programs), and a terminal that was already
open doesn't know that yet. Then:

```bash
claude --version
```

A healthy answer is a version number followed by `(Claude Code)`, like this:

```text
2.1.226 (Claude Code)
```

Your number will be different and higher. What matters is that you get a number
rather than an error. If you get `command not found`, that is a PATH problem and
[the table at the bottom](#when-it-doesnt-work) has the fix.

For a fuller check — install health, configuration errors, whether the last
update worked — there's a built-in diagnostic that prints a report without
starting a session:

```bash
claude doctor
```

### Not keen on the terminal?

The terminal is not the only door in. There is a **desktop app** for macOS,
Windows and Linux, and extensions for **VS Code** and **JetBrains IDEs** (an IDE
being a code editor with tooling built in). They run the same agent with a
graphical interface around it.

They're genuinely good, and if the terminal puts you off, start there:
[desktop](https://code.claude.com/docs/en/desktop-quickstart),
[VS Code](https://code.claude.com/docs/en/vs-code),
[JetBrains](https://code.claude.com/docs/en/jetbrains).

One caveat, because it catches people: **the VS Code extension does not give you
a `claude` command in your terminal.** It keeps its own private copy. The rest of
this guide assumes you can type `claude` at a prompt, so if you go the extension
route, also run the standalone install above.

---

## Signing in, and the money question

Run `claude` for the first time and it walks you through logging in. It opens
your browser, you sign in to your Anthropic account and approve access, and the
browser hands control back to the terminal. Your credentials are then stored on
your machine and you don't do this again. To sign in again or switch accounts
later, type `/login` inside a running session; `/logout` signs you out.

The exact wording of those first-run screens changes between versions — expect a
couple of setup questions (colour theme, that sort of thing) before the login
step. What you're looking for is a browser tab opening and a "you're logged in"
message back in the terminal.

### The two kinds of billing, which are not the same thing

This confuses almost everyone, so here it is plainly. Anthropic sells two
different things, and you may need one, or both, for different reasons:

| | **A Claude subscription** | **API credit** |
|---|---|---|
| What it is | A monthly plan — Pro, Max, Team, Enterprise | Pay-as-you-go credit on an Anthropic Console account |
| How you pay | Fixed monthly fee | Per unit of text processed, drawn down from a balance you top up |
| What it covers here | **You** using Claude Code to build and deploy | **Your deployed app** calling Claude on behalf of its users |
| Where you set it up | [claude.com/pricing](https://claude.com/pricing) | [platform.claude.com](https://platform.claude.com) |

**At the time of writing, Claude Code needs a Pro, Max, Team or Enterprise
subscription, or a Console account with credit** — the free Claude.ai plan does
not include it. A subscription is the usual choice, because it's a predictable
monthly number rather than a meter running while you work.

**API credit is a separate question, and only if your project calls Claude.** If
you're building a "summarise this with AI" button, that button will make API
calls from your server, and those are billed per use against a key you create.
That key is your app's, not yours — it lives in a secret store, never in your
code, and [Keys and access](05-keys-and-access.md) covers exactly how to handle
it and how to avoid publishing it by accident.

So: **subscription to build, API credit only if the thing you built talks to
Claude.** Many projects in this guide never need the second one.

Prices and plan names change, so check
**[claude.com/pricing](https://claude.com/pricing)** rather than trusting any
number written down elsewhere, including here.

> **A note if you already have an `ANTHROPIC_API_KEY` set** as an environment
> variable on your machine: Claude Code notices it and offers to use that key
> instead of opening a browser. That's fine, but be aware it means your agent
> session is billed to your API balance, not your subscription.

---

## Codex, if you'd rather use that

**Codex** is OpenAI's terminal coding agent. Same idea: it runs on your machine,
reads and writes files in a folder, runs commands, and asks before it acts.

> Checked against OpenAI's documentation in August 2026:
> **<https://learn.chatgpt.com/docs/codex/cli>** (older `developers.openai.com`
> links now redirect there). As above — if a command misbehaves, that page wins.

```bash
# macOS or Linux — the standalone installer
curl -fsSL https://chatgpt.com/codex/install.sh | sh
```

```powershell
# Windows
powershell -ExecutionPolicy ByPass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

```bash
# Or via npm, or Homebrew on macOS
npm install -g @openai/codex
brew install --cask codex
```

Check it landed:

```bash
codex --version
```

A healthy answer looks like `codex-cli 0.146.0` — again, your number will differ.

Then run `codex` in a project folder and choose **Sign in with ChatGPT**. The
browser opens, you approve, and you're in. OpenAI currently includes Codex across
its ChatGPT plans — Free, Go, Plus, Pro, Business, Edu and Enterprise — with the
usage limits varying a lot by plan, so a free account will run out of road faster
than a paid one. You can sign in with an OpenAI API key instead, which is
pay-as-you-go, needs
[a bit more setup](https://learn.chatgpt.com/docs/auth), and leaves some
cloud-side features unavailable. Check current plans and limits at
[openai.com/chatgpt/pricing](https://openai.com/chatgpt/pricing/) rather than
trusting anything written here.

### The honest comparison

Both agents will get you through this guide. They read files, write files, run
commands, and ask permission, and the day-to-day feel of using them is more
similar than different. The difference for *you*, right now, is fit: this guide's
example prompts, its hand-over page, and its
[skill](08-let-claude-drive.md) — a packaged set of instructions that teaches the
agent this specific deployment workflow — are all written for Claude Code, so
that path has fewer edges. With Codex you'll be pasting the same instructions in
plain English instead, which works, and is a couple of extra steps.

Pick on what you already pay for. You are not making a permanent decision; both
install in a few minutes and they can coexist on the same machine.

---

## Somewhere to keep your projects

Make one folder now, and put every project inside it:

```bash
mkdir -p ~/dev
```

`~` is shorthand for your home folder, so that's `/Users/you/dev` on a Mac and
`/home/you/dev` on Linux or WSL. One folder per project inside it:

```text
~/dev/
├── tide-clock/
├── recipe-scaler/
└── agent-test/
```

This looks like housekeeping and isn't. **The folder you start the agent in is
the boundary of what it can see and touch.** Start it in `~/dev/tide-clock` and
that project is its whole world. Start it in your home folder and its world
includes your documents, your photos, your `.ssh` keys and every credential on
the machine.

So there are two rules, and they're the same rule twice:

- **One folder per project.** Never two projects in one folder.
- **Never start an agent in your home folder**, on your Desktop, or in
  Documents.

> **Avoid folders that sync.** A project inside iCloud Drive, Dropbox or
> OneDrive will fight you — the sync client rewrites files under the agent's
> feet, `node_modules` takes an age to upload, and git repositories in
> particular corrupt in ways that are miserable to unpick. `~/dev` sits outside
> all of them, which is most of the point.

## Your first two minutes with it

Do this now, before you need it for anything real. The point is to see the loop
once — propose, approve, done — so it isn't unfamiliar when the stakes are your
actual project.

Make an empty folder and move into it. `mkdir` makes a directory, `cd` changes
into it:

```bash
mkdir -p ~/dev/agent-test
cd ~/dev/agent-test
```

Start the agent:

```bash
claude
```

You'll get a prompt with the version, the model it's using, and the folder it's
working in shown above it. That folder line matters — it's the boundary of what
the agent will touch.

Now type this and press Enter:

```text
Make a single HTML file that shows the current time in a big font, and open it.
```

Here's what happens, and it's worth watching rather than skimming:

1. It thinks for a few seconds, then tells you what it intends to do — usually
   one sentence, something like "I'll create an `index.html` with a clock that
   updates every second."
2. It shows you the **actual file it wants to write**, with the HTML, CSS and
   JavaScript in it, and asks whether to create it. Options along the lines of
   **Yes** / **Yes, and don't ask again** / **No, tell Claude what to do
   differently**. Read the file. It's short. Choose **Yes**.
3. It writes the file. You'll see a confirmation with the path.
4. Because you said "and open it", it asks a *second* time — this time to run a
   command that opens the file in your browser (`open index.html` on macOS,
   `xdg-open` on Linux, `start` on Windows). This is a separate permission
   because running a command is a different kind of act from writing a file.
   Approve it.
5. Your browser opens. There's a clock on the screen. You made that by typing an
   English sentence.

That's the entire loop, and everything later in this guide is that loop repeated
with higher stakes. Try one follow-up before you leave, because *changing* things
is most of the real work:

```text
Make the background dark and the text a soft green, and add today's date underneath.
```

It'll edit the file and show you what changed. Refresh the browser tab.

When you're done, type `/exit` (or press `Ctrl+D` twice) to leave. Nothing about
that folder is special — delete `~/agent-test` whenever you like.

---

## Stop it asking you about everything

Out of the box, the agent asks permission before each file it writes and each
command it runs. That is the right default the first time. By the twentieth
prompt it is genuinely wearing, and it has a nastier side effect: **it trains
you to click "yes" without reading**, which quietly removes the protection the
prompts existed to give you.

Better to choose a level deliberately.

| Level | What you type | It asks about |
|---|---|---|
| Default | `claude` | Every edit and every command |
| **Accept edits** | `claude --permission-mode acceptEdits` | Commands only — file edits go straight through |
| Bypass everything | `claude --dangerously-skip-permissions` | Nothing |

### Start with `acceptEdits`

```bash
claude --permission-mode acceptEdits
```

This is the one to use day to day. Editing files is the bulk of the prompts and
the least dangerous thing the agent does — a bad edit shows up immediately and
git can undo it. Anything that *runs* still stops and asks you, which is where
the real consequences live: deleting things, installing things, spending money.

Most of the friction disappears and the meaningful check stays.

### And when you want it to just get on with it

```bash
claude --dangerously-skip-permissions
```

The name is doing its job — that flag means *nothing will stop it*. The risk is
worth stating precisely, because "the AI might go rogue" is the wrong worry:

1. **A mistake has nothing to catch it.** Agents occasionally do the wrong
   thing confidently. `rm -rf` in the wrong directory is not recoverable by
   apologising to it afterwards.
2. **Anything it reads can try to instruct it.** It fetches web pages, reads
   dependency files, opens GitHub issues. Text in any of those can be written
   to look like an instruction, and with no prompts there is nothing between
   that text and your machine. This is a real class of attack, not a
   hypothetical.

Which is exactly why you made `~/dev`. Used inside a single project folder that
holds nothing you can't afford to lose, the blast radius is that folder. Used in
your home directory, the blast radius is your life.

**The three conditions to meet before you use it:**

- You're in a **project folder under `~/dev`**, never `~` and never `/`.
- The project is **already a git repository with a commit** — `git init && git
  add -A && git commit -m "start"`. That commit is your undo button, and
  `git reset --hard` gets you back to it.
- **Nothing in that folder is irreplaceable**, and no live production
  credentials are reachable from it.

It refuses to run as `root`, which tells you how the people who wrote it feel
about the flag.

> **If you use it, still read the transcript.** Skipping the prompts does not
> mean skipping attention — it means the attention happens after rather than
> before, so you want to be able to notice a command you didn't expect and stop
> it. Scroll back occasionally.

### The same thing in Codex

```bash
codex --ask-for-approval on-request          # graduated, roughly acceptEdits
codex --dangerously-bypass-approvals-and-sandbox
```

Codex also has a real sandbox (`--sandbox`), which Claude Code doesn't do the
same way — worth knowing if you'd rather have the machine enforce the boundary
than rely on which folder you're in.

## How to talk to it well

The gap between a frustrating session and a good one is mostly these five
habits.

- **Say the goal, not the commands.** "I want this online at yourthing.com over
  HTTPS" gets a better result than "run `aws s3 sync`". You're describing the
  destination; working out the route is its job, and it knows more routes than
  you do.
- **Say up front what it must stop and ask about.** "Stop before anything that
  spends money, and before the first commit" is a sentence that has saved people
  real money. Constraints stated at the start are respected far more reliably
  than ones you shout mid-flight.
- **Paste whole errors, never summaries.** Every line, including the ugly ones
  you'd assume are noise. The detail that identifies the real cause is almost
  always in the part people trim — deploy failures in particular routinely
  *look* like permission problems and *are* configuration problems, and the
  difference is a single line near the bottom.
- **Ask it to explain before you approve something you don't recognise.** "What
  does this command actually do, and what happens if it's wrong?" gets a real
  answer, costs you fifteen seconds, and is how you end up understanding your
  own setup rather than owning a black box.
- **Tell it when it's wrong.** "That's not the domain I asked for" or "you've
  changed a file I didn't want touched" — say it immediately and plainly. It
  will correct course. Being polite about a mistake for three more turns is how
  small errors become tangled ones.

---

## When it doesn't work

| What you see | What's happening | What to do |
|---|---|---|
| `zsh: command not found: claude`, `bash: claude: command not found`, or `'claude' is not recognized as an internal or external command` | The program installed, but your terminal doesn't know where to look for it. Your **PATH** is the list of folders it searches, and the install folder isn't on it — often because this terminal window was already open when you installed | First, close the terminal and open a new one; that fixes it most of the time. If not, add the install folder to your PATH: `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc` then `source ~/.zshrc` (use `~/.bashrc` on most Linux). On Windows the installer puts it in `%USERPROFILE%\.local\bin` |
| `The token '&&' is not a valid statement separator` | You ran the Command Prompt install line inside PowerShell | Run the PowerShell version (`irm https://claude.ai/install.ps1 \| iex`) instead |
| `'irm' is not recognized as an internal or external command` | The opposite — the PowerShell line inside Command Prompt | Run the `cmd` version, or open PowerShell |
| Permission errors during install, or `EACCES` from npm | The target folder isn't writable by your account, usually a side-effect of an earlier `sudo npm install -g` | Don't retry with `sudo` — that deepens the hole. Use the native installer instead: `curl -fsSL https://claude.ai/install.sh \| bash` |
| Login starts but no browser opens | Common over SSH, inside WSL, or in a container — the agent asks the machine to open a browser and there isn't one, or it opens on the wrong computer | At the login prompt press `c` to copy the sign-in URL, open it in a browser yourself, then paste the code it gives you back into the terminal. In WSL you can also point it at your Windows browser: `export BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"` |
| `OAuth error: Invalid code. Please make sure the full code was copied` | The login code expired, or got cut short when you copied it | Retry the login and move through it briskly; make sure you've selected the whole code, which can wrap onto a second line in a narrow terminal |
| Install fails with `403`, `Failed to fetch version`, or curl errors | Something between you and the download server — a corporate proxy, a firewall, or a region where Claude Code isn't available | If you're behind a proxy, set it before installing: `export HTTPS_PROXY=http://proxy.example.com:8080` (ask IT for the address). On PowerShell: `$env:HTTPS_PROXY = 'http://proxy.example.com:8080'`. Try a different network to confirm the proxy is the cause |
| `unable to get local issuer certificate` or `SELF_SIGNED_CERT_IN_CHAIN` | A corporate proxy is inspecting encrypted traffic by re-signing it with the company's own certificate, which your machine doesn't yet trust | Point Claude Code at your organisation's certificate file: `export NODE_EXTRA_CA_CERTS=/path/to/ca-cert.pem`. Your IT team can give you that file. Details on [network configuration](https://code.claude.com/docs/en/network-config) |
| A VPN makes it hang or fail | Some corporate VPNs route or block traffic to `api.anthropic.com`, `claude.ai`, `platform.claude.com` and `downloads.claude.ai` | Test with the VPN off. If it works, that's your answer, and the fix is an allowlist request to IT rather than anything you can change locally. The [network configuration page](https://code.claude.com/docs/en/network-config) lists every host to ask for |
| It installed but behaves oddly | Could be a stale version, a broken settings file, or two installs fighting | Run `claude doctor` — it prints a diagnostic report covering install health and configuration errors without starting a session |

If none of that matches, Anthropic's
[installation troubleshooting page](https://code.claude.com/docs/en/troubleshoot-install)
is organised as error-message-to-fix and is more thorough than this table.

---

You now have an agent that can read files, write files, and run commands in a
folder you choose — which is everything the rest of this guide needs. The next
question is what to point it at.

**Next:** [Come up with something to build →](01-find-an-idea.md)
