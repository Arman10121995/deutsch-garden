# Known Limitations

1. The bundled vocabulary bank contains 881 training cards, while the documented lexical-breadth targets are broader cumulative planning goals. CEFR provides no universal official word-count threshold.
2. Placement uses a compact 36-item adaptive instrument and has not undergone psychometric norming against a large certified learner sample.
3. Listening uses device German TTS rather than studio-recorded multi-speaker audio.
4. Writing evaluation is an offline transparent heuristic and cannot replace trained human scoring for advanced CEFR production.
5. **The speaking tutor is a scripted role-play, not a language model.** It follows a fixed sequence of authored turns and evaluates each reply with a deterministic rule engine. It will not improvise, will not answer a question you ask it, and will not follow you off-script. What it does reliably is tell you whether you addressed the turn, at sufficient length, using the target structures.
6. **Pronunciation scoring is text-based, not acoustic.** The lab compares the *recognised words* against the target sentence. It catches dropped words, wrong words, wrong endings and word-order problems. It cannot grade a single vowel or consonant, because no offline Flutter plugin provides forced phoneme alignment. A word transcribed correctly scores full marks even if the accent is heavy.
7. Speech recognition quality is the platform's, not the app's. On Android the system recogniser may route audio to the vendor's servers unless a German offline language pack is installed; on some devices and emulators no recogniser exists at all. Every speaking screen therefore accepts typed input as an equal path.
8. Free-talk scoring approximates coverage from answer length and connector use. It cannot verify that the content points were genuinely addressed — an off-topic answer of the right length and register will score well.
9. Stories are original graded texts written for this app, not authentic published literature. They are level-controlled rather than natural.
10. The SM-2 implementation uses conventional parameters rather than parameters fitted to this deck's review logs; it is a sound default, not a tuned model.
11. Achievements, quests and streaks are local. There is no leaderboard, no social feature and no server, so nothing here is comparable across users.
12. Exam-prep mini mocks train task types and strategy but are not full-length official provider papers.
13. Real exam formats can change. Verify official provider pages before registration or final preparation.
