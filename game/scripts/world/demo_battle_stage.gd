extends Node3D
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
var camera: Camera3D
var models: Array[Node3D]=[]
var species: Array[String]=["",""]
var battle: RefCounted
var last_turn: int=-1
var time: float=0
var animations: bool=true
func _ready() -> void:
 var ground:=MeshInstance3D.new();var mesh:=CylinderMesh.new();mesh.top_radius=8;mesh.bottom_radius=8;mesh.height=.12;mesh.radial_segments=64;ground.mesh=mesh;ground.position.y=-.08
 var m:=StandardMaterial3D.new();m.albedo_color=Color("8baa79");m.roughness=.92;ground.material_override=m;add_child(ground)
 for side: int in [-1,1]:
  var ring:=MeshInstance3D.new();var disk:=CylinderMesh.new();disk.top_radius=1.5;disk.bottom_radius=1.5;disk.height=.03;ring.mesh=disk;ring.position=Vector3(side*1.8,-.015,-side*1.2);ring.material_override=m;add_child(ring)
 camera=Camera3D.new();camera.position=Vector3(5,3.5,7);camera.fov=43;add_child(camera);camera.look_at(Vector3(0,.7,0));camera.current=true
 models=[Node3D.new(),Node3D.new()]
 for i: int in range(2):add_child(models[i]);models[i].position=Vector3(-1.8 if i==0 else 1.8,0,1.2 if i==0 else -1.2);models[i].rotation.y=2.16 if i==0 else -.98
func refresh() -> void:
 if not battle:return
 for i: int in range(2):
  var mon: Dictionary=battle.current(i);var id: String=mon.species
  if id!=species[i]:
   for child: Node in models[i].get_children():models[i].remove_child(child);child.queue_free()
   var path: String="res://assets/demo/pokemon-"+id+".glb"
   if ResourceLoader.exists(path):models[i].add_child(load(path).instantiate())
   else:
    # Species outside this demo's five-model roster stay explicitly identified.
    var label:=Label3D.new();label.text=Catalog.name_of(id,"fr");label.billboard=BaseMaterial3D.BILLBOARD_ENABLED;label.position.y=1;models[i].add_child(label)
   species[i]=id
  models[i].visible=int(mon.hp)>0
func _process(delta: float) -> void:
 time+=delta;refresh()
 for i: int in range(models.size()):models[i].position.y=sin(time*1.6+i)*.015 if animations else 0.0
