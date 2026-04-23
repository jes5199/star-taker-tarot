# Hexagram Breath

Two layered hexagram cycles on the deck:

1. **月體納甲火候** (yuètǐ nàjiǎ huǒhòu) — lunar-body nàjiǎ fire-times. Drives the 16 **court cards**.
2. **孟喜卦氣** (Mèng Xǐ guàqì), a.k.a. **六日七分** (liù rì qī fēn) — Meng Xi's "six days seven parts". Drives the 36 **pip/decan cards**.

Both use 60 + 4 hexagrams but they are layered, not collapsed. Different omitted quartets, different timescales, different orderings.

Primary source: 周易參同契 (Wei Boyang, *Cantong Qi*). Later: 悟真篇 (Zhang Boduan, *Wuzhen Pian*); Jindan alchemical corpus.

---

## 1. 月體納甲火候 — Lunar Hexagram Breath (court cards)

### Cycle rule

- Start from King Wen 1–64.
- Remove the four axial-cosmological hexagrams: **Qián (1), Kūn (2), Kǎn (29), Lí (30)**.
- Remaining 60 hexagrams pair into 30 days, morning (朝 zhāo) + evening (暮 mù).

### Day-N formula

Let KW(n) be the n-th hexagram of King Wen, skipping 1, 2, 29, 30. So KW → (3, 4, 5, 6, …, 28, 31, 32, 33, …, 64).

- Day N morning = KW(2N − 1)
- Day N evening = KW(2N)

### 進火 / 退符 framing

- 進火 (jìnhuǒ) — advancing the fire, yang work, days 1–15 (waxing half).
- 退符 (tuìfú) — withdrawing the tally, yin work, days 16–30 (waning half).
- The per-day morning/evening split is *also* yang/yin: morning = advance, evening = withdraw. The two framings nest — macro-waxing vs. micro-daily.

### Moon phase → court card mapping

Each court card has a `\drawmoonphase{...}{...}{phase}` tag at `(cardwidth-5mm, cardheight-6mm)`. Phases 0-15.

| Phase | Card | Days | Hexagrams |
|-------|------|------|-----------|
| 0 | Knight of Pentacles | 30 (singleton) | 63 Jì Jì / 64 Wèi Jì |
| 1 | Page of Pentacles | 1 + 2 | 3, 4, 5, 6 |
| 2 | Page of Swords | 3 + 4 | 7, 8, 9, 10 |
| 3 | King of Swords | 5 + 6 | 11, 12, 13, 14 |
| 4 | Queen of Pentacles | 7 + 8 | 15, 16, 17, 18 |
| 5 | King of Cups | 9 + 10 | 19, 20, 21, 22 |
| 6 | Queen of Cups | 11 + 12 | 23, 24, 25, 26 |
| 7 | Page of Cups | 13 + 14 | 27, 28, 31, 32 |
| 8 | Page of Wands | 15 (singleton) | 33 Dùn / 34 Dà Zhuàng |
| 9 | Knight of Cups | 16 + 17 | 35, 36, 37, 38 |
| 10 | Queen of Swords | 18 + 19 | 39, 40, 41, 42 |
| 11 | Queen of Wands | 20 + 21 | 43, 44, 45, 46 |
| 12 | Knight of Wands | 22 + 23 | 47, 48, 49, 50 |
| 13 | Knight of Swords | 24 + 25 | 51, 52, 53, 54 |
| 14 | King of Wands | 26 + 27 | 55, 56, 57, 58 |
| 15 | King of Pentacles | 28 + 29 | 59, 60, 61, 62 |

Phases 0 and 8 are **singletons** (new moon / full moon). They render two hexagrams in Knight-of-Pentacles right-side layout (y = 60mm upper / y = 38mm lower), not a bottom row of four. Upper = morning/filled/朝, lower = evening/outlined/暮.

Phases 1-7 and 9-15 render a **bottom row of four** hexagrams at shifts (18mm, 26mm, 34mm, 42mm) × 7mm. Order left-to-right: Day A morning, Day A evening, Day B morning, Day B evening. Morning = filled/朝. Evening = outlined/暮.

### Full 30-day listing

