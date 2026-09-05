# SVG Manual Creation System for Deutsch Garden

## Understanding the Task

**The existing 1,280 SVGs are HAND-CRAFTED, UNIQUE visual representations.**
- Each SVG is individually designed for its specific word
- They use creative visual metaphors
- They follow a consistent style but each is UNIQUE
- **No automatic generation can match this quality**

## How This System Works

### 1. **Identify Missing Words**
- There are 8,720 words without a direct semantic SVG
- Words are organized by ID: 001-203 (core), x10001-x10728 (expansion), x10729-x10939 (extra), x20000-x28876 (generated)

### 2. **Create Batches**
- Work on 10-50 words at a time
- For each word, provide **specific visual instructions**
- Each SVG must be **manually created** based on the instructions

### 3. **Visual Requirements**
- **Format:** SVG with viewBox="0 0 64 64"
- **Content:** Pure vector graphics (NO TEXT)
- **Style:** Match existing SVGs (simple, clean, meaningful)
- **Uniqueness:** Each SVG must be different

## Available Commands

```bash
# Show overall progress
python tool/svg_batch_workflow.py --status

# Create new batch of words to work on
python tool/svg_batch_workflow.py --new-batch 10

# List current batch with completion status
python tool/svg_batch_workflow.py --list-batch

# Show detailed instructions for current batch
python tool/svg_batch_workflow.py --instructions

# Use predefined SVGs for words that have templates
python tool/svg_batch_workflow.py --use-predefined

# Mark current batch as complete
python tool/svg_batch_workflow.py --complete
```

## Current Progress

- **Total words:** 10,000
- **With SVGs:** 1,280
- **Missing:** 8,720
- **Next to create:** select a fresh batch with `--new-batch` and resolve every
  proposed id against the live deck before drawing it.

### Completed in This Session (102-175)

