"""Compute ecliptic longitudes of astrologically significant fixed stars."""

from skyfield.api import load, Star
from skyfield.data import hipparcos

# Hipparcos catalog IDs
STARS = {
    # 15 Behenian stars
    "Algol":            14576,
    "Alcyone":          17702,
    "Aldebaran":        21421,
    "Capella":          24608,
    "Sirius":           32349,
    "Procyon":          37279,
    "Regulus":          49669,
    "Alkaid":           67301,
    "Algorab":          60965,
    "Spica":            65474,
    "Arcturus":         69673,
    "Alphecca":         76267,
    "Antares":          80763,
    "Vega":             91262,
    "Deneb Algedi":     107556,
    # Royal star
    "Fomalhaut":        113368,
    # Orion
    "Betelgeuse":       27989,
    "Rigel":            24436,
    "Bellatrix":        25336,
    # Gemini
    "Castor":           36850,
    "Pollux":           37826,
    # Bright / navigational
    "Canopus":          30438,
    "Altair":           97649,
    "Deneb":            102098,
    "Polaris":          11767,
    "Achernar":         7588,
    # Astrologically active
    "Hamal":            9884,
    "Zubenelgenubi":    72622,
    "Scheat":           113881,
    "Vindemiatrix":     63608,
    "Toliman":          71683,
    # Requested
    "Sadalsuud":        106278,
    "Rasalhague":       86032,
}

SIGNS = [
    "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
    "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
]

def lon_to_zodiac(lon_deg):
    """Convert ecliptic longitude in degrees to zodiac sign + degrees/minutes."""
    sign_idx = int(lon_deg // 30)
    remainder = lon_deg - sign_idx * 30
    degrees = int(remainder)
    minutes = int((remainder - degrees) * 60 + 0.5)
    if minutes == 60:
        degrees += 1
        minutes = 0
    return f"{degrees:02d}°{minutes:02d}' {SIGNS[sign_idx]}"

# Load ephemeris and Hipparcos data
ts = load.timescale()
eph = load('de421.bsp')
earth = eph['earth']

with load.open(hipparcos.URL) as f:
    df = hipparcos.load_dataframe(f)

for year in [2024, 2050]:
    t = ts.tt(year, 1, 1)
    print(f"Fixed Stars — Tropical Ecliptic Longitudes ({year})")
    print()
    print(f"{'Star':<24} {'Longitude':<24} {'HIP ID'}")
    print("-" * 60)

    for name, hip_id in STARS.items():
        star = Star.from_dataframe(df.loc[hip_id])
        astrometric = earth.at(t).observe(star)
        lat, lon, dist = astrometric.ecliptic_latlon(epoch='date')
        print(f"{name:<24} {lon_to_zodiac(lon.degrees):<24} HIP {hip_id}")

    print()
    print()
