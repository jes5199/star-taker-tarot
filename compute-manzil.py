"""Compute the 28 lunar mansions (manāzil) in tropical coordinates.

Uses equal-sized sidereal divisions (360°/28 = 12°51'26" each),
with Fagan-Allen ayanamsa. Reference: 25°00' in 2019.
Source: https://shulyrose.com/a-technical-guide-to-the-sidereal-manzil
"""

SIGNS = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
]

# 28 manāzil with Arabic transliteration and English meaning
MANZIL = [
    ("Sharaṭayn · Naṭḥ", "الشرطين", "The Two Signs"),
    ("Buṭayn", "البطين", "The Little Belly"),
    ("Thurayyā", "الثريا", "The Pleiades"),
    ("Dabarān", "الدبران", "The Follower"),
    ("Haqʿa", "الهقعة", "The Circle"),
    ("Hanʿa", "الهنعة", "The Brand"),
    ("Dhirāʿ", "الذراع", "The Forearm"),
    ("Nathra", "النثرة", "The Gap"),
    ("Ṭarf", "الطرف", "The Glance"),
    ("Jabha", "الجبهة", "The Forehead"),
    ("Zubra · Kharātān", "الزبرة", "The Mane"),
    ("Ṣarfa", "الصرفة", "The Changer"),
    ("ʿAwwāʾ · Zāwiya", "العواء", "The Howler"),
    ("Simāk al-Aʿzal", "السماك الأعزل", "The Unarmed"),
    ("Ghafr", "الغفر", "The Cover"),
    ("Zubānā", "الزبانى", "The Claws"),
    ("Iklīl", "الإكليل", "The Crown"),
    ("Qalb", "القلب", "The Heart"),
    ("Shawla", "الشولة", "The Raised Tail"),
    ("Naʿāʾim", "النعائم", "The Ostriches"),
    ("Balda", "البلدة", "The Empty Place"),
    ("Saʿd al-Dhābiḥ", "سعد الذابح", "The Slaughterer"),
    ("Saʿd Bulaʿ", "سعد بلع", "The Swallower"),
    ("Saʿd al-Suʿūd", "سعد السعود", "Luckiest of the Lucky"),
    ("Saʿd al-Akhbiya", "سعد الأخبية", "The Tents"),
    ("Fargh al-Muqaddam", "الفرغ المقدم", "The Former Spout"),
    ("Fargh al-Muʾakhkhar", "الفرغ المؤخر", "The Latter Spout"),
    ("Rishāʾ · Baṭn al-Ḥūt", "بطن الحوت", "Belly of the Fish"),
]

# Fagan-Allen ayanamsa: 25°00'00" in 2019
# Precession rate: ~50.29" per year
AYANAMSA_2019 = 25.0  # degrees
PRECESSION_RATE = 50.29 / 3600  # degrees per year

MANSION_SIZE = 360.0 / 28  # 12.857142857°


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


for year in [2024, 2030, 2050]:
    years_from_2019 = year - 2019
    ayanamsa = AYANAMSA_2019 + years_from_2019 * PRECESSION_RATE

    print(f"28 Lunar Mansions (Manāzil) — Tropical Boundaries ({year})")
    print(f"Fagan-Allen ayanamsa: {lon_to_zodiac(ayanamsa).replace(SIGNS[0], '').strip()}")
    print()
    print(f"{'#':<4} {'Name':<26} {'Start':<22} {'End':<22} {'Meaning'}")
    print("─" * 100)

    for i, (name, arabic, meaning) in enumerate(MANZIL):
        sid_start = i * MANSION_SIZE
        sid_end = (i + 1) * MANSION_SIZE
        trop_start = (sid_start + ayanamsa) % 360
        trop_end = (sid_end + ayanamsa) % 360
        print(f"{i+1:<4} {name:<26} {lon_to_zodiac(trop_start):<22} {lon_to_zodiac(trop_end):<22} {meaning}")

    print()
    print()
