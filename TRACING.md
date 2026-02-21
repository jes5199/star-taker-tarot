## Card Image Tracing Process

The B&W SVG card images are generated from color Rider-Waite-Smith scans
using potrace, with a red-channel extraction step to prevent dark-colored
areas (red robes, warm skin tones, etc.) from filling in as solid black.

### Source images

Color JPGs from Wikimedia Commons:
https://commons.wikimedia.org/wiki/Category:Rider-Waite_tarot_deck

Use the 960px thumbnails, e.g.:
https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/RWS_Tarot_04_Emperor.jpg/960px-RWS_Tarot_04_Emperor.jpg

### Pipeline

1. **Crop border** — The Wikimedia scans have a white margin and thin black
   border line. Remove with: trim white (fuzz 15%), shave 40px, trim again.

2. **Extract red channel** — Separating the red channel makes red/warm areas
   (robes, skin, hats) appear bright instead of dark, preventing them from
   thresholding into solid black blobs.

3. **Resize to 500×878** — Matches the viewBox used by all card SVGs.

4. **Threshold at 35%** — Converts to a 1-bit bitmap. 35% gives fairly thick
   lines while preserving detail.

5. **Kill edge border** — White-out 5px on all four edges of the bitmap to
   remove any residual card border that survived cropping.

6. **Trace with potrace** — `potrace -s --flat` produces a flat SVG with no
   grouping, matching the existing card format.

7. **Generate PDF** — `convert card.svg card.pdf` for LaTeX inclusion.

### Usage

    ./trace-card.sh <url-or-local-file> <output-prefix>
    ./trace-card.sh https://upload.wikimedia.org/.../RWS_Tarot_04_Emperor.jpg a-04

Output goes to `images/<prefix>.svg` and `images/<prefix>.pdf`.

### Major Arcana URLs

    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/RWS_Tarot_00_Fool.jpg/960px-RWS_Tarot_00_Fool.jpg" a-00
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/RWS_Tarot_01_Magician.jpg/960px-RWS_Tarot_01_Magician.jpg" a-01
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/RWS_Tarot_02_High_Priestess.jpg/960px-RWS_Tarot_02_High_Priestess.jpg" a-02
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/RWS_Tarot_03_Empress.jpg/960px-RWS_Tarot_03_Empress.jpg" a-03
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/RWS_Tarot_04_Emperor.jpg/960px-RWS_Tarot_04_Emperor.jpg" a-04
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/RWS_Tarot_05_Hierophant.jpg/960px-RWS_Tarot_05_Hierophant.jpg" a-05
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/RWS_Tarot_06_Lovers.jpg/960px-RWS_Tarot_06_Lovers.jpg" a-06
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9b/RWS_Tarot_07_Chariot.jpg/960px-RWS_Tarot_07_Chariot.jpg" a-07
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/RWS_Tarot_08_Strength.jpg/960px-RWS_Tarot_08_Strength.jpg" a-08
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/RWS_Tarot_09_Hermit.jpg/960px-RWS_Tarot_09_Hermit.jpg" a-09
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/RWS_Tarot_10_Wheel_of_Fortune.jpg/960px-RWS_Tarot_10_Wheel_of_Fortune.jpg" a-10
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/RWS_Tarot_11_Justice.jpg/960px-RWS_Tarot_11_Justice.jpg" a-11
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/RWS_Tarot_12_Hanged_Man.jpg/960px-RWS_Tarot_12_Hanged_Man.jpg" a-12
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/RWS_Tarot_13_Death.jpg/960px-RWS_Tarot_13_Death.jpg" a-13
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f8/RWS_Tarot_14_Temperance.jpg/960px-RWS_Tarot_14_Temperance.jpg" a-14
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/RWS_Tarot_15_Devil.jpg/960px-RWS_Tarot_15_Devil.jpg" a-15
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/RWS_Tarot_16_Tower.jpg/960px-RWS_Tarot_16_Tower.jpg" a-16
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/RWS_Tarot_17_Star.jpg/960px-RWS_Tarot_17_Star.jpg" a-17
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/RWS_Tarot_18_Moon.jpg/960px-RWS_Tarot_18_Moon.jpg" a-18
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/RWS_Tarot_19_Sun.jpg/960px-RWS_Tarot_19_Sun.jpg" a-19
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/RWS_Tarot_20_Judgement.jpg/960px-RWS_Tarot_20_Judgement.jpg" a-20
    ./trace-card.sh "https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/RWS_Tarot_21_World.jpg/960px-RWS_Tarot_21_World.jpg" a-21

### Why red channel?

A naive grayscale conversion averages R, G, B channels. Red objects (robes,
hats, skin) have low G and B values, so they average dark and threshold to
black. Extracting just the red channel makes these areas bright, preserving
the underlying line work.
