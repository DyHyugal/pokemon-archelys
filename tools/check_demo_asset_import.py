#!/usr/bin/env python3
import json,pathlib,tempfile
from import_demo_asset import inspect,stage,ROOT
with tempfile.TemporaryDirectory(prefix='archelys-import-') as folder:
    root=pathlib.Path(folder);model=ROOT/'game/assets/demo/shop.glb'
    assert inspect(model)['meshes']>0 and inspect(model)['unique_mesh_triangles']>0
    stage(model,'shop','Original fixture','Original test geometry',1,0,root/'imports')
    manifest=json.loads((root/'imports/registry.json').read_text());assert manifest['assets']['shop']['sha256']==inspect(model)['sha256']
    bad=root/'wrong.glb';bad.write_bytes(b'PNG image')
    for action in [lambda:inspect(bad),lambda:stage(model,'../escape','x','x',1,0,root/'imports'),lambda:stage(model,'shop','x','x',0,0,root/'imports')]:
        try:action()
        except ValueError:pass
        else:raise AssertionError('Invalid import accepted')
    assert manifest==json.loads((root/'imports/registry.json').read_text())
print('DEMO ASSET IMPORT: actual GLB/provenance staged, PNG/traversal/invalid scale rejected; originals preserved')