| Day | Morning (朝, filled) | Evening (暮, outlined) |
|-----|--------------------|-----------------------|
| 1 | 3 Zhūn | 4 Méng |
| 2 | 5 Xū | 6 Sòng |
| 3 | 7 Shī | 8 Bǐ |
| 4 | 9 Xiǎo Chù | 10 Lǚ (Treading) |
| 5 | 11 Tài | 12 Pǐ |
| 6 | 13 Tóng Rén | 14 Dà Yǒu |
| 7 | 15 Qiān | 16 Yù |
| 8 | 17 Suí | 18 Gǔ |
| 9 | 19 Lín | 20 Guān |
| 10 | 21 Shì Kè | 22 Bì |
| 11 | 23 Bō | 24 Fù |
| 12 | 25 Wú Wàng | 26 Dà Chù |
| 13 | 27 Yí | 28 Dà Guò |
| 14 | 31 Xián | 32 Héng |
| 15 | 33 Dùn | 34 Dàzhuàng |
| 16 | 35 Jìn | 36 Míng Yí |
| 17 | 37 Jiā Rén | 38 Kuí |
| 18 | 39 Jiǎn | 40 Jiě |
| 19 | 41 Sǔn | 42 Yì |
| 20 | 43 Guài | 44 Gòu |
| 21 | 45 Cuì | 46 Shēng |
| 22 | 47 Kùn | 48 Jǐng |
| 23 | 49 Gé | 50 Dǐng |
| 24 | 51 Zhèn | 52 Gèn |
| 25 | 53 Jiàn | 54 Guī Mèi |
| 26 | 55 Fēng | 56 Lǚ (Wanderer) |
| 27 | 57 Xùn | 58 Duì |
| 28 | 59 Huàn | 60 Jié |
| 29 | 61 Zhōng Fú | 62 Xiǎo Guò |
| 30 | 63 Jì Jì | 64 Wèi Jì |

Note the two Lǚ hexagrams: hex 10 (履, Treading) and hex 56 (旅, Wanderer). Same pinyin, different characters, different hexagrams.

### Related terminology

- 火候 (huǒhòu) — "fire times", the general neidan schedule.
- 月體納甲 (yuètǐ nàjiǎ) — the broader framework of trigram/hexagram↔moon correspondence.
- 卦氣 (guàqì) — umbrella for hexagram↔time mappings. The 60-hex huǒhòu is one instance; Meng Xi's system (§2 below) is another.
- 六十卦火候 (liùshí guà huǒhòu) — literal "sixty-hexagram fire-times".

---

## 2. 孟喜卦氣 / 六日七分 — Meng Xi's guàqì (pip / decan cards)

### Cycle rule

- Start from King Wen 1-64.
- Remove the four cardinal-direction hexagrams: **Kǎn (29), Zhèn (51), Lí (30), Duì (58)** — 四正卦 (sì zhèng guà), the seasonal axes.
- Each of the four reserved hexagrams' six lines map to six 節氣 (solar terms). 4 × 6 = 24, matching the full solar-term cycle.
- Remaining 60 hexagrams distribute around the 365.25-day solar year. Each receives 6 + 7/80 days (dividing one day into 80 分 fēn — hence **六日七分**).

### Attribution

- 孟喜 (Meng Xi), Western Han. Elaborated by 京房 (Jing Fang).
- 辟卦 (bìguà) layer = 12 sovereign / monthly pivot hexagrams.
- Full five-rank hierarchy per month: 公 gōng, 辟 bì, 侯 hóu, 大夫 dàfū, 卿 qīng.

### Contrasts with huǒhòu

| | 月體納甲火候 | 孟喜卦氣 |
|---|---|---|
| Timescale | lunation (30 days) | solar year (365.25 days) |
| Reserved quartet | Qián, Kūn, Kǎn, Lí (axial-cosmological) | Kǎn, Zhèn, Lí, Duì (cardinal-directional) |
| Order | King Wen minus 4 | Meng Xi's own sequence around the ecliptic |
| Cards | court (16) | pip / decan (36, 10-per-suit minus aces count matters here — see pip cards) |

### Pip-card assignment

Pending — pip cards will eventually be mapped under guàqì / 六日七分. See pip-card sources (existing `\hexagram{...}` calls already attach hexagrams to decans; this section documents the framework rather than re-deriving the assignment).
