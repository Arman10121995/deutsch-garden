# release/

**The builds live on [the releases page](https://github.com/Arman10121995/deutsch-garden/releases/latest), not in this folder.**

This folder used to hold a committed copy of every platform build, so that a
download did not depend on the releases page. That stopped being possible in
3.9.0.

The first bundled neural voice took the Android build from 62 MB to 201 MB;
the second role voice takes the 4.5 APK to roughly 272 MiB. In either case,
**GitHub refuses any push containing a file over 100 MB.** Not a warning — the
push is rejected. The full multi-platform set is roughly 1.7 GB against a repository whose
history is already 366 MB, and binaries in git are permanent: every clone
downloads every version ever committed, forever. Even if the APK fit, adding
that payload per release is not something a repository survives.

So the v3.8.0 binaries that were here have been removed from the working tree
and this folder is a pointer. They remain in the history, which is why the
repository is the size it is — a cost already paid rather than one worth
paying again.

## Getting the current build

Every release attaches the same ten artifacts, all produced by one CI matrix
run from the tagged commit — not assembled by hand on someone's laptop:

| File | Platform | Size | Install |
| --- | --- | --- | --- |
| `DeutschGarden.apk` | Android | 269 MiB | Open it on the phone. Signed with the project release key, not a debug key. |
| `DeutschGarden.aab` | Android | 243 MiB | Signed app-bundle artifact, inside Play's current 500 MB compressed base-module limit. Above 200 MB, Play shows mobile-data users a non-blocking large-download notice. A phone cannot install an AAB directly. |
| `DeutschGarden-windows-x64.zip` | Windows | ~140 MiB | Extract, run `DeutschGarden.exe`. SmartScreen: **More info → Run anyway**. |
| `DeutschGarden-windows-x64.msix` | Windows | ~140 MiB | Installer with Start-menu entry and clean uninstall; the self-signed publisher still requires manual trust. |
| `DeutschGarden-x86_64.AppImage` | Linux | ~145 MiB | `chmod +x`, then run it. Needs GStreamer, which every mainstream desktop already ships. |
| `DeutschGarden-linux-x64.tar.gz` | Linux | ~145 MiB | The same build unpacked, if you prefer a directory. |
| `DeutschGarden-macos.zip` | macOS | ~165 MiB | Unzip to Applications. Gatekeeper: right-click → **Open**. |
| `DeutschGarden-ios-unsigned.ipa` | iOS | ~145 MiB | **Unsigned.** Needs re-signing with your own certificate. |
| `DeutschGarden-ios-unsigned.zip` | iOS | ~145 MiB | The same `.app` bundle, for tools that want it rather than the `.ipa` layout. |
| `DeutschGarden-web.tar.gz` | Web | ~134 MiB | A static PWA. Unpack and serve the `web/` directory from any host. |

Android, Windows and web figures were measured locally from the 4.5 release
candidate; the other native figures are estimates until the tagged matrix
publishes them. The 4.6 content additions are mostly text and do not change
the native voice footprint materially.

The Android signature is asserted in CI rather than trusted. The job runs
`apksigner verify --print-certs` and fails the build if it sees
`CN=Android Debug`; the release key reports
`CN=DeutschGarden, OU=DeutschGarden, O=DeutschGarden, L=Rostock, ST=Mecklenburg-Vorpommern, C=DE`.

Why each platform warns on install, and which warnings a paid certificate would
remove, is in [`../docs/SECURITY_WARNINGS.md`](../docs/SECURITY_WARNINGS.md).

Building any of them yourself takes one command and no signing identity — see
[`../docs/BUILD_AND_RELEASE.md`](../docs/BUILD_AND_RELEASE.md).

## How a release is cut

The repository is public, so GitHub-hosted runners are free and unmetered on
every platform. Pushing a `v*` tag runs the correctness gate, then the six-way
build matrix, then publishes the release with all ten files attached:

```bash
git tag v4.6.0 && git push origin v4.6.0
```

The publish step is idempotent — it creates the release if it is absent and
uploads over the assets if it already exists — so a matrix that half-failed can
be re-run without deleting anything by hand.
