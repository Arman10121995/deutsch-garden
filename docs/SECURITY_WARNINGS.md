# Security warnings when installing DeutschGarden

Every operating system warns about software it cannot trace to a known
publisher. Some of those warnings were this project's fault and are now fixed.
The rest are the price of distributing outside an app store, and no amount of
code changes removes them — only a paid signing certificate does.

This page is deliberately blunt about which is which.

## What 3.5.1 fixed

### Android: the "release" APK was signed with the debug key

`flutter build apk --release` signs with the **debug keystore** unless a release
signing config exists. Flutter's generated `android/app/build.gradle.kts` says
so in a `TODO`, and that `TODO` was never actioned. Every APK this project
shipped up to and including 3.5.0 carried `CN=Android Debug`.

That matters more than it sounds:

- Google Play Protect treats debug-signed release builds as a strong signal of
  a repackaged or tampered app, and warns accordingly.
- Third-party scanners flag it for the same reason.
- Play would refuse the upload outright.

3.5.1 signs with a real RSA-4096 key valid until 2054. Verify any APK yourself:

```bash
apksigner verify --print-certs DeutschGarden.apk
```

It must print `CN=DeutschGarden`, never `CN=Android Debug`. CI asserts this on
every build and fails if it regresses.

### Android: the app asked for INTERNET

The manifest requested `android.permission.INTERNET`, added on the assumption
that the speech recogniser needed it. It does not. Android's
`SpeechRecognizer` runs inside the system speech service — a separate process
with its own permissions — and this app only binds to it over IPC.

An offline education app asking for network access is exactly the shape a
scanner is built to notice, and it made the project's central claim
unverifiable. It is gone. DeutschGarden requests `RECORD_AUDIO` only when a
learner uses speaking features, and the microphone is declared **optional**, so
a device without one can still install. On Android 13 and later it requests
`POST_NOTIFICATIONS` only after the learner explicitly switches on the optional
daily reminder. That reminder is scheduled locally and sends no data anywhere.

The promise is now enforced by the OS instead of asserted in a README: the app
*cannot* contact a server, because Android will not let it.

## What is left, and what it would cost to remove

| Platform | Warning you will see | Removable? |
| --- | --- | --- |
| Android | "Install unknown apps" prompt | **No.** Inherent to sideloading. Publishing on Play removes it. |
| Android | Play Protect "unsafe app" | **Fixed in 3.5.1** (was the debug key). |
| Windows | SmartScreen: "Windows protected your PC" | Only with an Authenticode certificate. |
| macOS | Gatekeeper: "cannot be opened because the developer cannot be verified" | Only with Apple Developer + notarization. |
| iOS | Will not install at all | Only with Apple Developer signing. |
| Linux | None | — |

### Windows

SmartScreen blocks executables with no reputation. Reputation is tied to an
Authenticode signing certificate, and it accrues over downloads — a brand-new
OV certificate still shows the warning until enough installs accumulate. An EV
certificate carries reputation immediately.

- OV certificate: roughly $200–400 per year
- EV certificate: roughly $400–700 per year, hardware token required

A **self-signed** certificate does not help and can make things worse: the
publisher shows as untrusted rather than unknown.

Until then, users click **More info → Run anyway**.

### macOS and iOS

Both need the Apple Developer Program, $99 per year. That single membership
covers:

- notarizing the macOS `.app`, which removes the Gatekeeper block entirely
- signing the iOS build into an installable `.ipa`

The `.ipa` in the releases is **unsigned** — no CI runner holds an Apple
signing identity. It contains no `embedded.mobileprovision`, so it installs
only by re-signing with your own certificate through Sideloadly or AltStore, or
by running `flutter build ipa` on your own Mac.

Until then, macOS users right-click the app and choose **Open**, or run:

```bash
xattr -dr com.apple.quarantine /Applications/DeutschGarden.app
```

### Linux

AppImages carry no signature requirement. Mark it executable and run it:

```bash
chmod +x DeutschGarden-x86_64.AppImage
./DeutschGarden-x86_64.AppImage
```

## The signing key

The Android release key is the app's identity. Anyone holding it can publish an
update that Android accepts as genuine, and **losing it means you can never
update the app on Play again** — there is no recovery, and the only remedy is
publishing under a new package name and asking every user to reinstall.

- It is **not** in this repository. `.gitignore` excludes `key.properties`,
  `*.jks` and `*.keystore`.
- CI reads it from the repository secrets `ANDROID_KEYSTORE_BASE64`,
  `ANDROID_KEYSTORE_PASSWORD` and `ANDROID_KEY_ALIAS`.
- Local release builds read `key.properties` at the project root. Without that
  file the build falls back to debug signing, so a contributor without the key
  can still build and run — and CI's verification step catches it if such a
  build were ever released.

Back the keystore up somewhere you will still have in five years.

## Verifying a download

Every release lists SHA-256 checksums for its assets on the release page.
Signatures are the stronger check where they exist:

```bash
# Android
apksigner verify --print-certs DeutschGarden.apk

# macOS — expect "code object is not signed at all" until notarization exists
codesign -dv --verbose=4 DeutschGarden.app
```
