"""Compute rāśi and nakṣatra boundaries in tropical coordinates.

Uses Lahiri (Chitrapaksha) ayanamsa, defined by Spica at 0° sidereal Libra.
We derive the ayanamsa from Spica's tropical position via skyfield.
"""

from skyfield.api import load, Star
from skyfield.data import hipparcos

SIGNS = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
]

# 12 Rāśi (sidereal zodiac signs)
RASHI = [
    ("Meṣa", "मेष", "Aries", "Mars"),
    ("Vṛṣabha", "वृषभ", "Taurus", "Venus"),
    ("Mithuna", "मिथुन", "Gemini", "Mercury"),
    ("Karka", "कर्क", "Cancer", "Moon"),
    ("Siṃha", "सिंह", "Leo", "Sun"),
    ("Kanyā", "कन्या", "Virgo", "Mercury"),
    ("Tulā", "तुला", "Libra", "Venus"),
    ("Vṛścika", "वृश्चिक", "Scorpio", "Mars"),
    ("Dhanu", "धनु", "Sagittarius", "Jupiter"),
    ("Makara", "मकर", "Capricorn", "Saturn"),
    ("Kumbha", "कुम्भ", "Aquarius", "Saturn"),
    ("Mīna", "मीन", "Pisces", "Jupiter"),
]

# 27 Nakṣatras (lunar mansions)
NAKSHATRA = [
    ("Aśvinī", "अश्विनी", "Ketu", "The Physicians"),
    ("Bharaṇī", "भरणी", "Venus", "The Bearer"),
    ("Kṛttikā", "कृत्तिका", "Sun", "The Cutter"),
    ("Rohiṇī", "रोहिणी", "Moon", "The Red One"),
    ("Mṛgaśīrṣā", "मृगशीर्षा", "Mars", "The Deer's Head"),
    ("Ārdrā", "आर्द्रा", "Rahu", "The Moist One"),
    ("Punarvasu", "पुनर्वसु", "Jupiter", "The Restorer"),
    ("Puṣya", "पुष्य", "Saturn", "The Nourisher"),
    ("Āśleṣā", "आश्लेषा", "Mercury", "The Embracer"),
    ("Maghā", "मघा", "Ketu", "The Great One"),
    ("Pūrva Phālgunī", "पूर्व फाल्गुनी", "Venus", "The Former Red One"),
    ("Uttara Phālgunī", "उत्तर फाल्गुनी", "Sun", "The Latter Red One"),
    ("Hasta", "हस्त", "Moon", "The Hand"),
    ("Chitrā", "चित्रा", "Mars", "The Bright One"),
    ("Svātī", "स्वाती", "Rahu", "The Independent"),
    ("Viśākhā", "विशाखा", "Jupiter", "The Forked"),
    ("Anurādhā", "अनुराधा", "Saturn", "The Follower of Rādhā"),
    ("Jyeṣṭhā", "ज्येष्ठा", "Mercury", "The Eldest"),
    ("Mūla", "मूल", "Ketu", "The Root"),
    ("Pūrvāṣāḍhā", "पूर्वाषाढ़ा", "Venus", "The Former Invincible"),
    ("Uttarāṣāḍhā", "उत्तराषाढ़ा", "Sun", "The Latter Invincible"),
    ("Śravaṇa", "श्रवण", "Moon", "The Ear"),
    ("Dhaniṣṭhā", "धनिष्ठा", "Mars", "The Wealthiest"),
    ("Śatabhiṣā", "शतभिषा", "Rahu", "The Hundred Physicians"),
    ("Pūrva Bhādrapadā", "पूर्व भाद्रपदा", "Jupiter", "Former Lucky Feet"),
    ("Uttara Bhādrapadā", "उत्तर भाद्रपदा", "Saturn", "Latter Lucky Feet"),
    ("Revatī", "रेवती", "Mercury", "The Wealthy"),
]

RASHI_SIZE = 30.0  # degrees
NAKSHATRA_SIZE = 360.0 / 27  # 13°20' = 13.3333°


def lon_to_zodiac(lon_deg):
    """Convert ecliptic longitude in degrees to zodiac sign + degrees/minutes."""
    lon_deg = lon_deg % 360
    sign_idx = int(lon_deg // 30)
    remainder = lon_deg - sign_idx * 30
    degrees = int(remainder)
    minutes = int((remainder - degrees) * 60 + 0.5)
    if minutes == 60:
        degrees += 1
        minutes = 0
    return f"{degrees:02d}°{minutes:02d}' {SIGNS[sign_idx]}"


# Compute Lahiri ayanamsa from Spica's tropical position
SPICA_HIP = 65474

ts = load.timescale()
eph = load('de421.bsp')
earth = eph['earth']

with load.open(hipparcos.URL) as f:
    df = hipparcos.load_dataframe(f)

spica = Star.from_dataframe(df.loc[SPICA_HIP])

for year in [2024, 2030, 2050]:
    t = ts.tt(year, 1, 1)
    astrometric = earth.at(t).observe(spica)
    lat, lon, dist = astrometric.ecliptic_latlon(epoch='date')
    spica_tropical = lon.degrees
    # Lahiri: Spica = 180° sidereal, so ayanamsa = tropical - 180°
    ayanamsa = spica_tropical - 180.0

    print(f"Rāśi and Nakṣatra — Tropical Boundaries ({year})")
    print(f"Lahiri (Chitrapaksha) ayanamsa: {lon_to_zodiac(ayanamsa).split()[0]} "
          f"(Spica at {lon_to_zodiac(spica_tropical)})")
    print()

    print(f"{'RĀŚI (12 Sidereal Signs)'}")
    print(f"{'#':<4} {'Name':<14} {'Devanāgarī':<10} {'Start':<22} {'End':<22} {'Ruler'}")
    print("─" * 90)
    for i, (name, deva, western, ruler) in enumerate(RASHI):
        sid_start = i * RASHI_SIZE
        sid_end = (i + 1) * RASHI_SIZE
        trop_start = (sid_start + ayanamsa) % 360
        trop_end = (sid_end + ayanamsa) % 360
        print(f"{i+1:<4} {name:<14} {deva:<10} {lon_to_zodiac(trop_start):<22} "
              f"{lon_to_zodiac(trop_end):<22} {ruler}")

    print()
    print(f"{'NAKṢATRA (27 Lunar Mansions)'}")
    print(f"{'#':<4} {'Name':<24} {'Devanāgarī':<18} {'Start':<22} {'End':<22} {'Ruler'}")
    print("─" * 110)
    for i, (name, deva, ruler, meaning) in enumerate(NAKSHATRA):
        sid_start = i * NAKSHATRA_SIZE
        sid_end = (i + 1) * NAKSHATRA_SIZE
        trop_start = (sid_start + ayanamsa) % 360
        trop_end = (sid_end + ayanamsa) % 360
        print(f"{i+1:<4} {name:<24} {deva:<18} {lon_to_zodiac(trop_start):<22} "
              f"{lon_to_zodiac(trop_end):<22} {ruler}")

    print()
    print()