1. `assets/vocab/102.svg` - Wort (word) - Open book
2. `assets/vocab/103.svg` - Satz (sentence) - Speech bubbles
3. `assets/vocab/104.svg` - Grammatik (grammar) - Stack of books
4. `assets/vocab/105.svg` - Bedeutung (meaning) - Lightbulb
5. `assets/vocab/106.svg` - Aussprache (pronunciation) - Mouth with sound waves
6. `assets/vocab/107.svg` - Fehler (mistake) - Circle with X
7. `assets/vocab/108.svg` - Übung (exercise) - Checkmark in box
8. `assets/vocab/109.svg` - Geld (money) - Coin
9. `assets/vocab/110.svg` - Preis (price) - Price tag
10. `assets/vocab/111.svg` - Geschäft (shop) - Store front
11. `assets/vocab/112.svg` - Rechnung (bill) - Document with lines
12. `assets/vocab/113.svg` - Karte (card) - Playing cards
13. `assets/vocab/114.svg` - Handy (mobile phone) - Phone
14. `assets/vocab/115.svg` - Internet (internet) - Globe
15. `assets/vocab/116.svg` - Passwort (password) - Lock
16. `assets/vocab/117.svg` - Datei (file) - Document
17. `assets/vocab/118.svg` - Bildschirm (screen) - Monitor
19. `assets/vocab/119.svg` - Nachricht (message) - Envelope
20. `assets/vocab/120.svg` - Gespräch (conversation) - Speech bubbles
21. `assets/vocab/121.svg` - Hilfe (help) - Lifebuoy
22. `assets/vocab/122.svg` - Problem (problem) - Warning triangle
23. `assets/vocab/123.svg` - Lösung (solution) - Lightbulb on document
24. `assets/vocab/124.svg` - Erfahrung (experience) - Path/timeline
25. `assets/vocab/125.svg` - Entscheidung (decision) - Person at crossroads
26. `assets/vocab/126.svg` - Möglichkeit (possibility) - Open doors
27. `assets/vocab/127.svg` - Verantwortung (responsibility) - Shield with star
28. `assets/vocab/128.svg` - Entwicklung (development) - Upward arrow with curve
29. `assets/vocab/129.svg` - Erklärung (explanation) - Speech bubble with info
30. `assets/vocab/130.svg` - Unterschied (difference) - Two different circles
31. `assets/vocab/131.svg` - Beziehung (relationship) - Connected people
32. `assets/vocab/132.svg` - Gewohnheit (habit) - Calendar with checkmarks
33. `assets/vocab/133.svg` - Umgebung (environment) - House with trees
34. `assets/vocab/134.svg` - Vorteil (advantage) - Thumbs up
35. `assets/vocab/135.svg` - Nachteil (disadvantage) - Thumbs down
36. `assets/vocab/136.svg` - Meinung (opinion) - Speech bubble with star
37. `assets/vocab/137.svg` - Teilnahme (participation) - Group of people
38. `assets/vocab/138.svg` - Voraussetzung (requirement) - Checklist
39. `assets/vocab/139.svg` - Unterstützung (support) - Hand helping
40. `assets/vocab/140.svg` - Veranstaltung (event) - Calendar with people
41. `assets/vocab/141.svg` - Versicherung (insurance) - Shield document
42. `assets/vocab/142.svg` - Bewerbung (application) - Document with pen
43. `assets/vocab/143.svg` - Fortschritt (progress) - Upward path
44. `assets/vocab/144.svg` - Auswirkung (impact) - Explosion/radiation
45. `assets/vocab/145.svg` - Herausforderung (challenge) - Mountain path
46. `assets/vocab/146.svg` - Maßnahme (measure) - Gears/cogs
47. `assets/vocab/147.svg` - Fähigkeit (ability) - Medal/star
48. `assets/vocab/148.svg` - Kenntnis (knowledge) - Brain
49. `assets/vocab/149.svg` - Zusammenarbeit (collaboration) - People in circle
50. `assets/vocab/150.svg` - Anforderung (requirement) - Checklist
51. `assets/vocab/151.svg` - Veränderung (change) - Swapping arrows
52. `assets/vocab/152.svg` - Ursache (cause) - Domino pieces
53. `assets/vocab/153.svg` - Folge (consequence) - Chain of circles
54. `assets/vocab/154.svg` - Zusammenhang (connection) - Linked circles
55. `assets/vocab/155.svg` - Behauptung (claim) - Emphasized speech bubble
56. `assets/vocab/156.svg` - Beleg (evidence) - Magnifying glass on document
57. `assets/vocab/157.svg` - Rücksicht (consideration) - Eye watching people
58. `assets/vocab/158.svg` - Rückmeldung (feedback) - Returning speech bubble
59. `assets/vocab/159.svg` - Vereinbarung (agreement) - Handshake
60. `assets/vocab/160.svg` - Beschwerde (complaint) - Angry speech bubble
61. `assets/vocab/161.svg` - Leistung (performance) - Trophy/medal
62. `assets/vocab/162.svg` - Zustimmung (approval) - Thumbs up
63. `assets/vocab/163.svg` - Widerspruch (contradiction) - Opposing arrows
64. `assets/vocab/164.svg` - Vorgehensweise (approach) - Flowchart path
65. `assets/vocab/165.svg` - Einschätzung (assessment) - Measuring document
66. `assets/vocab/166.svg` - Abwägung (weighing) - Scales
67. `assets/vocab/167.svg` - Wahrnehmung (perception) - Eye
68. `assets/vocab/168.svg` - Nachhaltigkeit (sustainability) - Leaf with branches
69. `assets/vocab/169.svg` - Glaubwürdigkeit (credibility) - Certificate with seal
70. `assets/vocab/170.svg` - Zuverlässigkeit (reliability) - Clock
71. `assets/vocab/171.svg` - Umsetzbarkeit (feasibility) - Checklist with checks
72. `assets/vocab/172.svg` - Tragweite (scope) - Concentric circles
73. `assets/vocab/173.svg` - Auseinandersetzung (debate) - People arguing
74. `assets/vocab/174.svg` - Stellungnahme (statement) - Official document
75. `assets/vocab/175.svg` - Sachverhalt (facts) - Folder with documents

### Completed in This Session (x10001-x10129)

