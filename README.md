# Captain Kill Switch — downloads

Public download host for **[Captain Kill Switch](https://captainkillswitch.com)**:
a free menu-bar / system-tray button that closes every running application in
one click, for macOS, Windows and Linux.

![Demo: a cluttered desktop, one click on the tray icon, and every app closes](https://captainkillswitch.com/demo/cks-demo.gif)

**→ [captainkillswitch.com](https://captainkillswitch.com)** is the place to
start. It picks the right file for your OS and carries the install commands,
the FAQ and the [privacy policy](https://captainkillswitch.com/privacy).

This repository only *hosts files*. It is not the source — the app is closed
source and lives in a private repo. What is published here is deliberately
verifiable:

| | |
|---|---|
| `latest.json` | the updater manifest all three platforms poll |
| `latest-*.dmg` / `.pkg` / `.exe` / `.msi` / `.deb` | the current installers |
| `apt/` | the signed apt repository (Linux) |
| Releases tagged `vX.Y.Z` | immutable per-version copies + `SHA256SUMS.txt` |

Every release publishes `SHA256SUMS.txt` alongside the installers, so any
download can be checked against the version it claims to be:

```sh
shasum -a 256 captain-kill-switch-*-linux-amd64.deb
```

macOS builds are Developer ID signed and notarised by Apple. Linux installs
from the signed apt repository above. Windows builds are not code-signed yet,
so SmartScreen will warn on first run — click **More info → Run anyway**; it
flags anything it has not seen downloaded widely, regardless of what it does.

## Install

Full instructions, including Homebrew, Scoop, apt and AUR, are on the
[download page](https://captainkillswitch.com/#download). Per-platform pages:
[macOS](https://captainkillswitch.com/mac) ·
[Windows](https://captainkillswitch.com/windows) ·
[Linux](https://captainkillswitch.com/linux)
