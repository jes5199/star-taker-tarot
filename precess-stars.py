"""Compute ecliptic longitudes of the 15 Behenian fixed stars for epoch 2050."""

from skyfield.api import load, Star
from skyfield.data import hipparcos

# Hipparcos catalog IDs for the 15 Behenian stars
BEHENIAN = {
    "Algol":        14576,
    "Alcyone":      17702,
    "Aldebaran":    21421,
    "Capella":      24608,
    "Sirius":       32349,
    "Procyon":      37279,
    "Regulus":      49669,
    "Alkaid":       67301,
    "Algorab":      60965,
    "Spica":        65474,
    "Arcturus":     69673,
    "Alphecca":     76267,
    "Antares":      80763,
    "Vega":         91262,
    "Deneb Algedi": 107556,
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

t = ts.tt(2050, 1, 1)

print("15 Behenian Fixed Stars — Tropical Ecliptic Longitudes (J2050.0)")
print()
print(f"{'Star':<24} {'Longitude':<24} {'HIP ID'}")
print("-" * 60)

for name, hip_id in BEHENIAN.items():
    star = Star.from_dataframe(df.loc[hip_id])
    astrometric = earth.at(t).observe(star)
    lat, lon, dist = astrometric.ecliptic_latlon(epoch='date')
    print(f"{name:<24} {lon_to_zodiac(lon.degrees):<24} HIP {hip_id}")
