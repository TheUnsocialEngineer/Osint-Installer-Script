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
<summary>Bookmarks (61 links, 14 folders)</summary>

> <details>
> <summary>Reference &amp; Platforms (5)</summary>
>
> - [Bellingcat OSINT Toolkit](https://bellingcat.gitbook.io/toolkit)
> - [OSINT Rocks](https://osint.rocks/)
> - [OSINT Industries](https://app.osint.industries/)
> - [OsintCat](https://www.osintcat.net/)
> - [Epieos](https://epieos.com/)
> </details>

> <details>
> <summary>People Search (4)</summary>
>
> - [WhatsMyName](https://whatsmyname.app/)
> - [IDCrawl Username Search](https://www.idcrawl.com/username-search)
> - [ThatsThem](https://thatsthem.com/)
> - [PimEyes](https://pimeyes.com/en)
> </details>

> <details>
> <summary>Email &amp; Breaches (2)</summary>
>
> - [Have I Been Pwned](https://haveibeenpwned.com/)
> - [VoilaNorbert](https://www.voilanorbert.com/)
> </details>

> <details>
> <summary>Infrastructure &amp; Domains (8)</summary>
>
> - [Shodan](https://shodan.io/)
> - [Censys](https://search.censys.io/)
> - [URLScan](https://urlscan.io/)
> - [IntelX](https://intelx.io/)
> - [DomainTools WHOIS](https://whois.domaintools.com/)
> - [ICANN Lookup](https://lookup.icann.org/)
> - [grep.app](https://grep.app/)
> - [PublicWWW](https://publicwww.com/)
> </details>

> <details>
> <summary>Archiving (2)</summary>
>
> - [Wayback Machine](https://archive.org/web/)
> - [Archive.today](https://archive.ph/)
> </details>

> <details>
> <summary>Image &amp; Video (5)</summary>
>
> - [EXIF Tools](https://exif.tools/)
> - [Google Lens](https://lens.google.com/)
> - [TinEye](https://tineye.com/)
> - [Forensically](https://29a.ch/photo-forensics/)
> - [InVID WeVerify](https://www.invid-project.eu/tools-and-services/invid-verification-plugin/)
> </details>

> <details>
> <summary>Maps &amp; Satellite (12)</summary>
>
> - [Google Maps](https://www.google.com/maps)
> - [Google Earth](https://earth.google.com/web/)
> - [EOS LandViewer](https://eos.com/landviewer/)
> - [SARTopo](https://sartopo.com/)
> - [Overpass Turbo](https://overpass-turbo.eu/)
> - [OpenStreetMap](https://www.openstreetmap.org/)
> - [Sentinel Hub Playground](https://apps.sentinel-hub.com/sentinel-playground/)
> - [Sentinel Hub EO Browser](https://apps.sentinel-hub.com/eo-browser/)
> - [NASA Worldview](https://worldview.earthdata.nasa.gov/)
> - [NASA FIRMS](https://firms.modaps.eosdis.nasa.gov/map/)
> - [Mapillary](https://www.mapillary.com/app/)
> - [OpenAerialMap](https://openaerialmap.org/)
> </details>

> <details>
> <summary>Geolocation (3)</summary>
>
> - [SunCalc](https://www.suncalc.org/)
> - [GeoHints](https://geohints.com/)
> - [PeakVisor](https://peakvisor.com/)
> </details>

> <details>
> <summary>Property Records (2)</summary>
>
> - [Zillow](https://www.zillow.com/)
> - [Broward County Property Appraiser](https://bcpa.net/RecMenu.asp)
> </details>

> <details>
> <summary>Public Records (US) (4)</summary>
>
> - [Black Book Online - Voter Records](https://www.blackbookonline.info/USA-Voter-Records.aspx)
> - [Black Book Online - County Court Records](https://www.blackbookonline.info/USA-County-Court-Records.aspx)
> - [VoterRecords.com](https://voterrecords.com/)
> - [NSOPW Sex Offender Registry](https://www.nsopw.gov/search-public-sex-offender-registries)
> </details>

> <details>
> <summary>Companies &amp; Finance (6)</summary>
>
> - [OpenCorporates](https://opencorporates.com/)
> - [UK Companies House](https://find-and-update.company-information.service.gov.uk/)
> - [SEC EDGAR](https://www.sec.gov/edgar/search/)
> - [OpenSanctions](https://www.opensanctions.org/)
> - [OCCRP Aleph](https://aleph.occrp.org/)
> - [OpenSecrets](https://www.opensecrets.org/)
> </details>

> <details>
> <summary>Transport (4)</summary>
>
> - [Flightradar24](https://www.flightradar24.com/)
> - [FlightAware](https://www.flightaware.com/)
> - [MarineTraffic](https://www.marinetraffic.com/)
> - [VesselFinder](https://www.vesselfinder.com/)
> </details>

> <details>
> <summary>Conflict &amp; Monitoring (3)</summary>
>
> - [LiveUAMap](https://liveuamap.com/)
> - [ACLED](https://acleddata.com/)
> - [GPSJam](https://www.gpsjam.org/)
> </details>

> <details>
> <summary>Misc (1)</summary>
>
> - [Backend script refactor](https://chatgpt.com/c/693cab17-b60c-8329-9377-be540cd7441b)
> </details>

</details>

<details>
<summary>Chrome extensions (46)</summary>

> <details>
> <summary>Browser utility (2)</summary>
>
> - uBlock Origin
> - Tampermonkey
> </details>

> <details>
> <summary>Infrastructure &amp; domains (7)</summary>
>
> - Shodan
> - Netcraft
> - DNSChecker
> - Netlas.io
> - URLScan.io
> - Wappalyzer
> - Blockchair
> </details>

> <details>
> <summary>Archiving &amp; capture (4)</summary>
>
> - Wayback Machine
> - Web Archives
> - Save Webpages Offline As MHTML
> - Go Full Page
> </details>

> <details>
> <summary>Image &amp; video (6)</summary>
>
> - Search by Image
> - EXIF Viewer Pro
> - Perceptual Image Analysis
> - PhotoOSINT
> - InVID and WeVerify
> - CopyFish OCR
> </details>

> <details>
> <summary>Maps &amp; geolocation (3)</summary>
>
> - Street View Tracker
> - Place ID Finder for Google Maps
> - Split Screen for Google Chrome
> </details>

> <details>
> <summary>Research &amp; page tools (9)</summary>
>
> - Forensic OSINT
> - Sputnik
> - Trufflepiggy - Context Search
> - SearchJumper
> - Dork Search Tool
> - Context Menu Search
> - View Rendered Source
> - HTML Inspector
> - Regex Search
> </details>

> <details>
> <summary>People, email &amp; accounts (5)</summary>
>
> - WHO I AM
> - OSINT Username Search
> - Hunter.io
> - Email Extractor
> - GHunt Companion
> </details>

> <details>
> <summary>Social &amp; platform IDs (6)</summary>
>
> - YouTube Channel ID Finder
> - TTFinder
> - IG Username to ID
> - Steam ID Finder
> - YouTube Booster
> - DumpItBlue+
> </details>

> <details>
> <summary>Scraping &amp; links (2)</summary>
>
> - Instant Data Scraper
> - Link Klipper
> </details>

> <details>
> <summary>Extension dev (2)</summary>
>
> - Chrome Extension Source Viewer
> - CRX Extractor
> </details>

</details>

### Installed software

<details>
<summary>Installed software (27 packages)</summary>

> <details>
> <summary>Development &amp; editors (12)</summary>
>
> - git
> - python312
> - vscode
> - notepadplusplus
> - emeditor-free
> - obsidian
> - gh
> - golang
> - nodejs
> - yarn
> - curl
> - jq
> </details>

> <details>
> <summary>Browser (1)</summary>
>
> - googlechrome
> </details>

> <details>
> <summary>Security &amp; network (6)</summary>
>
> - wireshark
> - nmap
> - sysinternals
> - tor-browser
> - protonvpn
> - openvpn
> </details>

> <details>
> <summary>Media &amp; metadata (4)</summary>
>
> - ffmpeg
> - vlc
> - obs-studio
> - exiftool
> </details>

> <details>
> <summary>Utilities (2)</summary>
>
> - 7zip
> - sqlitebrowser
> </details>

> <details>
> <summary>Containers (1)</summary>
>
> - docker-desktop
> </details>

> <details>
> <summary>OSINT platform (1)</summary>
>
> - Maltego (winget)
> </details>

</details>

### OSINT CLI tools

<details>
<summary>OSINT CLI tools (16)</summary>

> <details>
> <summary>Username &amp; people search (6)</summary>
>
> - sherlock — pipx (`sherlock-project`)
> - maigret — pipx
> - holehe — pip
> - h8mail — pip
> - blackbird — git clone → `C:\OSINT\blackbird`
> - instaloader — pip
> </details>

> <details>
> <summary>Google &amp; social accounts (2)</summary>
>
> - ghunt — pipx
> - gitfive — pipx
> </details>

> <details>
> <summary>Recon &amp; enumeration (4)</summary>
>
> - theHarvester — git clone → `C:\OSINT\theHarvester` (`uv sync`)
> - spiderfoot — git clone → `C:\OSINT\spiderfoot`
> - subfinder — `go install`
> - httpx — `go install`
> </details>

> <details>
> <summary>Phone &amp; messaging (2)</summary>
>
> - phoneinfoga — binary → `C:\OSINT\bin`
> - telegram-phone-number-checker — pipx
> </details>

> <details>
> <summary>Instagram (1)</summary>
>
> - instagram-location-search — pip
> </details>

> <details>
> <summary>Investigation platform (1)</summary>
>
> - flowsint — git clone → `C:\OSINT\flowsint` + Docker Compose
> </details>

</details>

### Flowsint

Needs **Docker Desktop** running. The script installs Docker, clones the repo to `C:\OSINT\flowsint`, copies env files, and starts the stack with `docker compose -f docker-compose.prod.yml up -d`.

UI: http://localhost:5173/register — create an account on first use.

If Docker wasn't ready during install, run `flowsint` from cmd or use the desktop shortcut after Docker is up.

### Launchers and shortcuts

`C:\OSINT\bin` is added to the machine PATH.

<details>
<summary>Launchers and shortcuts</summary>

> <details>
> <summary>OSINT tool launchers (12)</summary>
>
> - sherlock
> - ghunt
> - gitfive
> - maigret
> - holehe
> - h8mail
> - telegram-phone-number-checker
> - spiderfoot
> - theharvester
> - phoneinfoga
> - blackbird
> - instaloader
> </details>

> <details>
> <summary>Docker &amp; Flowsint launchers (3)</summary>
>
> - start-docker
> - flowsint
> - flowsint-open
> </details>

> <details>
> <summary>Desktop shortcuts (5)</summary>
>
> - Sherlock
> - SpiderFoot
> - GHunt
> - Flowsint
> - Maltego
> </details>

> <details>
> <summary>Taskbar pins (12)</summary>
>
> - Command Prompt
> - Windows PowerShell
> - Google Chrome
> - Visual Studio Code
> - Obsidian
> - Wireshark
> - Sherlock
> - GHunt
> - SpiderFoot
> - Maigret
> - Flowsint
> - Maltego
> </details>

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
