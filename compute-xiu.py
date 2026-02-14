"""Compute xiù boundaries by projecting determinative stars' hour circles onto the ecliptic.

Method: for each star, intersect its hour circle (the great-circle meridian
at α = α★) with the ecliptic plane.  The intersection longitude is:

    λ_boundary = atan2(sin α★ · cos ε, cos α★)

where ε is the obliquity of the ecliptic.  This gives the exact ecliptic
longitude where the mansion boundary crosses the ecliptic (β = 0).
"""

import math
from skyfield.api import load, Star
from skyfield.data import hipparcos

# 28 xiù determinative stars in traditional order
XIU = [
    # Eastern Azure Dragon 東方青龍
    (1,  "角", "Jiǎo",  "Horn",             "Spica",           65474),   # α Virginis
    (2,  "亢", "Kàng",  "Neck",             "Kang",            69427),   # κ Virginis
    (3,  "氐", "Dǐ",    "Root",             "Zubenelgenubi",   72622),   # α Librae
    (4,  "房", "Fáng",  "Room",             "Fang",            78265),   # π Scorpii
    (5,  "心", "Xīn",   "Heart",            "Alniyat",         80112),   # σ Scorpii
    (6,  "尾", "Wěi",   "Tail",             "Xamidimura",      82514),   # μ¹ Scorpii
    (7,  "箕", "Jī",    "Winnowing Basket", "Alnasl",          88635),   # γ² Sagittarii
    # Northern Black Tortoise 北方玄武
    (8,  "斗", "Dǒu",   "Southern Dipper",  "Phi Sagittarii",  92041),   # φ Sagittarii
    (9,  "牛", "Niú",   "Ox",               "Dabih",           100345),  # β¹ Capricorni
    (10, "女", "Nǚ",    "Girl",             "Albali",          102618),  # ε Aquarii
    (11, "虛", "Xū",    "Emptiness",        "Sadalsuud",       106278),  # β Aquarii
    (12, "危", "Wēi",   "Rooftop",          "Sadalmelik",      109074),  # α Aquarii
    (13, "室", "Shì",   "Encampment",       "Markab",          113963),  # α Pegasi
    (14, "壁", "Bì",    "Wall",             "Algenib",         1067),    # γ Pegasi
    # Western White Tiger 西方白虎
    (15, "奎", "Kuí",   "Legs",             "Eta Andromedae",  4463),    # η Andromedae
    (16, "婁", "Lóu",   "Bond",             "Sheratan",        8903),    # β Arietis
    (17, "胃", "Wèi",   "Stomach",          "35 Arietis",      12719),   # 35 Arietis
    (18, "昴", "Mǎo",   "Hairy Head",       "Electra",         17499),   # 17 Tauri
    (19, "畢", "Bì",    "Net",              "Ain",             20889),   # ε Tauri
    (20, "觜", "Zī",    "Turtle Beak",      "Meissa",          26207),   # λ Orionis
    (21, "參", "Shēn",  "Three Stars",      "Alnitak",         26727),   # ζ Orionis
    # Southern Vermilion Bird 南方朱雀
    (22, "井", "Jǐng",  "Well",             "Tejat",           30343),   # μ Geminorum
    (23, "鬼", "Guǐ",   "Ghost",            "Theta Cancri",    41822),   # θ Cancri
    (24, "柳", "Liǔ",   "Willow",           "Delta Hydrae",    42313),   # δ Hydrae
    (25, "星", "Xīng",  "Star",             "Alphard",         46390),   # α Hydrae
    (26, "張", "Zhāng", "Extended Net",     "Upsilon-1 Hydrae",48356),   # υ¹ Hydrae
    (27, "翼", "Yì",    "Wings",            "Alkes",           53740),   # α Crateris
    (28, "軫", "Zhěn",  "Chariot",          "Gienah",          59803),   # γ Corvi
]

SIGNS = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
]

ANIMALS = [
    (1, 7,   "Eastern Azure Dragon 東方青龍 (Spring)"),
    (8, 14,  "Northern Black Tortoise 北方玄武 (Winter)"),
    (15, 21, "Western White Tiger 西方白虎 (Autumn)"),
    (22, 28, "Southern Vermilion Bird 南方朱雀 (Summer)"),
]


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


def hour_circle_ecliptic_longitude(ra_rad, obliquity_rad):
    """Project a star's hour circle onto the ecliptic.

    λ = atan2(sin α · cos ε, cos α)
    """
    lam = math.atan2(math.sin(ra_rad) * math.cos(obliquity_rad),
                     math.cos(ra_rad))
    lam_deg = math.degrees(lam)
    if lam_deg < 0:
        lam_deg += 360
    return lam_deg


