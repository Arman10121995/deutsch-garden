# Asset and platform policy

Two orderings. They are preferences, not absolutes: each step down is allowed,
but only when the step above genuinely cannot do the job, and the reason gets
written down where the decision lives.

## Where an asset may come from

1. **Make it ourselves.** First choice always. The 513 vocabulary drawings, the
   100 civics images and every animation in the app exist because this was the
   answer. Nothing we author can produce a copyright claim against whoever
   ships this.

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
limits, so the first line is a fact rather than a hope.
