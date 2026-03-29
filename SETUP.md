# Setting Up HERALD — Complete Beginner's Guide

This guide assumes you have never used a terminal, Claude Code, or any developer tools before. Follow every step in order.

---

## What is a terminal?

A terminal is a text-based window where you type commands to control your computer. You will use it throughout this guide.

**How to open a terminal:**
- **Mac** — press `Command + Space`, type `Terminal`, press Enter
- **Windows** — press the Windows key, type `PowerShell`, press Enter
- **Linux** — press `Ctrl + Alt + T`

Leave it open. You will come back to it.

---

## Step 1 — Create an Anthropic account

HERALD runs on Claude, Anthropic's AI. You need an account first.

1. Go to **claude.ai**
2. Click **Sign up** and create a free account
3. Once signed in, upgrade to **Claude Pro** — Claude Code requires a paid plan ($20/month)

---

## Step 2 — Install Node.js

Node.js is a program that lets you install developer tools like Claude Code. You only do this once.

1. Go to **nodejs.org**
2. Click the big **LTS** download button (LTS = stable version, recommended)
3. Open the downloaded file and follow the installer — click Next through everything
4. When it finishes, **close and reopen your terminal**

**Check it worked** — type this in your terminal and press Enter:
```
node --version
```
You should see a version number like `v20.11.0`. If you do, Node.js is installed.

---

## Step 3 — Install Claude Code

Claude Code is the AI coding tool that HERALD runs inside. Install it by typing this in your terminal and pressing Enter:

```
npm install -g @anthropic-ai/claude-code
```

This may take a minute. When it finishes, **check it worked:**
```
claude --version
```
You should see a version number. If you do, Claude Code is installed.

---

## Step 4 — Log in to Claude Code

Type this in your terminal:
```
claude login
```

A browser window will open asking you to log in with your Anthropic account (the one you created in Step 1). Log in and approve the connection. Come back to the terminal when done.

---

## Step 5 — Install HERALD globally

This adds the `/install-herald` command to Claude Code on your machine. You only do this once.

Copy and paste this into your terminal and press Enter:
```
curl -fsSL https://raw.githubusercontent.com/brainiac992/herald-of-rivia/main/bootstrap.sh | bash
```

You should see:
```
HERALD bootstrap complete.
/install-herald is now available globally in Claude Code.
```

---

## Step 6 — Create or open a project folder

HERALD works inside a project folder — this is just a regular folder on your computer where your work lives.

**To create a new project folder:**
```
mkdir my-project
cd my-project
```

**To use an existing folder:**
```
cd path/to/your/folder
```

> **Not sure what `cd` means?** It stands for "change directory" — it moves you into a folder. Think of it like double-clicking a folder, but in text form.

---

## Step 7 — Start Claude Code

While inside your project folder, type:
```
claude
```

Claude Code will open. You are now inside the AI assistant.

---

## Step 8 — Install HERALD into your project

Inside Claude Code, type:
```
/install-herald
```

HERALD will set itself up automatically. When it finishes you will see a confirmation message listing all the files it added.

---

## Step 9 — Restart Claude Code

Type `exit` to close Claude Code, then start it again:
```
exit
claude
```

HERALD is now fully active.

---

## Step 10 — Make your first request

Just type what you want to do in plain English. You do not need to use any special commands or syntax.

**Example:**
```
I want to build a simple website with a homepage and a contact form
```

HERALD will ask you a few questions to make sure it understands what you want, then propose a plan. You approve the plan before anything happens. Nothing is built without your sign-off.

---

## Something went wrong?

| Problem | Fix |
|---|---|
| `node --version` shows an error | Re-download Node.js from nodejs.org and reinstall |
| `claude --version` shows an error | Re-run `npm install -g @anthropic-ai/claude-code` |
| `/install-herald` not found | Re-run the curl command from Step 5 |
| HERALD not responding after install | Make sure you restarted Claude Code (Step 9) |
| `curl` not found on Windows | Use Git Bash instead of PowerShell, or install curl from curl.se |

---

## What's next?

| Command | What it does |
|---|---|
| `/fast [your request]` | Skip the questions — go straight to planning |
| `/brainstorm [topic]` | Think through an idea before building anything |
| `/score` | Review how the last task went |

---

*Full technical documentation: [README.md](README.md)*
