# Publishing to app stores

What each store costs, what it demands, and what DeutschGarden still needs.
Figures verified 2026-08-20 against the stores' own documentation; every one of
them has changed in the last three years, so re-check before you pay anything.

## What it costs

| Store | Fee | Free? |
| --- | --- | --- |
| **Web / PWA** | nothing | **Yes** — no store, no account, no review |
| **Microsoft Store** (Windows) | **0** — the $19 individual fee is waived | **Yes**, via the new onboarding flow |
| **Snap Store** (Ubuntu) | nothing | **Yes** |
| **Flathub** (Linux) | nothing | **Yes**, but the source must be public |
| **Google Play** (Android) | **USD 25, one-time** | No |
| **Apple App Store** (iOS + macOS) | **USD 99 per year** | No |

Sources: [Microsoft individual registration](https://learn.microsoft.com/en-us/windows/apps/publish/whats-new-individual-developer)
· [Play registration](https://support.google.com/googleplay/android-developer/answer/6112435)
· [Apple fee waivers](https://developer.apple.com/help/account/membership/fee-waivers/)

**Three of the five are genuinely free**, plus the web build. Android costs $25
once. Apple costs $99 every year and there is no way around it for an
individual — see below.

### Apple's fee waiver does not apply to you

Apple waives the $99 for nonprofit organisations, accredited educational
institutions and government entities. The eligibility rules state explicitly
that the applicant must be a legal entity and **not an individual, sole
proprietor, or single-person business**, and must not sell anything through the
app. A solo developer publishing a free app does not qualify.

$99/year is the price of iOS at all, and of a macOS build that opens without a
Gatekeeper warning — the same membership covers both App Store distribution and
Developer ID notarization for distribution outside the store.

## Recommended order

1. **Web (PWA)** — already built. No fee, no account, no review, no gatekeeper,
   and it reaches every platform including iOS. Do this first.
2. **Microsoft Store** — free, and Store distribution also solves the
   SmartScreen warning that the raw `.exe` triggers.
3. **Snap Store** — free, and unlike Flathub it accepts a prebuilt binary,
   which matters a great deal for a Flutter app.
4. **Google Play** — $25 and a two-week testing gate. Worth it: it is where
   Android users actually look.
5. **Flathub** — free but the most technically demanding, and it requires the
   repository to be public.
6. **Apple** — last, because it is the only recurring cost. Skip it entirely
   unless iOS users are actually asking; the PWA covers iOS in Safari.

## Web / PWA — free, and already working

`flutter build web --release` produces `build/web`, and CI attaches
`DeutschGarden-web.tar.gz` to every release. CanvasKit is served locally rather
than from Google's CDN, so a loaded page makes no external requests at all.

Any static host works and all the obvious ones are free: GitHub Pages
(available now that the repository is public), Cloudflare Pages, Netlify,
Vercel.

```bash
flutter build web --release --base-href /deutsch-garden/
```

## Microsoft Store — free

**Start at <https://storedeveloper.microsoft.com>.** This matters: the fee is
waived only in that flow. Entering through Partner Center, Visual Studio or
Xbox gives you the legacy flow and asks for $19.

1. Register as an **Individual developer** (free). Identity is verified with a
   government ID and a selfie rather than a credit card. Available in roughly
   200 markets.
2. Reserve the app name in Partner Center.
3. Package as MSIX. For Flutter the usual route is the
   [`msix`](https://pub.dev/packages/msix) package: add it to
   `dev_dependencies`, configure `msix_config` in `pubspec.yaml` with the
   publisher identity Partner Center assigns, then `dart run msix:create`.
4. Store submissions are signed by Microsoft, so **SmartScreen stops warning** —
   this is the main reason to bother.
5. Fill in the IARC age rating questionnaire and the listing.

**What is missing today:** no MSIX packaging at all; the Windows build is a zip
of an `.exe` and DLLs.

## Snap Store — free

1. Create an Ubuntu One account, then `snapcraft login` and
   `snapcraft register deutschgarden`.
2. Write `snap/snapcraft.yaml`. Use `base: core22` (or `core24`) with the
   **flutter plugin plus the gnome extension** — the older `flutter/*`
   extensions only support `core18`.
3. Confinement: `strict`, with plugs for `audio-playback`, `audio-record`,
   `desktop`, `desktop-legacy`, `wayland` and `x11`.
4. `snapcraft` to build, `snapcraft upload --release=stable`. Review is
   automated unless you request `classic` confinement.

**Watch the speech fallback.** On Linux the app shells out to `spd-say` /
`espeak-ng`. Those binaries do not exist inside a strictly confined snap unless
they are staged into it, and speech-dispatcher normally runs as a user session
service outside the sandbox. Expect to either stage `espeak-ng` into the snap
or accept that synthesis is unavailable there. Test it before publishing rather
than discovering it in a review.

**What is missing today:** no `snap/snapcraft.yaml`.

## Flathub — free, but the strictest

Flathub is free and has no account fee, but it has two requirements that bite
this project specifically:

- **Everything must build from source, with no network access during the
  build.** For a Flutter app that means vendoring the SDK and the entire pub
  cache into the manifest. Prebuilt binaries in the submission are rejected.
  There is a
  [community guide for Flutter apps](https://discourse.flathub.org/t/to-all-publishers-of-flutter-apps-lets-build-from-source/8682)
  covering exactly this.
- **The source must be publicly available.** This repository is now public,
  so this condition is met. The build-from-source requirement above is still
  the real obstacle.

You will also need an AppStream MetaInfo XML file, a `.desktop` file, an icon,
screenshots, and an app ID you legitimately control. With no domain, use the
GitHub-derived form: `io.github.arman10121995.DeutschGarden`.

Sandboxing has the same `spd-say` problem as Snap, and more sharply: a Flatpak
sandbox cannot launch arbitrary host binaries. Speech synthesis on Linux will
need either a bundled `espeak-ng` or a D-Bus route to the host's
speech-dispatcher.

**What is missing today:** no flatpak manifest, no metainfo XML, and no
committed `.desktop` file — CI writes one at packaging time rather than
keeping one in the tree. The repository being private is no longer among the
blockers.

## Google Play — USD 25 once, plus a testing gate

The $25 is the easy part. The obstacle is this:

> Personal developer accounts created after **13 November 2023** must run a
> closed test with **at least 12 testers, opted in continuously for at least 14
> days**, before they can apply for production access.
> — [Play Console Help](https://support.google.com/googleplay/android-developer/answer/14151465)

The 14 days only start counting once the release is approved *and* 12 testers
have actually opted in — an email address that never clicked the link does not
count, and a tester who opts out early resets their contribution. Production
access review then takes up to about a week. Budget a month, and line up twelve
real people before you start. Organisation accounts are exempt, but registering
one needs a D-U-N-S number.

Then:

1. Upload an **AAB**, not an APK. `flutter build appbundle --release` works and
   produces a correctly signed bundle, but the measured 4.4 artifact is
   243 MiB. That exceeds Play's 200 MB base-module limit. Keep both offline
   voices, but move at least one model to an **install-time Play Asset
   Delivery pack** before submission; direct GitHub distribution is unaffected.
2. **Play App Signing** — Google holds the app signing key and your RSA-4096 key
   becomes the *upload* key. Keep it safe: it is how Play knows an upload is
   from you.
3. Privacy policy URL — required. `docs/PRIVACY.md` has the content; it needs a
   public URL, which the web build's host can provide.
4. Data safety form. For this app it is unusually easy: no data collected, none
   transmitted, no INTERNET permission. Declare `RECORD_AUDIO` as used on-device
   only.
5. Content rating questionnaire, screenshots, feature graphic, listing text.

**What is missing today:** the install-time asset-pack split, hosted privacy
policy, screenshots, listing copy, and the account/testing process. The AAB is
correctly built and signed, but must not be described as Play-ready at its
current base-module size.

## Apple — USD 99 per year

Only worth it if iOS matters more than $99/year. The PWA already runs on iOS
Safari.

- A **Mac is effectively required** for the final steps, though GitHub Actions
  macOS runners can build and upload if you load certificates and an App Store
  Connect API key into secrets. CI already builds both targets.
- The free Apple ID route only sideloads to your own device for 7 days. It
  cannot be used to distribute.
- **Review risk for this app specifically:** it presents CEFR A1–C2 levels and
  exam-style practice material. Apple is sensitive to apps that imply an
  official certification. The app is already careful about this — placement is
  described as diagnostic and the mocks as original practice — but keep that
  wording prominent in the listing and the screenshots.
- The macOS build also needs notarization, which is included in the same
  membership.

**What is missing today:** signing certificates, provisioning profiles,
notarization in CI, screenshots for every required device class.

## Shared work, whichever store you pick

- A **hosted privacy policy URL** — needed by Play and Apple, nice for the rest.
- **Screenshots** — none exist in the repository. Every store wants several, at
  specific sizes.
- **Listing copy** — a short description and a long one.
- **A support URL or contact address.**
- **Deciding whether the repository goes public.** Flathub requires it, GitHub
  Pages is free only with it, and it costs nothing else here since the code is
  already MIT.