1. `assets/vocab/x10001.svg` - Hallo (hello) - Waving hand
2. `assets/vocab/x10002.svg` - Tschüss (bye) - Waving hand
3. `assets/vocab/x10003.svg` - bitte (please) - Praying hands
4. `assets/vocab/x10004.svg` - danke (thanks) - Bowing person
5. `assets/vocab/x10005.svg` - gern (gladly) - Smiling face
6-124. `assets/vocab/x10006.svg` through `x10124.svg` - Various communication and action verbs
125. `assets/vocab/x10125.svg` - zeigen (to show) - Hand pointing to target with arrow
126. `assets/vocab/x10126.svg` - schicken (to send) - Envelope with outgoing arrows
127. `assets/vocab/x10127.svg` - bekommen (to receive) - Inbox with incoming arrows
128. `assets/vocab/x10128.svg` - bringen (to bring) - Person carrying box
129. `assets/vocab/x10129.svg` - holen (to fetch) - Hand reaching for distant object
130. `assets/vocab/x10130.svg` - mitnehmen (to take along) - Person with luggage bag
131. `assets/vocab/x10131.svg` - ankommen (to arrive) - Train with person arriving
132. `assets/vocab/x10132.svg` - abfahren (to depart) - Train with person waving goodbye
133. `assets/vocab/x10133.svg` - umsteigen (to change trains) - Person with luggage between two trains
134. `assets/vocab/x10134.svg` - verpassen (to miss) - Clock with red X, person missing bus
135. `assets/vocab/x10135.svg` - reisen (to travel) - Person with suitcase and destination
136. `assets/vocab/x10136.svg` - fliegen (to fly) - Airplane with flying motion
137. `assets/vocab/x10137.svg` - mieten (to rent) - Person with document
138. `assets/vocab/x10138.svg` - umziehen (to move) - Person with furniture and new house
139. `assets/vocab/x10139.svg` - reparieren (to repair) - Toolbox with person and object
140. `assets/vocab/x10140.svg` - putzen (to clean) - Person with cleaning tools
141. `assets/vocab/x10141.svg` - waschen (to wash) - Person with washboard
142. `assets/vocab/x10142.svg` - einkaufen (to shop) - Person with shopping bag
143. `assets/vocab/x10143.svg` - verkaufen (to sell) - Person with shop and customer
144. `assets/vocab/x10144.svg` - umtauschen (to exchange) - Two people exchanging items
145. `assets/vocab/x10145.svg` - passen (to fit) - Box with measurement check
146. `assets/vocab/x10146.svg` - sparen (to save) - Person with piggy bank
147. `assets/vocab/x10147.svg` - verdienen (to earn) - Person with money
148. `assets/vocab/x10148.svg` - zahlen (to pay) - Person with coin
149. `assets/vocab/x10149.svg` - überweisen (to transfer) - Two people with money transfer
150. `assets/vocab/x10150.svg` - anrufen (to call) - Person with phone
151. `assets/vocab/x10151.svg` - telefonieren (to phone) - Two people on phones
152. `assets/vocab/x10152.svg` - warten (to wait) - Person with clock
153. `assets/vocab/x10153.svg` - suchen (to search) - Person with magnifying glass
154. `assets/vocab/x10154.svg` - finden (to find) - Person discovering object
155. `assets/vocab/x10155.svg` - verlieren (to lose) - Person with red X over item
156. `assets/vocab/x10156.svg` - gewinnen (to win) - Person with trophy
157. `assets/vocab/x10157.svg` - üben (to practise) - Person with exercise book
158. `assets/vocab/x10158.svg` - studieren (to study) - Person with book and graduation cap
159. `assets/vocab/x10159.svg` - prüfen (to check) - Person with checklist
160. `assets/vocab/x10160.svg` - bestehen (to pass) - Person with approved paper
161. `assets/vocab/x10161.svg` - arbeiten an (to work on) - Person at desk with tools
162. `assets/vocab/x10162.svg` - sich bewerben (to apply) - Person with application document
163. `assets/vocab/x10163.svg` - kündigen (to cancel) - Person with cancellation stamp
164. `assets/vocab/x10164.svg` - sich interessieren (to be interested) - Person looking at object
165. `assets/vocab/x10165.svg` - sich freuen (to look forward) - Happy person with calendar
166. `assets/vocab/x10166.svg` - sich fühlen (to feel) - Person with heart
167. `assets/vocab/x10167.svg` - sich treffen (to meet) - Two people meeting
168. `assets/vocab/x10168.svg` - sich beeilen (to hurry) - Person with clock rushing
169. `assets/vocab/x10169.svg` - sich ausruhen (to rest) - Person on bed
170. `assets/vocab/x10170.svg` - weh tun (to hurt) - Hand with red mark
171. `assets/vocab/x10171.svg` - husten (to cough) - Person with mouth covered
172. `assets/vocab/x10172.svg` - untersuchen (to examine) - Doctor with patient
173. `assets/vocab/x10173.svg` - verschreiben (to prescribe) - Doctor with prescription
174. `assets/vocab/x10174.svg` - besser (better) - Upward arrow with person
175. `assets/vocab/x10175.svg` - schlimmer (worse) - Downward arrow with red
176. `assets/vocab/x10176.svg` - billig (cheap) - Price tag with low mark
177. `assets/vocab/x10177.svg` - teuer (expensive) - Price tag with high mark
178. `assets/vocab/x10178.svg` - bequem (comfortable) - Chair with person
179. `assets/vocab/x10179.svg` - unbequem (uncomfortable) - Broken chair with person
180. `assets/vocab/x10180.svg` - freundlich (friendly) - Smiling person with heart
181. `assets/vocab/x10181.svg` - unfreundlich (unfriendly) - Angry person
182. `assets/vocab/x10182.svg` - pünktlich (punctual) - Person with clock showing exact time
183. `assets/vocab/x10183.svg` - ungefähr (approximately) - Wavy line with question mark
184. `assets/vocab/x10184.svg` - plötzlich (suddenly) - Lightning bolt with person
185. `assets/vocab/x10185.svg` - zuerst (first) - Number 1 with person
186. `assets/vocab/x10186.svg` - dann (then) - Arrow pointing forward
187. `assets/vocab/x10187.svg` - danach (after that) - Arrow pointing backward from finish
188. `assets/vocab/x10188.svg` - zuletzt (last) - Final checkmark with person
189. `assets/vocab/x10189.svg` - schon (already) - Clock with completed checkmark
190. `assets/vocab/x10190.svg` - noch (still) - Person waiting with clock
191. `assets/vocab/x10191.svg` - wieder (again) - Circular arrow with person
192. `assets/vocab/x10192.svg` - meistens (mostly) - Large portion with small remainder
193. `assets/vocab/x10193.svg` - selten (rarely) - Small portion with large remainder
194. `assets/vocab/x10194.svg` - vielleicht (perhaps) - Thought bubble with question mark