# Load ephemeris and Hipparcos data
ts = load.timescale()
eph = load('de421.bsp')
earth = eph['earth']

with load.open(hipparcos.URL) as f:
    df = hipparcos.load_dataframe(f)

for year in [2030]:
    t = ts.tt(year, 1, 1)

    # Get obliquity of the ecliptic
    # Skyfield doesn't directly expose obliquity, but we can compute it
    # from the frame rotation.  Alternatively, use the IAU formula.
    # Mean obliquity (IAU 2006): ε = 23°26'21.448" - 46.8150"·T - ...
    # T = centuries from J2000.0
    T = (t.tdb - 2451545.0) / 36525.0
    eps_arcsec = (84381.448 - 46.8150 * T - 0.00059 * T**2 + 0.001813 * T**3)
    obliquity_deg = eps_arcsec / 3600.0
    obliquity_rad = math.radians(obliquity_deg)

    # Also compute direct ecliptic longitudes for comparison
    results = []
    for num, hanzi, pinyin, name, star_name, hip_id in XIU:
        star = Star.from_dataframe(df.loc[hip_id])
        astrometric = earth.at(t).observe(star)

        # Get RA (equatorial)
        ra, dec, dist = astrometric.radec(epoch='date')
        ra_rad = ra.radians

        # Hour-circle projection onto ecliptic
        lam_proj = hour_circle_ecliptic_longitude(ra_rad, obliquity_rad)

        # Direct ecliptic longitude for comparison
        lat, lon, dist2 = astrometric.ecliptic_latlon(epoch='date')
        lam_direct = lon.degrees

        results.append((num, hanzi, pinyin, name, star_name, hip_id,
                         lam_proj, lam_direct))

    # Compute spans
    for i, r in enumerate(results):
        next_r = results[(i + 1) % 28]
        span = (next_r[6] - r[6]) % 360
        results[i] = r + (span,)

    # Print
    print(f"二十八宿 — 28 Xiù (Chinese Lunar Mansions) — Hour-Circle Projection ({year})")
    print()
    print("Boundaries defined by projecting each determinative star's hour circle")
    print("onto the ecliptic: λ = atan2(sin α★ · cos ε, cos α★)")
    print(f"Obliquity ε = {obliquity_deg:.4f}° ({int(obliquity_deg)}°"
          f"{int((obliquity_deg % 1) * 60):02d}'"
          f"{((obliquity_deg % 1) * 60 % 1) * 60:04.1f}\")")
    print(f"Positions computed via skyfield (Hipparcos + DE421).")
    print()

    current_animal = 0
    for r in results:
        num, hanzi, pinyin, name, star_name, hip_id, lam_proj, lam_direct, span = r

        # Print animal header
        for a_start, a_end, a_title in ANIMALS:
            if num == a_start:
                print(a_title)
                print("─" * 89)
                print(f"{'#':<4} {'Xiù':<8} {'Name':<20} {'Determinative Star':<28} "
                      f"{'Projected':<20} {'Span'}")
                break

        proj_str = lon_to_zodiac(lam_proj)
        direct_str = lon_to_zodiac(lam_direct)
        span_d = int(span)
        span_m = int((span - span_d) * 60 + 0.5)

        print(f"{num:<4} {hanzi} {pinyin:<6} {name:<20} {star_name:<28} "
              f"{proj_str:<20} {span_d:02d}°{span_m:02d}'")

        # Print separator after each animal group
        for a_start, a_end, a_title in ANIMALS:
            if num == a_end:
                print()
                break

    # Comparison table
    print()
    print("Comparison: hour-circle projection vs. direct ecliptic longitude")
    print("─" * 80)
    print(f"{'#':<4} {'Xiù':<8} {'Projected':<22} {'Direct ecl. lon.':<22} {'Δ'}")
    print("─" * 80)
    for r in results:
        num, hanzi, pinyin, name, star_name, hip_id, lam_proj, lam_direct, span = r
        delta = lam_proj - lam_direct
        if delta > 180:
            delta -= 360
        if delta < -180:
            delta += 360
        print(f"{num:<4} {hanzi} {pinyin:<6} {lon_to_zodiac(lam_proj):<22} "
              f"{lon_to_zodiac(lam_direct):<22} {delta:+.2f}°")
    print()
