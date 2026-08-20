# release/

The v3.5.1 build of every platform, committed so a download does not depend on
the releases page. These are the same files attached to
[the v3.5.1 release](https://github.com/Arman10121995/deutsch-garden/releases/tag/v3.5.1),
produced by the CI matrix from the tagged commit.

| File | Platform | Install |
| --- | --- | --- |
| `DeutschGarden.apk` | Android | Open it on the phone. Signed with the project release key, not a debug key. |
| `DeutschGarden-windows-x64.zip` | Windows | Extract, run `DeutschGarden.exe`. SmartScreen: **More info → Run anyway**. |
| `DeutschGarden-x86_64.AppImage` | Linux | `chmod +x`, then run it. |
| `DeutschGarden-linux-x64.tar.gz` | Linux | The same build unpacked, if you prefer a directory. |
| `DeutschGarden-macos.zip` | macOS | Unzip to Applications. Gatekeeper: right-click → **Open**. |
| `DeutschGarden-ios-unsigned.ipa` | iOS | **Unsigned.** Needs re-signing with your own certificate. |

Why each platform warns on install, and which warnings a paid certificate would
remove, is in [`../docs/SECURITY_WARNINGS.md`](../docs/SECURITY_WARNINGS.md).

Binaries in git are permanent: every clone of this repository downloads them,
whether or not it wants them. If the repository ever feels heavy, this folder
is the reason, and the releases page carries the same files.
