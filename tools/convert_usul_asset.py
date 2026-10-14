"""Blender-side bridge to an independently installed n3ds_importer.

Run with Blender --background --factory-startup --python-exit-code 1 --python
tools/convert_usul_asset.py -- --addon /path/io_scene_n3ds --output model.glb
--report conversion.json model.bin textures.bin motions.bin

No downloaded code, console assets or decryption keys are bundled. The external
add-on is GPL-3.0-or-later: https://github.com/sxrmss/n3ds_importer
Operator contract reviewed at a68959eae2f476526845a78af6990648cfe3434d.
"""
import argparse
import hashlib
import importlib.util
import json
import pathlib
import sys


def convert(addon, inputs, output):
    import bpy

    addon = pathlib.Path(addon).resolve()
    output = pathlib.Path(output).resolve()
    inputs = [pathlib.Path(p).resolve() for p in inputs]
    if not (addon / "__init__.py").is_file():
        raise ValueError("Choisir le dossier de l'add-on n3ds_importer décompressé")
    if not inputs or any(not p.is_file() for p in inputs):
        raise ValueError("Modèle et ressources associés requis")
    if len({p.parent for p in inputs}) != 1:
        raise ValueError("Sélectionner les ressources d'un seul modèle dans le même dossier")
    if output.suffix.lower() != ".glb" or output.exists():
        raise ValueError("Nouvelle destination .glb requise ; fichier existant préservé")
    temporary = output.with_name(output.stem + ".partial.glb")
    if temporary.exists():
        raise ValueError("Export partiel existant préservé : " + str(temporary))
    name = "archelys_external_n3ds"
    spec = importlib.util.spec_from_file_location(name, addon / "__init__.py", submodule_search_locations=[str(addon)])
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    module.register()
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    result = bpy.ops.import_scene.n3ds_model(
        directory=str(inputs[0].parent) + "/",
        files=[{"name": p.name} for p in inputs],
        import_skeleton=True, import_weights=True, import_materials=True,
        import_vertex_colors=True, import_animations=True,
    )
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH" and len(o.data.polygons)]
    if "FINISHED" not in result or not meshes:
        raise ValueError("L'importateur n'a produit aucune géométrie exploitable")
    output.parent.mkdir(parents=True, exist_ok=True)
    result = bpy.ops.export_scene.gltf(filepath=str(temporary), export_format="GLB", export_animations=True, export_yup=True)
    if "FINISHED" not in result or not temporary.is_file():
        raise ValueError("Export GLB impossible")
    if output.exists():
        raise ValueError("Destination créée pendant la conversion ; export non remplacé")
    temporary.rename(output)
    return {
        "schema": 1, "status": "converted-needs-visual-review",
        "output": str(output), "sha256": hashlib.sha256(output.read_bytes()).hexdigest(),
        "meshes": len(meshes), "animations": len(bpy.data.actions),
        "source_files": [{"name": p.name, "sha256": hashlib.sha256(p.read_bytes()).hexdigest()} for p in inputs],
        "importer": "https://github.com/sxrmss/n3ds_importer",
        "limits": ["Pas de reproduction garantie des shaders PICA200", "Contrôler textures, animations, échelle et collisions", "Aucun droit de redistribution accordé"],
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--addon", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--report", required=True)
    parser.add_argument("inputs", nargs="+")
    args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:])
    report = pathlib.Path(args.report)
    if report.exists():
        raise ValueError("Rapport existant préservé")
    try:
        result = convert(args.addon, args.inputs, args.output)
    except Exception as exc:
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps({"schema": 1, "error": str(exc)}, ensure_ascii=False), encoding="utf-8")
        raise
    report.parent.mkdir(parents=True, exist_ok=True)
    report.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    print("ARCHELYS CONVERSION: " + result["status"])


if __name__ == "__main__":
    main()
