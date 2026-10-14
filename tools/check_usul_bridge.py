"""Exercise the real Blender process/export bridge with a synthetic importer.

This validates orchestration, NOT compatibility with actual USUL resources or
the third-party n3ds importer. No official content is used.
"""
import argparse
import hashlib
import json
import pathlib
import subprocess
import tempfile
from import_demo_asset import inspect

parser = argparse.ArgumentParser()
parser.add_argument("--blender", default="blender")
args = parser.parse_args()
bridge = pathlib.Path(__file__).with_name("convert_usul_asset.py").resolve()
addon_source = '''
import bpy
from bpy.props import CollectionProperty, StringProperty, BoolProperty
class SyntheticImport(bpy.types.Operator):
    bl_idname = "import_scene.n3ds_model"
    bl_label = "Synthetic bridge fixture - not a console reader"
    files: CollectionProperty(type=bpy.types.OperatorFileListElement)
    directory: StringProperty()
    import_skeleton: BoolProperty()
    import_weights: BoolProperty()
    import_materials: BoolProperty()
    import_vertex_colors: BoolProperty()
    import_animations: BoolProperty()
    def execute(self, context):
        if self.files[0].name == "invalid.bin": return {"CANCELLED"}
        mesh = bpy.data.meshes.new("fixture")
        mesh.from_pydata([(0,0,0),(1,0,0),(0,1,0)],[],[(0,1,2)])
        obj = bpy.data.objects.new("fixture",mesh)
        context.collection.objects.link(obj)
        return {"FINISHED"}
def register(): bpy.utils.register_class(SyntheticImport)
'''
with tempfile.TemporaryDirectory(prefix="archelys-bridge-") as folder:
    root = pathlib.Path(folder)
    addon = root / "fixture_addon"; addon.mkdir()
    (addon / "__init__.py").write_text(addon_source)
    valid = root / "model.bin"; valid.write_bytes(b"synthetic-fixture")
    invalid = root / "invalid.bin"; invalid.write_bytes(b"invalid")
    output = root / "model.glb"
    def run(source, target, report):
        return subprocess.run([args.blender, "--background", "--factory-startup", "--python-exit-code", "1", "--python", str(bridge), "--", "--addon", str(addon), "--output", str(target), "--report", str(report), str(source)], capture_output=True, text=True, timeout=90)
    report = root / "success.json"
    result = run(valid, output, report)
    assert result.returncode == 0, result.stdout + result.stderr
    assert inspect(output)["unique_mesh_triangles"] == 1
    assert json.loads(report.read_text())["status"] == "converted-needs-visual-review"
    digest = hashlib.sha256(output.read_bytes()).hexdigest()
    result = run(valid, output, root / "preserve.json")
    assert result.returncode != 0 and hashlib.sha256(output.read_bytes()).hexdigest() == digest
    result = run(invalid, root / "bad.glb", root / "failure.json")
    assert result.returncode != 0 and not (root / "bad.glb").exists()
    assert "error" in json.loads((root / "failure.json").read_text())
print("USUL BRIDGE CONTRACT: export GLB, provenance, refusal and preservation passed (synthetic importer only)")