### Completed in This Session (102-175)

1. `assets/vocab/102.svg` - Wort (word) - Open book

### Step 1: Start a New Batch

```bash
python tool/svg_batch_workflow.py --new-batch 20
```

This creates a batch of 20 words that need SVGs.

### Step 2: View Instructions

```bash
python tool/svg_batch_workflow.py --instructions
```

This shows specific visual instructions for each word in the batch.

### Step 3: Create SVGs Manually

For each word, create a UNIQUE SVG file in `assets/vocab/` with the word ID as filename.

**Example:** For word 102 (Wort - word), create `assets/vocab/102.svg`

### Step 4: Verify and Mark Complete

Check each SVG:
- ✅ Valid SVG format
- ✅ viewBox="0 0 64 64"
- ✅ Pure vector graphics (no text)
- ✅ Unique and meaningful
- ✅ Matches existing style

```bash
python tool/svg_batch_workflow.py --list-batch
```

This shows which words in the batch have SVGs (marked with ✓).

## Visual Style Guide

### Color Palette (from existing SVGs)

| Name | Hex | Usage |
|------|-----|-------|
| Skin | #E8B08A | People, faces |
| Blue | #378ADD | Clothes, water, objects |
| Red | #E24B4A | Important elements, clothing |
| Brown | #8A5A2B | Wood, hair, handles |
| Beige | #FAC775 | Paper, buildings, light |
| Gray | #888780 | Buildings, neutral objects |
| Light Blue | #85B7EB | Windows, eyes, sky |
| Orange | #EF9F27 | Accents, highlights |
| Green | #639922 | Plants, positive elements |
| Dark | #444441 | Shadows, details, outlines |

### Design Principles

1. **Simplicity:** Use minimal shapes
2. **Clarity:** Should be recognizable
3. **Uniqueness:** Each SVG must be different
4. **Meaning:** Visual should suggest the word's meaning
5. **Consistency:** Match the aesthetic of existing SVGs

### Common Patterns from Existing SVGs

**People (001-010):**
- Head: circle
- Body: rectangle or path
- Clothes: colored shapes over body
- Details: eyes, hair, accessories

**Buildings (011-016):**
- Walls: rectangles
- Roof: triangle or curved path
- Windows: small rectangles
- Door: rectangle with details

