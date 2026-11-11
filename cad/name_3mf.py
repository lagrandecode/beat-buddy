"""Give the objects in an OpenSCAD 3MF readable names for the slicer: name_3mf.py file.3mf Name1 Name2 ..."""
import shutil
import sys
import zipfile

path, names = sys.argv[1], sys.argv[2:]
tmp = path + ".tmp"
with zipfile.ZipFile(path) as zin, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
    for item in zin.infolist():
        data = zin.read(item.filename)
        if item.filename.endswith(".model"):
            text = data.decode()
            for i, name in enumerate(names, start=1):
                text = text.replace(f'name="OpenSCAD Model {i}"', f'name="{name}"')
            data = text.encode()
        zout.writestr(item, data)
shutil.move(tmp, path)
