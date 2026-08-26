# release/

**The builds live on [the releases page](https://github.com/Arman10121995/deutsch-garden/releases/latest), not in this folder.**

This folder used to hold a committed copy of every platform build, so that a
download did not depend on the releases page. That stopped being possible in
3.9.0.

The bundled neural voice took the Android build from 62 MB to 201 MB, and
**GitHub refuses any push containing a file over 100 MB.** Not a warning — the
push is rejected. The full set is now about 780 MB against a repository whose
history is already 366 MB, and binaries in git are permanent: every clone
downloads every version ever committed, forever. Even if the APK fit, adding
780 MB per release is not something a repository survives.

So the v3.8.0 binaries that were here have been removed from the working tree
and this folder is a pointer. They remain in the history, which is why the
repository is the size it is — a cost already paid rather than one worth
paying again.

## Getting a build

Every release attaches the same eight artifacts, produced by the CI matrix
from the tagged commit:

| File | Platform | Install |
| --- | --- | --- |
| `DeutschGarden.apk` | Android | Open it on the phone. Signed with the project release key, not a debug key. |
| `DeutschGarden-windows-x64.zip` | Windows | Extract, run `DeutschGarden.exe`. SmartScreen: **More info → Run anyway**. |
| `DeutschGarden-x86_64.AppImage` | Linux | `chmod +x`, then run it. Needs GStreamer, which every mainstream desktop already ships. |
| `DeutschGarden-linux-x64.tar.gz` | Linux | The same build unpacked, if you prefer a directory. |
| `DeutschGarden-macos.zip` | macOS | Unzip to Applications. Gatekeeper: right-click → **Open**. |
| `DeutschGarden-ios-unsigned.ipa` | iOS | **Unsigned.** Needs re-signing with your own certificate. |
| `DeutschGarden-ios-unsigned.zip` | iOS | The same `.app` bundle, for tools that want it rather than the `.ipa` layout. |
| `DeutschGarden-web.tar.gz` | Web | A static PWA. Unpack and serve the `web/` directory from any host. |

Why each platform warns on install, and which warnings a paid certificate would
remove, is in [`../docs/SECURITY_WARNINGS.md`](../docs/SECURITY_WARNINGS.md).

Building any of them yourself takes one command and no signing identity — see
[`../docs/BUILD_AND_RELEASE.md`](../docs/BUILD_AND_RELEASE.md).