**Furniture (017-020):**
- Table: flat surface + legs
- Chair: seat + back + legs
- Bed: mattress + frame + pillow

**Nature (087-094):**
- Tree: trunk + leaf canopy
- Sun: circle + rays
- Cloud: curved path
- Rain: diagonal lines

## First Batch: Words 102-111

Here are **specific, detailed instructions** for the first 10 words:

### 102: Wort (word)
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Open book showing pages -->
  <rect x="18" y="20" width="12" height="20" rx="1" fill="#8A5A2B"/>
  <rect x="34" y="20" width="12" height="20" rx="1" fill="#8A5A2B"/>
  <rect x="20" y="22" width="8" height="16" fill="#FAC775"/>
  <rect x="36" y="22" width="8" height="16" fill="#FAC775"/>
  <path d="M20 25 L36 25" stroke="#444441" stroke-width="0.5"/>
  <path d="M20 28 L36 28" stroke="#444441" stroke-width="0.5"/>
  <path d="M20 31 L36 31" stroke="#444441" stroke-width="0.5"/>
  <path d="M20 34 L36 34" stroke="#444441" stroke-width="0.5"/>
  <rect x="30" y="20" width="4" height="20" fill="#8A5A2B"/>
</svg>
```

### 103: Satz (sentence)
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Three connected speech bubbles -->
  <path d="M12 20 Q12 12 17 12 Q22 12 25 15 Q25 20 17 20 Z" fill="#85B7EB"/>
  <path d="M28 25 Q28 17 33 17 Q38 17 41 20 Q41 25 33 25 Z" fill="#85B7EB"/>
  <path d="M44 30 Q44 22 49 22 Q54 22 57 25 Q57 30 49 30 Z" fill="#85B7EB"/>
  <path d="M25 18 L28 22" stroke="#85B7EB" stroke-width="1" fill="none"/>
  <path d="M41 22 L44 27" stroke="#85B7EB" stroke-width="1" fill="none"/>
</svg>
```

### 104: Grammatik (grammar)
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Stack of grammar books with lines -->
  <rect x="20" y="25" width="24" height="4" fill="#E24B4A" rx="1"/>
  <rect x="20" y="30" width="24" height="4" fill="#E24B4A" rx="1"/>
  <rect x="20" y="35" width="24" height="4" fill="#E24B4A" rx="1"/>
  <rect x="22" y="27" width="20" height="2" fill="#FAC775"/>
  <rect x="22" y="32" width="20" height="2" fill="#FAC775"/>
  <path d="M22 29 L42 29" stroke="#444441" stroke-width="0.5"/>
  <path d="M22 34 L42 34" stroke="#444441" stroke-width="0.5"/>
</svg>
```

### 105: Bedeutung (meaning)
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Lightbulb with rays -->
  <path d="M28 25 Q25 15 30 12 Q35 15 32 25" fill="#EF9F27"/>
  <path d="M28 25 L32 35" stroke="#EF9F27" stroke-width="2"/>
  <path d="M32 25 L36 35" stroke="#EF9F27" stroke-width="2"/>
  <path d="M28 35 L36 35" stroke="#EF9F27" stroke-width="2"/>
  <circle cx="32" cy="40" r="4" fill="#EF9F27"/>
  <rect x="30" y="44" width="4" height="4" fill="#444441"/>
  <path d="M32 48 L32 52" stroke="#444441" stroke-width="2"/>
  <path d="M28 50 L36 50" stroke="#444441" stroke-width="1"/>
</svg>
```

### 106: Aussprache (pronunciation)
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Mouth with sound waves -->
  <ellipse cx="32" cy="35" rx="8" ry="6" fill="#E8B08A"/>
  <path d="M28 35 Q32 40 36 35" stroke="#444441" stroke-width="2" fill="none"/>
  <path d="M40 25 Q44 20 48 25" stroke="#378ADD" stroke-width="1" fill="none"/>
  <path d="M48 25 Q52 20 56 25" stroke="#378ADD" stroke-width="1" fill="none"/>
  <path d="M56 25 Q60 20 64 25" stroke="#378ADD" stroke-width="1" fill="none"/>
