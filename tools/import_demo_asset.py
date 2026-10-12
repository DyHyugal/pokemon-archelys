#!/usr/bin/env python3
"""Inspect/stage a local self-contained GLB; never generates or downloads models."""
import argparse, hashlib, json, math, pathlib, re, shutil, struct
ROOT=pathlib.Path(__file__).resolve().parents[1]
def inspect(path):
    raw=path.read_bytes()
    if len(raw)<20 or raw[:4]!=b'glTF':raise ValueError('Expected a GLB model, not PNG/JPEG or a viewer screenshot')
    version,length=struct.unpack_from('<II',raw,4)
    if version!=2 or length!=len(raw):raise ValueError('Invalid GLB2 header/length')
    offset=12;doc=None
    while offset<len(raw):
        if offset+8>len(raw):raise ValueError('Truncated GLB chunk')
        size,kind=struct.unpack_from('<II',raw,offset);offset+=8
        if offset+size>len(raw):raise ValueError('Truncated GLB payload')
        if kind==0x4E4F534A:doc=json.loads(raw[offset:offset+size].decode().rstrip(' \0'))
        offset+=size
    if not isinstance(doc,dict) or doc.get('asset',{}).get('version')!='2.0' or not doc.get('meshes'):raise ValueError('No valid glTF2 mesh')
    for group in ['buffers','images']:
        for item in doc.get(group,[]):
            if 'uri' in item and not item['uri'].startswith('data:'):raise ValueError('Export embedded GLB textures/buffers; external resources are not staged')
    if 'KHR_draco_mesh_compression' in doc.get('extensionsRequired',[]):raise ValueError('Export uncompressed geometry for this Godot pipeline')
    accessors=doc.get('accessors',[]);triangles=0;vertices=0
    for mesh in doc['meshes']:
        for primitive in mesh.get('primitives',[]):
            position=primitive.get('attributes',{}).get('POSITION')
            if not isinstance(position,int) or not 0<=position<len(accessors):raise ValueError('Missing/invalid position accessor')
            count=int(accessors[position].get('count',0));vertices+=count
            index=primitive.get('indices')
            if index is not None:
                if not isinstance(index,int) or not 0<=index<len(accessors):raise ValueError('Invalid index accessor')
                count=int(accessors[index].get('count',0))
            mode=primitive.get('mode',4);triangles+=count//3 if mode==4 else max(0,count-2) if mode in [5,6] else 0
    return {'vertices_per_primitive':vertices,'unique_mesh_triangles':triangles,'sha256':hashlib.sha256(raw).hexdigest(),'bytes':len(raw),'meshes':len(doc['meshes']),'materials':len(doc.get('materials',[])),'images':len(doc.get('images',[])),'animations':len(doc.get('animations',[])),'skins':len(doc.get('skins',[]))}
def stage(path,asset_id,source,rights,scale,rotation,destination):
    if not re.fullmatch('[a-z][a-z0-9-]{0,63}',asset_id):raise ValueError('Use a stable lowercase asset ID')
    if not source.strip() or not rights.strip():raise ValueError('Record provenance and applicable rights')
    if not math.isfinite(scale) or not 0<scale<=100 or not math.isfinite(rotation):raise ValueError('Invalid scale/rotation')
    summary=inspect(path);registry=destination/'registry.json'
    manifest=json.loads(registry.read_text()) if registry.exists() else {'schema':1,'assets':{}}
    if manifest.get('schema')!=1 or not isinstance(manifest.get('assets'),dict):raise ValueError('Invalid existing registry; preserved')
    target=destination/(asset_id+'.glb')
    if target.exists() and hashlib.sha256(target.read_bytes()).hexdigest()!=summary['sha256']:raise ValueError('Existing different asset preserved; choose another ID or review replacement manually')
    destination.mkdir(parents=True,exist_ok=True)
    if path.resolve()!=target.resolve():shutil.copy2(path,target)
    manifest['assets'][asset_id]={'path':'res://assets/imported/'+target.name,'scale':scale,'rotation':rotation,'source':source,'rights':rights,'sha256':summary['sha256']}
    temporary=registry.with_suffix('.json.tmp');temporary.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n');temporary.replace(registry)
    return summary
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('file',type=pathlib.Path);p.add_argument('--id');p.add_argument('--source',default='');p.add_argument('--rights',default='');p.add_argument('--scale',type=float,default=1);p.add_argument('--rotation',type=float,default=0);p.add_argument('--destination',type=pathlib.Path,default=ROOT/'game/assets/imported');a=p.parse_args()
    try:result=stage(a.file,a.id,a.source,a.rights,a.scale,a.rotation,a.destination) if a.id else inspect(a.file)
    except (ValueError,OSError,json.JSONDecodeError) as e:p.exit(1,str(e)+'\n')
    print(json.dumps(result,indent=2))
