# Asset and platform policy

Two orderings. They are preferences, not absolutes: each step down is allowed,
but only when the step above genuinely cannot do the job, and the reason gets
written down where the decision lives.

## Where an asset may come from

1. **Make it ourselves.** First choice always. The 999 vocabulary drawings, 32
   AI-assisted action scenes generated from an original project prompt, the 100
   civics images and every animation in the app exist because this was the
   answer. The generated scenes were reviewed and cropped locally and contain
   no copied source image, logo, text or watermark.

2. **MIT, ISC, BSD, Apache-2.0 or CC0.** Second choice, and it must *compose*:
   the licence has to permit onward distribution under this project's own MIT
   grant. The 85 Tabler pictograms in `assets/vocab_line/` are the worked
   example — MIT, notice shipped, attribution kept in every file, gate
   enforcing it.

3. **Royalty-free with no realistic strike risk.** Last resort, and in practice
   almost nothing qualifies, because "royalty-free" usually means *use is free*
   rather than *redistribution is free*.

### The distinction that actually decides it

Attribution-required composes. Redistribution-restricted does not.

A public MIT repository tells everyone downstream they may copy, modify,
sublicense and sell what is in it. That promise can only be made about files
the project is allowed to sublicense. A licence that says "you may use this but
may not redistribute it standalone, and may not apply different terms" cannot
sit in an MIT repository, however free it is to *use*.

Checked and rejected on exactly that basis:

| Source | Licence | Blocking clause |
| --- | --- | --- |
| Pixabay | Pixabay Content License | cannot distribute Content on a standalone basis — a `.gif` in `assets/` is standalone |
| LottieFiles | Lottie Simple License | may not impose different terms; distribution must carry that same licence |
| Cliply, MotionElements | bespoke free licences | same shape: use permitted, redistribution restricted |
| GIPHY, Tenor | mostly user-uploaded | provenance unknown, much of it pop culture, not clearable |

"Fair use" does not rescue any of these. Fair use is a defence about *use*;
bundling an asset into a distributed application is redistribution.

## What the app may cost

1. **Offline, exportable, and small enough for the stores.** First choice.
   Everything works in aeroplane mode, the profile exports and merges, and the
   build stays inside what Play, the Microsoft Store and the App Store accept.

2. **Bigger than the stores allow, if the functionality gain is large.** A
   deliberate trade, made once and written down — not something that happens by
   accident because assets crept in.

3. **Requiring the network.** Strongly discouraged, and never for anything a
   learner needs mid-session. Offline is the product, not a feature of it.

`tool/check_store_size.py` measures the current position against the store
limits, so choosing the second line is visible and documented rather than an
accidental consequence of asset creep. Version 4.4 made that trade for two
fully offline dialogue voices. The measured 4.5 Android base is 246 MiB and
remains below Play's current
500 MB compressed base-module limit, while direct builds remain complete.

### The one thing that uses the third rule

The optional German speech model, added in 4.1, is the only use the third rule
has ever been put to. It is worth recording exactly what was weighed, because
the next request to "just fetch something" will look similar and almost
certainly will not qualify.

**Why not the first rule.** The model cannot be generated. Training an ASR
model is not in scope for a single maintainer, and there is no smaller one
that reads German at a usable error rate.

**Why not bundled.** The 4.5 App Bundle is already 246 MiB because the two
offline role voices deliberately use the second rule. Adding another ~105 MB
for an optional transcript feature would make the eventual Play asset split
larger and every direct download heavier for something most learners will
never enable. An explicit one-time desktop download is the narrower trade.

**Licence.** NVIDIA `stt_de_fastconformer_hybrid_large_pc`, CC-BY-4.0:
attribution required, which composes with MIT the same way the Tabler icons
do. The attribution is written into the model directory on install and shown
on the settings card before the download starts. The 55 MB Kroko alternative
was rejected: CC-BY-SA with non-commercial free keys, and share-alike inside
an MIT application is a compliance burden with no upside.

**How minimal it is.** Once, on request, by name, with the size stated before
the button. Never during a session, never for anything a learner needs, never
without being asked. After it lands, nothing touches the network again.

**What it deliberately does *not* buy.** Android and iOS are not offered it.
The model would run fine on a phone; what stops it is that
`tool/patch_android_manifest.py` strips the INTERNET permission, so on Android
the offline promise is enforced by the operating system rather than by anyone
remembering. Handing that back for every learner — including the large
majority who never open the setting — to serve an opt-in extra on a platform
that already has a system recogniser is not "as minimally as possible". So the
download is desktop-only, and Linux, which has no recogniser at all, is the
platform that actually gains.

Reversing that is two lines (`isSupported` in `lib/asr_io.dart` and the
permission list in `tool/patch_android_manifest.py`). It is written here so it
stays a decision. `tool/check_network_use.py` fails the build if either moves,
if a second file opens a socket, if the download URL points anywhere but the
k2-fsa releases, or if the licence and accuracy notes stop travelling with the
model.
