"""Run with Blender 4.3.2: original rigged mannequin for pipeline validation."""
import bpy, math, pathlib
from mathutils import Vector
root=pathlib.Path(__file__).resolve().parents[1]
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
armdata=bpy.data.armatures.new('PrototypeRig')
rig=bpy.data.objects.new('PrototypeRig',armdata);bpy.context.collection.objects.link(rig)
bpy.context.view_layer.objects.active=rig;rig.select_set(True)
bpy.ops.object.mode_set(mode='EDIT')
bones=[('Root',(0,0,0),(0,0,0.25),None),('Torso',(0,0,0.7),(0,0,1.2),'Root'),('Head',(0,0,1.2),(0,0,1.6),'Torso'),('Arm.L',(-0.3,0,1.1),(-0.3,0,0.65),'Torso'),('Arm.R',(0.3,0,1.1),(0.3,0,0.65),'Torso'),('Leg.L',(-0.13,0,0.7),(-0.13,0,0.1),'Root'),('Leg.R',(0.13,0,0.7),(0.13,0,0.1),'Root')]
for name,head,tail,parent in bones:
 b=armdata.edit_bones.new(name);b.head=head;b.tail=tail
 if parent:b.parent=armdata.edit_bones[parent]
bpy.ops.object.mode_set(mode='OBJECT');rig.select_set(False)
def material(name,color):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value=(*color,1)
 m.node_tree.nodes['Principled BSDF'].inputs['Roughness'].default_value=0.8
 return m
shirt=material('Shirt',(0.18,0.46,0.64));skin=material('Skin',(0.76,0.56,0.39));pants=material('Pants',(0.15,0.18,0.23))
parts=[('Torso',(0,0,0.95),(0.5,0.28,0.5),shirt),('Head',(0,0,1.42),(0.36,0.34,0.4),skin),('Arm.L',(-0.33,0,0.9),(0.15,0.17,0.5),skin),('Arm.R',(0.33,0,0.9),(0.15,0.17,0.5),skin),('Leg.L',(-0.13,0,0.38),(0.21,0.23,0.65),pants),('Leg.R',(0.13,0,0.38),(0.21,0.23,0.65),pants)]
for bone,pos,size,mat in parts:
 bpy.ops.mesh.primitive_cube_add(size=1,location=pos)
 obj=bpy.context.object;obj.name='Mannequin_'+bone;obj.dimensions=size
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 obj.data.materials.append(mat)
 group=obj.vertex_groups.new(name=bone);group.add(list(range(len(obj.data.vertices))),1.0,'REPLACE')
 mod=obj.modifiers.new('Rig','ARMATURE');mod.object=rig;obj.parent=rig
for frame in [1,7,13,19,25]:
 phase=(frame-1)/24*math.tau
 for name,offset in [('Leg.L',0),('Leg.R',math.pi),('Arm.L',math.pi),('Arm.R',0)]:
  bone=rig.pose.bones[name];bone.rotation_mode='XYZ';bone.rotation_euler.x=math.sin(phase+offset)*0.35
  bone.keyframe_insert(data_path='rotation_euler',frame=frame)
rig.animation_data.action.name='Walk_Prototype'
bpy.context.scene.frame_start=1;bpy.context.scene.frame_end=25;bpy.context.scene.frame_set(1)
out=root/'game/assets/prototypes/mannequin.glb'
bpy.ops.export_scene.gltf(filepath=str(out),export_format='GLB',export_animations=True,export_cameras=False,export_lights=False)
print('Original mannequin exported:',out)
