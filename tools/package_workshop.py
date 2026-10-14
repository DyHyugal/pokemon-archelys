"""Package the project-specific Godot editor, with its existing offline combat runtime."""
import argparse
import hashlib
import json
import pathlib
import subprocess
import zipfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--output", type=pathlib.Path, default=ROOT / "builds/Archelys-Atelier-Godot.zip")
args = parser.parse_args()
required = [ROOT / p for p in ["game/project.godot", "game/data/workshop/example.tscn", "builds/runtime/node.exe", "builds/showdown/upstream/dist/sim/index.js"]]
if any(not p.is_file() for p in required):
    raise SystemExit("Préparer le projet et Showdown Windows avant l'archive Atelier")
files = []
for name in ["game", "combat", "tools", "docs/licenses", "builds/showdown", "builds/runtime"]:
    for path in (ROOT / name).rglob("*"):
        if not path.is_file() or path.is_symlink(): continue
        relative = path.relative_to(ROOT)
        if any(part in [".godot", "__pycache__", "local_usul", ".archelys-local"] for part in relative.parts): continue
        if path.suffix in [".tmp", ".pyc"]: continue
        files.append(path)
for name in ["tools/convert_usul_asset.py", "tools/prepare_showdown.py", "docs/development/ATELIER_GODOT.md", "docs/development/VERIFICATION_D82.md", "docs/development/workshop/editor.png"]:
    files.append(ROOT / name)
args.output.parent.mkdir(parents=True, exist_ok=True)
prefix = "Archelys-Atelier"
commit = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
manifest = {"schema": 1, "version": "0.1.0", "commit": commit, "kind": "Godot editor project, not ROM converter", "files": {}}
with zipfile.ZipFile(args.output, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
    for path in sorted(set(files)):
        relative = path.relative_to(ROOT).as_posix()
        data = path.read_bytes()
        if relative == "game/project.godot":
            data = data.replace(b'run/main_scene="res://main.tscn"', b'run/main_scene="res://data/workshop/example.tscn"')
        manifest["files"][relative] = hashlib.sha256(data).hexdigest()
        archive.writestr(prefix + "/" + relative, data)
    guide = (ROOT / "docs/development/ATELIER_GODOT.md").read_bytes()
    archive.writestr(prefix + "/LIRE-MOI.md", guide)
    archive.writestr(prefix + "/manifest.json", json.dumps(manifest, ensure_ascii=False, indent=2))
with zipfile.ZipFile(args.output) as archive:
    if archive.testzip() is not None: raise SystemExit("Archive Atelier corrompue")
    for path, digest in manifest["files"].items():
        if hashlib.sha256(archive.read(prefix + "/" + path)).hexdigest() != digest: raise SystemExit("Empreinte Atelier incorrecte : " + path)
digest = hashlib.sha256(args.output.read_bytes()).hexdigest()
args.output.with_suffix(".sha256").write_text(digest + "  " + args.output.name + "\n")
print(json.dumps({"path": str(args.output), "bytes": args.output.stat().st_size, "sha256": digest, "files": len(manifest["files"])}))
