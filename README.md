# OSINT VM Installer

PowerShell script that sets up a fresh Windows machine for OSINT work. Installs software, CLI tools, Chrome extensions, and bookmarks. Tweaks the box along the way — debloat, wallpaper, taskbar pins, telemetry off, Windows Update disabled.

**Run as Administrator.** Takes 30–60+ minutes depending on your connection.

---

## Install

1. Open **PowerShell as Administrator** (right-click → Run as administrator).

2. Allow the script to run:

   ```powershell
   Set-ExecutionPolicy Bypass
   ```

   Say **Yes to All** when prompted.

3. Download and run the installer:

   ```powershell
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/TheUnsocialEngineer/Osint-Installer-Script/refs/heads/main/OSINT-Installer.ps1?token=GHSAT0AAAAAAD5J2MKYY22H7KGXKCHZWXYO2R4BP5A" | iex
   ```

   If you already have the script on disk:

   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process
   cd C:\path\to\OsintVmStuff
   .\OSINT-Installer.ps1
   ```

4. Wait until it finishes. You'll see a green **OSINT VM setup complete** message. **Reboot when done** — especially if Docker or Chrome were installed for the first time.

---

## What it does

Everything lands under `C:\OSINT` unless noted otherwise.

### Browser

- Installs **Google Chrome** and sets it as the default browser.
- Removes the Edge desktop shortcut.
- Downloads OSINT bookmarks from GitHub to `C:\OSINT\Bookmarks\bookmarks_24_06_2026.html`.
- Force-installs **46** Chrome extensions via group policy. They show up automatically after Chrome launches.

<details>
<summary>Chrome extensions (46)</summary>

- uBlock Origin
- GHunt Companion
- Wappalyzer
- URLScan.io
- Sputnik
- Shodan
- Netcraft
- DNSChecker
- Netlas.io
- Wayback Machine
- Web Archives
- Forensic OSINT
- Go Full Page
- Save Webpages Offline As MHTML
- PhotoOSINT
- Split Screen for Google Chrome
- Street View Tracker
- Place ID Finder for Google Maps
- Search by Image
- EXIF Viewer Pro
- Perceptual Image Analysis
- Trufflepiggy - Context Search
- SearchJumper
- Dork Search Tool
- WHO I AM
- OSINT Username Search
- Context Menu Search
- Hunter.io
- Email Extractor
- YouTube Channel ID Finder
- TTFinder
- IG Username to ID
- Steam ID Finder
- InVID and WeVerify
- Instant Data Scraper
- HTML Inspector
- Link Klipper
- Regex Search
- View Rendered Source
- DumpItBlue+
- YouTube Booster
- Chrome Extension Source Viewer
- CRX Extractor
- Tampermonkey
- CopyFish OCR
- Blockchair

</details>

### Desktop apps

<details>
<summary>Chocolatey (26 packages)</summary>

- googlechrome
- git
- python312
- vscode
- notepadplusplus
- emeditor-free
- obsidian
- 7zip
- exiftool
- curl
- jq
- sysinternals
- tor-browser
- protonvpn
- wireshark
- ffmpeg
- vlc
- obs-studio
- sqlitebrowser
- openvpn
- nmap
- gh
- golang
- nodejs
- yarn
- docker-desktop

</details>

<details>
<summary>winget (1 package)</summary>

- Maltego

</details>

### OSINT CLI tools

Installed with pip, pipx, git, Go, or a standalone binary depending on what each project supports.

<details>
<summary>pipx (5)</summary>

- sherlock-project → `sherlock`
- ghunt → `ghunt`
- gitfive → `gitfive`
- maigret → `maigret`
- telegram-phone-number-checker

</details>

<details>
<summary>pip (4)</summary>

- holehe
- h8mail
- instaloader
- instagram-location-search

</details>

<details>
<summary>git clone → C:\OSINT (4)</summary>

- spiderfoot — `pip install -r requirements.txt`
- theHarvester — `uv sync`
- blackbird — `pip install -r requirements.txt`
- flowsint — Docker Compose (`docker-compose.prod.yml`)

</details>

<details>
<summary>Go install (2)</summary>

- subfinder
- httpx

</details>

<details>
<summary>Binary (1)</summary>

- PhoneInfoga — GitHub release → `C:\OSINT\bin`

</details>

### Flowsint

Needs **Docker Desktop** running. The script installs Docker, clones the repo to `C:\OSINT\flowsint`, copies env files, and starts the stack with `docker compose -f docker-compose.prod.yml up -d`.

UI: http://localhost:5173/register — create an account on first use.

If Docker wasn't ready during install, run `flowsint` from cmd or use the desktop shortcut after Docker is up.

### Launchers and shortcuts

`C:\OSINT\bin` is added to the machine PATH.

<details>
<summary>Batch launchers (15)</summary>

- sherlock
- ghunt
- gitfive
- maigret
- holehe
- h8mail
- telegram-phone-number-checker
- spiderfoot
- theharvester
- phoneinfoga
- blackbird
- instaloader
- start-docker
- flowsint
- flowsint-open

</details>

<details>
<summary>Desktop shortcuts (5)</summary>

- Sherlock
- SpiderFoot
- GHunt
- Flowsint
- Maltego

</details>

<details>
<summary>Taskbar pins (12)</summary>

- Command Prompt
- Windows PowerShell
- Google Chrome
- Visual Studio Code
- Obsidian
- Wireshark
- Sherlock
- GHunt
- SpiderFoot
- Maigret
- Flowsint
- Maltego

</details>

### Other changes

- Sets an OSINT wallpaper.
- Removes built-in apps: Bing News, Xbox apps, Teams, Clipchamp, Zune Music, Get Help, Get Started.
- Disables Windows telemetry.
- Disables **Windows Update** (service stopped and set to disabled). Re-enable manually if you want updates back.

---

## After install

1. Reboot.
2. Open Chrome — extensions install on their own within a minute or two.
3. Start Docker Desktop before using Flowsint.
4. Open a **new** cmd or PowerShell window so PATH picks up `C:\OSINT\bin`.

---

## Requirements

- Windows 10/11
- Administrator account
- Internet connection
- 30–60+ minutes depending on connection speed

---

## Files in this repo

| File | Purpose |
|------|---------|
| `OSINT-Installer.ps1` | Main installer script |
| `bookmarks_24_06_2026.html` | Bookmark source (installer downloads from GitHub when run via `iex`) |

---

## Notes

- Re-running the script is mostly safe. pip/pipx tools get upgraded, old git clones for tools that moved to pip/pipx get removed, and the bookmark file gets re-downloaded if missing.
- Some tools need API keys or accounts you set up yourself (Shodan, Hunter.io, Telegram checker, Maltego, Flowsint). The script only installs them.
- Use this on a VM or investigation box, not your personal daily driver, unless you're fine with Windows Update staying off.
