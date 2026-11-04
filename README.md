# Jadon's Ultimate Installer

[Download V23 — one CMD file](https://github.com/NahWhatsWrongNow/MTG-Forge-Installer/raw/refs/heads/main/Jadons%20Ultimate%20Installer%20v23.cmd)

Download the file above and run it on Windows. You only need the CMD; it embeds the applications, card catalogs and artwork. Internet access is needed when downloading Forge or a missing portable runtime. Windows PowerShell is required.

The installer includes MTG Forge, Archidekt deck import and sync, A Betting Man, Hold The Line, and the university development tools for Python, VS Code and React.

## V23

- Hold The Line has 23 factions and 4,600 cards. Bracket II adds ten factions and 2,000 executable card definitions, with the supplied deck boxes, backgrounds and progression.
- Bracket I, existing campaigns, deck imports, player names, statistics and themes are preserved.
- Live repair validates the replacement, stops and waits for the identified game service, and then replaces its program folder. Saves stay outside the replaced files.
- Recovery handles unresponsive owned services, rejects unrelated processes, prevents simultaneous setup and reports folder locks clearly.

Open **Hold The Line → II · Impossible Realms** for Bracket II. Practice and host progression settings are available alongside the normal unlock route.

[Release notes and verification](V23-RELEASE-NOTES.md)

**V23 SHA-256:** `07031B08E5E7EDBB1690D42D2FEEC3E9D80C178B9317BC952523F98FBF018E78`

## Working with this repository

The V23 CMD is stored with Git LFS because it is approximately 155 MiB. Use the download link above to obtain the actual installer. A Git LFS pointer is a short text file, not the installer.

To clone and edit locally with Git LFS installed:

```sh
git lfs install
git clone https://github.com/NahWhatsWrongNow/MTG-Forge-Installer.git
cd MTG-Forge-Installer
git lfs pull
```

After making changes, commit and push normally. Git LFS transfers the installer payload automatically. Keep generated runtime caches, logs and personal campaign data out of this repository.
