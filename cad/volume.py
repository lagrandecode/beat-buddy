"""Print volume and filament estimate for ASCII or binary STL files."""
import struct
import sys

DENSITY = {}
PLA = 1.24
INFILL_FACTOR = 0.55      # walls + 25 % infill typically uses ~55 % of the solid volume


def triangles(path):
    data = open(path, "rb").read()
    if data[:5] == b"solid" and b"facet" in data[:300]:
        verts = []
        for line in data.decode(errors="ignore").splitlines():
            parts = line.split()
            if parts[:1] == ["vertex"]:
                verts.append(tuple(map(float, parts[1:4])))
                if len(verts) == 3:
                    yield verts
                    verts = []
    else:
        n = struct.unpack("<I", data[80:84])[0]
        for i in range(n):
            v = struct.unpack("<12f", data[84 + 50 * i: 84 + 50 * i + 48])
            yield [v[3:6], v[6:9], v[9:12]]


def volume_mm3(path):
    vol = 0.0
    for (a, b, c) in triangles(path):
        vol += (a[0] * (b[1] * c[2] - b[2] * c[1]) - a[1] * (b[0] * c[2] - b[2] * c[0])
                + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6.0
    return abs(vol)


for p in sys.argv[1:]:
    v = volume_mm3(p)
    name = next((k for k in DENSITY if k in p), None)
    rho = DENSITY.get(name, PLA)
    factor = INFILL_FACTOR
    print(f"{p}: solid {v / 1000:.1f} cm³, about {v / 1000 * rho * factor:.0f} g of filament")