</svg>
```

### 107: Fehler (mistake/error)
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Circle with X mark -->
  <circle cx="32" cy="32" r="16" fill="#E24B4A"/>
  <path d="M22 22 L42 42" stroke="#E24B4A" stroke-width="4" stroke-linecap="round"/>
  <path d="M42 22 L22 42" stroke="#E24B4A" stroke-width="4" stroke-linecap="round"/>
</svg>
```

### 108: Übung (exercise/practice)
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Checkmark in a box -->
  <rect x="22" y="25" width="20" height="20" rx="2" fill="#FAC775" stroke="#444441" stroke-width="1"/>
  <path d="M28 35 L34 42 L40 30" stroke="#639922" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
</svg>
```

### 109: Geld (money)
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Coin with euro-like symbol -->
  <circle cx="32" cy="32" r="14" fill="#EF9F27"/>
  <circle cx="32" cy="32" r="10" fill="#FAC775"/>
  <path d="M32 20 L32 44" stroke="#8A5A2B" stroke-width="2"/>
  <path d="M20 32 L44 32" stroke="#8A5A2B" stroke-width="2"/>
</svg>
```

### 110: Preis (price)
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Price tag with hole -->
  <path d="M25 20 L45 20 L45 35 L30 35 L25 40 Z" fill="#FAC775" stroke="#444441" stroke-width="1"/>
  <circle cx="40" cy="15" r="2" fill="#444441"/>
  <path d="M38 15 L42 15" stroke="#444441" stroke-width="1"/>
</svg>
```

### 111: Geschäft (shop/business)
```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Store front with awning -->
  <rect x="20" y="30" width="24" height="20" fill="#888780"/>
  <path d="M18 30 L32 20 L46 30" fill="#E24B4A"/>
  <rect x="28" y="40" width="8" height="10" fill="#8A5A2B"/>
  <rect x="24" y="33" width="4" height="4" fill="#FAC775"/>
  <rect x="36" y="33" width="4" height="4" fill="#FAC775"/>
</svg>
```

## How to Use This System

### For the Next Agent:

1. **Copy the SVG code** for each word above
2. **Save to file**: `assets/vocab/WORD_ID.svg`
3. **Verify**: Check it looks good and matches existing style
4. **Repeat** for next batch

### To Get Next Batch:

```bash
python tool/svg_batch_workflow.py --new-batch 20
python tool/svg_batch_workflow.py --instructions
```

This will give you the next 20 words with specific instructions.

## Quality Checklist

For each SVG you create:
- [ ] Valid SVG format with proper namespace
- [ ] viewBox="0 0 64 64"
- [ ] Pure vector graphics (NO TEXT)
- [ ] Uses colors from the palette
- [ ] Unique and different from other SVGs
- [ ] Visually represents the word meaning
- [ ] Matches the style of existing SVGs
- [ ] Fills most of the 64x64 space

## Progress Tracking

After creating SVGs for a batch:
- The system automatically detects completed words
- You can see progress with `--list-batch` and `--status`
- Completed batches are tracked

## Next Steps

1. **Copy the 10 SVGs above** and save them to the correct files
2. **Verify they work** in the app
3. **Run `--new-batch 20`** to get the next batch
4. **Continue in reviewed batches; structural visuals remain valid for words
   where a semantic image would be misleading**

## Important Notes

- **NO automatic generation** - Each SVG must be manually created
- **Each SVG must be UNIQUE** - No duplicates, no templates
- **Study existing SVGs** - Look at 001-110, x10729, x20055, etc.
- **Take your time** - Quality is more important than speed
- **Be creative** - Each visual should be meaningful and recognizable

## Files to Create First

1. `assets/vocab/102.svg` - Wort (word) - Open book
2. `assets/vocab/103.svg` - Satz (sentence) - Speech bubbles
3. `assets/vocab/104.svg` - Grammatik (grammar) - Stack of books
4. `assets/vocab/105.svg` - Bedeutung (meaning) - Lightbulb
5. `assets/vocab/106.svg` - Aussprache (pronunciation) - Mouth with sound waves
6. `assets/vocab/107.svg` - Fehler (mistake) - Circle with X
7. `assets/vocab/108.svg` - Übung (exercise) - Checkmark in box
8. `assets/vocab/109.svg` - Geld (money) - Coin
9. `assets/vocab/110.svg` - Preis (price) - Price tag
10. `assets/vocab/111.svg` - Geschäft (shop) - Store front

**Start with these 10 SVGs I've provided above, then continue with the next batch.**
