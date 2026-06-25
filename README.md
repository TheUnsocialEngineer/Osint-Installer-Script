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
- Imports OSINT bookmarks into Chrome as **14 category folders on the bookmarks bar** (61 links) — Reference & Platforms, People Search, Email & Breaches, and the rest. No parent OSINT folder. Source HTML is saved to `C:\OSINT\Bookmarks\bookmarks_24_06_2026.html`.
- Force-installs **47** Chrome extensions via group policy. They show up automatically after Chrome launches.

If bookmarks did not appear correctly, see [Manual bookmark import](#manual-bookmark-import) below.

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
<summary>Chrome extensions (47)</summary>

> <details>
> <summary>Browser utility (3)</summary>
>
> - [uBlock Origin](https://chromewebstore.google.com/detail/cjpalhdlnbpafiamejdnhcphjbkeiagm)
> - [Proton Pass](https://chromewebstore.google.com/detail/ghmbeldphafepmbegfdlkpapadhbakde)
> - [Tampermonkey](https://chromewebstore.google.com/detail/dhdgffkkebhmkfjojejmpbldmpobfkfo)
> </details>

> <details>
> <summary>Infrastructure &amp; domains (7)</summary>
>
> - [Shodan](https://chromewebstore.google.com/detail/jjalcfnidlmpjhdfepjhjbhnhkbgleap)
> - [Netcraft](https://chromewebstore.google.com/detail/bmejphbfclcpmpohkggcjeibfilpamia)
> - [DNSChecker](https://chromewebstore.google.com/detail/gegfpbhjnhegdnjdkghhnneaocdbbhjp)
> - [Netlas.io](https://chromewebstore.google.com/detail/pncoieihjcmpooceknjajojehmhdedii)
> - [URLScan.io](https://chromewebstore.google.com/detail/loehkbkhflmmkempgkdpkkhghdiegicp)
> - [Wappalyzer](https://chromewebstore.google.com/detail/gppongmhjkpfnbhagpmjfkannfbllamg)
> - [Blockchair](https://chromewebstore.google.com/detail/fhhkkooikehnkaodebbfnkinedlllcfk)
> </details>

> <details>
> <summary>Archiving &amp; capture (4)</summary>
>
> - [Wayback Machine](https://chromewebstore.google.com/detail/fpnmgdkabkmnadcjpehmlllkndpkmiak)
> - [Web Archives](https://chromewebstore.google.com/detail/hkligngkgcpcolhcnkgccglchdafcnao)
> - [Save Webpages Offline As MHTML](https://chromewebstore.google.com/detail/nfbcfginnecenjncdjhaminfcienmehn)
> - [Go Full Page](https://chromewebstore.google.com/detail/fdpohaocaechififmbbbbbknoalclacl)
> </details>

> <details>
> <summary>Image &amp; video (6)</summary>
>
> - [Search by Image](https://chromewebstore.google.com/detail/cnojnbdhbhnkbcieeekonklommdnndci)
> - [EXIF Viewer Pro](https://chromewebstore.google.com/detail/mmbhfeiddhndihdjeganjggkmjapkffm)
> - [Perceptual Image Analysis](https://chromewebstore.google.com/detail/gidmeabdffonnejjlkbglmppmfniakdf)
> - [PhotoOSINT](https://chromewebstore.google.com/detail/gonhdjmkgfkokhkflfhkbiagbmoolhcd)
> - [InVID and WeVerify](https://chromewebstore.google.com/detail/mhccpoafgdgbhnjfhkcmgknndkeenfhe)
> - [CopyFish OCR](https://chromewebstore.google.com/detail/eenjdnjldapjajjofmldgmkjaienebbj)
> </details>

> <details>
> <summary>Maps &amp; geolocation (3)</summary>
>
> - [Street View Tracker](https://chromewebstore.google.com/detail/nlngoiabgfhbklfnidbhhcaakkojcocf)
> - [Place ID Finder for Google Maps](https://chromewebstore.google.com/detail/gdnnaahojechcmemagbbbbnoiieolafp)
> - [Split Screen for Google Chrome](https://chromewebstore.google.com/detail/dnollkdkikklpdganoecjcmmlddbennb)
> </details>

> <details>
> <summary>Research &amp; page tools (9)</summary>
>
> - [Forensic OSINT](https://chromewebstore.google.com/detail/jojaomahhndmeienhjihojidkddkahcn)
> - [Sputnik](https://chromewebstore.google.com/detail/manapjdamopgbpimgojkccikaabhmocd)
> - [Trufflepiggy - Context Search](https://chromewebstore.google.com/detail/chffnhocnckigoapjdienmaphjnljpmo)
> - [SearchJumper](https://chromewebstore.google.com/detail/hgepmblbgodbilmfdjkalkgofdcipkhh)
> - [Dork Search Tool](https://chromewebstore.google.com/detail/neadoiokjghjpklekpjifhheaddbdjca)
> - [Context Menu Search](https://chromewebstore.google.com/detail/ocpcmghnefmdhljkoiapafejjohldoga)
> - [View Rendered Source](https://chromewebstore.google.com/detail/ejgngohbdedoabanmclafpkoogegdpob)
> - [HTML Inspector](https://chromewebstore.google.com/detail/fpaahdcndgfpbbddmgckaifkfljkfkhd)
> - [Regex Search](https://chromewebstore.google.com/detail/dcnmfijohgljejnnocmbecmpccgficcm)
> </details>

> <details>
> <summary>People, email &amp; accounts (5)</summary>
>
> - [WHO I AM](https://chromewebstore.google.com/detail/gdnhlhadhgnhaenfcphpeakdghkccfoo)
> - [OSINT Username Search](https://chromewebstore.google.com/detail/hbpmcahfkjladffaenebdafoeohalfmp)
> - [Hunter.io](https://chromewebstore.google.com/detail/hgmhmanijnjhaffoampdlllchpolkdnj)
> - [Email Extractor](https://chromewebstore.google.com/detail/jdianbbpnakhcmfkcckaboohfgnngfcc)
> - [GHunt Companion](https://chromewebstore.google.com/detail/dpdcofblfbmmnikcbmmiakkclocadjab)
> </details>

> <details>
> <summary>Social &amp; platform IDs (6)</summary>
>
> - [YouTube Channel ID Finder](https://chromewebstore.google.com/detail/bfkbgahmplemjmengbjlncclgcnckogb)
> - [TTFinder](https://chromewebstore.google.com/detail/jjaeadbgppdbbdfhifejbheijbflleid)
> - [IG Username to ID](https://chromewebstore.google.com/detail/kcdkceelebfeldicmpijnhbkoibieoji)
> - [Steam ID Finder](https://chromewebstore.google.com/detail/iaeodlelphecgkpneeifmgcjgeoobjah)
> - [YouTube Booster](https://chromewebstore.google.com/detail/dajnidicmkknmmbapmmmlemjdfolgjnf)
> - [DumpItBlue+](https://chromewebstore.google.com/detail/igmgknoioooacbcpcfgjigbaajpelbfe)
> </details>

> <details>
> <summary>Scraping &amp; links (2)</summary>
>
> - [Instant Data Scraper](https://chromewebstore.google.com/detail/ofaokhiedipichpaobibbnahnkdoiiah)
> - [Link Klipper](https://chromewebstore.google.com/detail/fahollcgofmpnehocdgofnhkkchiekoo)
> </details>

> <details>
> <summary>Extension dev (2)</summary>
>
> - [Chrome Extension Source Viewer](https://chromewebstore.google.com/detail/jifpbeccnghkjeaalbbjmodiffmgedin)
> - [CRX Extractor](https://chromewebstore.google.com/detail/ajkhmmldknmfjnmeedkbkkojgobmljda)
> </details>

</details>

### Installed software

<details>
<summary>Installed software (26 packages)</summary>

> <details>
> <summary>Development &amp; editors (11)</summary>
>
> - [git](https://community.chocolatey.org/packages/git)
> - [python312](https://community.chocolatey.org/packages/python312)
> - [vscode](https://community.chocolatey.org/packages/vscode)
> - [notepadplusplus](https://community.chocolatey.org/packages/notepadplusplus)
> - [obsidian](https://community.chocolatey.org/packages/obsidian)
> - [gh](https://community.chocolatey.org/packages/gh)
> - [golang](https://community.chocolatey.org/packages/golang)
> - [nodejs](https://community.chocolatey.org/packages/nodejs)
> - [yarn](https://community.chocolatey.org/packages/yarn)
> - [curl](https://community.chocolatey.org/packages/curl)
> - [jq](https://community.chocolatey.org/packages/jq)
> </details>

> <details>
> <summary>Browser (1)</summary>
>
> - [googlechrome](https://community.chocolatey.org/packages/GoogleChrome)
> </details>

> <details>
> <summary>Security &amp; network (6)</summary>
>
> - [wireshark](https://community.chocolatey.org/packages/wireshark)
> - [nmap](https://community.chocolatey.org/packages/nmap)
> - [sysinternals](https://community.chocolatey.org/packages/sysinternals)
> - [tor-browser](https://community.chocolatey.org/packages/tor-browser)
> - [protonvpn](https://community.chocolatey.org/packages/protonvpn)
> - [openvpn](https://community.chocolatey.org/packages/openvpn)
> </details>

> <details>
> <summary>Media &amp; metadata (4)</summary>
>
> - [ffmpeg](https://community.chocolatey.org/packages/ffmpeg)
> - [vlc](https://community.chocolatey.org/packages/vlc)
> - [obs-studio](https://community.chocolatey.org/packages/obs-studio)
> - [exiftool](https://community.chocolatey.org/packages/exiftool)
> </details>

> <details>
> <summary>Utilities (2)</summary>
>
> - [7zip](https://community.chocolatey.org/packages/7zip)
> - [sqlitebrowser](https://community.chocolatey.org/packages/sqlitebrowser)
> </details>

> <details>
> <summary>Containers (1)</summary>
>
> - [docker-desktop](https://community.chocolatey.org/packages/docker-desktop)
> </details>

> <details>
> <summary>OSINT platform (1)</summary>
>
> - [Maltego](https://www.maltego.com/) (winget)
> </details>

</details>

### OSINT CLI tools

<details>
<summary>OSINT CLI tools (16)</summary>

> <details>
> <summary>Username &amp; people search (6)</summary>
>
> - [sherlock](https://github.com/sherlock-project/sherlock) — pipx (`sherlock-project`)
> - [maigret](https://github.com/soxoj/maigret) — pipx
> - [holehe](https://github.com/megadose/holehe) — pip
> - [h8mail](https://github.com/khast3x/h8mail) — pip
> - [blackbird](https://github.com/p1ngul1n0/blackbird) — git clone → `C:\OSINT\blackbird`
> - [instaloader](https://instaloader.github.io/) — pip
> </details>

> <details>
> <summary>Google &amp; social accounts (2)</summary>
>
> - [ghunt](https://github.com/mxrch/GHunt) — pipx
> - [gitfive](https://github.com/mxrch/GitFive) — git clone → `C:\OSINT\GitFive`
> </details>

> <details>
> <summary>Recon &amp; enumeration (4)</summary>
>
> - [theHarvester](https://github.com/laramies/theHarvester) — git clone → `C:\OSINT\theHarvester` (`uv sync`)
> - [spiderfoot](https://github.com/smicallef/spiderfoot) — git clone → `C:\OSINT\spiderfoot`
> - [subfinder](https://github.com/projectdiscovery/subfinder) — `go install`
> - [httpx](https://github.com/projectdiscovery/httpx) — `go install`
> </details>

> <details>
> <summary>Phone &amp; messaging (2)</summary>
>
> - [phoneinfoga](https://github.com/sundowndev/phoneinfoga) — binary → `C:\OSINT\bin`
> - [telegram-phone-number-checker](https://github.com/bellingcat/telegram-phone-number-checker) — pipx
> </details>

> <details>
> <summary>Instagram (1)</summary>
>
> - [instagram-location-search](https://pypi.org/project/instagram-location-search/) — pip
> </details>

> <details>
> <summary>Investigation platform (1)</summary>
>
> - [flowsint](https://github.com/reconurge/flowsint) — git clone → `C:\OSINT\flowsint` + Docker Compose
> </details>

</details>

### Flowsint

Needs **WSL 2** and **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** running. The script enables WSL, installs Docker Desktop, clones the repo to `C:\OSINT\flowsint`, copies env files, and starts the stack with `docker compose -f docker-compose.prod.yml up -d`.

If WSL or Docker were installed for the first time, **reboot** before expecting flowsint containers to start.

UI: [http://localhost:5173/register](http://localhost:5173/register) — create an account on first use.

If Docker wasn't ready during install, run `flowsint` from cmd or use the desktop shortcut after Docker is up.

**Docker / VM disclaimer:** The installer installs WSL 2 and Docker Desktop — it does not guarantee Docker will run on every machine. Docker needs hardware virtualization. On a VM, you may have to enable nested virtualization, assign enough RAM (8 GB+ recommended for Docker + Flowsint), and turn on VT-x/AMD-V in the host BIOS. Hyper-V-based VMs (Hyper-V, VMware with HV, some cloud instances) need extra setup; Docker Desktop may also ask for manual steps on first launch (WSL integration, signing in, accepting terms). If `docker info` fails after a reboot, fix Docker/WSL in Docker Desktop settings before running `flowsint`.

### Launchers and shortcuts

`C:\OSINT\bin` is added to the machine PATH.

<details>
<summary>Launchers and shortcuts</summary>

> <details>
> <summary>OSINT tool launchers (12)</summary>
>
> - [sherlock](https://github.com/sherlock-project/sherlock)
> - [ghunt](https://github.com/mxrch/GHunt)
> - [gitfive](https://github.com/mxrch/GitFive)
> - [maigret](https://github.com/soxoj/maigret)
> - [holehe](https://github.com/megadose/holehe)
> - [h8mail](https://github.com/khast3x/h8mail)
> - [telegram-phone-number-checker](https://github.com/bellingcat/telegram-phone-number-checker)
> - [spiderfoot](https://github.com/smicallef/spiderfoot)
> - [theharvester](https://github.com/laramies/theHarvester)
> - [phoneinfoga](https://github.com/sundowndev/phoneinfoga)
> - [blackbird](https://github.com/p1ngul1n0/blackbird)
> - [instaloader](https://instaloader.github.io/)
> </details>

> <details>
> <summary>Docker &amp; Flowsint launchers (3)</summary>
>
> - [start-docker](https://www.docker.com/products/docker-desktop/)
> - [flowsint](https://github.com/reconurge/flowsint)
> - [flowsint-open](http://localhost:5173/)
> </details>

> <details>
> <summary>Desktop shortcuts (5)</summary>
>
> - [Sherlock](https://github.com/sherlock-project/sherlock)
> - [SpiderFoot](https://github.com/smicallef/spiderfoot)
> - [GHunt](https://github.com/mxrch/GHunt)
> - [Flowsint](https://github.com/reconurge/flowsint)
> - [Maltego](https://www.maltego.com/)
> </details>

> <details>
> <summary>Taskbar pins (12)</summary>
>
> - Command Prompt
> - [Windows PowerShell](https://learn.microsoft.com/powershell/)
> - [Google Chrome](https://www.google.com/chrome/)
> - [Visual Studio Code](https://code.visualstudio.com/)
> - [Obsidian](https://obsidian.md/)
> - [Wireshark](https://www.wireshark.org/)
> - [Sherlock](https://github.com/sherlock-project/sherlock)
> - [GHunt](https://github.com/mxrch/GHunt)
> - [SpiderFoot](https://github.com/smicallef/spiderfoot)
> - [Maigret](https://github.com/soxoj/maigret)
> - [Flowsint](https://github.com/reconurge/flowsint)
> - [Maltego](https://www.maltego.com/)
> </details>

</details>

### Other changes

- Sets an OSINT wallpaper.
- Removes built-in apps: Bing News, Xbox apps, Teams, Clipchamp, Zune Music, Get Help, Get Started.
- Disables Windows telemetry.
- Disables **Windows Update** (service stopped and set to disabled). Re-enable manually if you want updates back.

---

## Manual bookmark import

The installer imports bookmarks into Chrome automatically while Chrome is closed. If category folders are missing from your bookmarks bar, show as one flat list, or only some folders appear, import the HTML file manually.

### Before you start

1. Close Chrome completely — check Task Manager and end every `chrome.exe` process.
2. Confirm the bookmark file exists at:

   `C:\OSINT\Bookmarks\bookmarks_24_06_2026.html`

   If it is missing, re-run the installer or download `bookmarks_24_06_2026.html` from this repo.

### Import in Chrome

1. Open Chrome.
2. Open the bookmark manager — **Bookmarks → Bookmark manager**, or press `Ctrl+Shift+O`.
3. Click the **⋮** menu (top right).
4. Click **Import bookmarks**.
5. Select `C:\OSINT\Bookmarks\bookmarks_24_06_2026.html`.
6. Click **Open**.

Chrome adds the import under **Bookmarks bar** as 14 top-level folders: Reference & Platforms, People Search, Email & Breaches, Infrastructure & Domains, Archiving, Image & Video, Maps & Satellite, Geolocation, Property Records, Public Records (US), Companies & Finance, Transport, Conflict & Monitoring, and Misc.

If you still have an old **OSINT** parent folder from a previous install, delete it first, then import again so you do not get duplicates.

### Re-run the installer instead

With Chrome fully closed, re-running `OSINT-Installer.ps1` rebuilds the 14 category folders on your bookmarks bar directly. Use this if HTML import keeps flattening folders.

---

## After install

1. Reboot.
2. Open Chrome — extensions install on their own within a minute or two. Bookmarks bar should show 14 category folders. If not, see [Manual bookmark import](#manual-bookmark-import).
3. Start Docker Desktop before using Flowsint (requires WSL 2 — reboot if the installer said WSL needs one).
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
- **Docker / Flowsint:** Installing Docker is not the same as Docker working. Nested virtualization, VM resource limits, and host hypervisor settings often need manual adjustment — see the disclaimer under [Flowsint](#flowsint).
