"""Original DS/USUL-inspired tropical demo meshes. Blender4.3.2. No ripped assets."""
from pathlib import Path
helper=Path(__file__).with_name('create_archipelago_assets.py')
exec(helper.read_text().split('for region in PALETTES:house(region)')[0])
OUT=ROOT/'game/assets/demo';OUT.mkdir(parents=True,exist_ok=True)
SOURCES=ROOT/'art/source/demo';SOURCES.mkdir(parents=True,exist_ok=True)
manifest=[]
def tube(name,rings,m,bone=None):
 verts=[];faces=[];n=20
 for cx,cy,z,rx,ry in rings:
  for i in range(n):
   a=i*math.tau/n;verts.append((cx+math.cos(a)*rx,cy+math.sin(a)*ry,z))
 for j in range(len(rings)-1):
  for i in range(n):faces.append((j*n+i,j*n+(i+1)%n,(j+1)*n+(i+1)%n,(j+1)*n+i))
 faces.extend([tuple(range(n-1,-1,-1)),tuple((len(rings)-1)*n+i for i in range(n))])
 if rings[-1][2]<rings[0][2]:faces=[tuple(reversed(f)) for f in faces]
 o=mesh(name,verts,faces,m)
 for p in o.data.polygons:p.use_smooth=True
 if bone:bind(o,bone)
 return o
def bind(o,bone):
 group=o.vertex_groups.new(name=bone)
 lower=('Knee.'+bone[-1]) if bone.startswith('Leg.') else (('Forearm.'+bone[-1]) if bone.startswith('Arm.') else '')
 if lower:
  low=o.vertex_groups.new(name=lower);threshold=.45 if bone.startswith('Leg.') else .98
  for v in o.data.vertices:
   z=v.co.z+o.location.z;weight=max(0,min(1,(threshold+.04-z)/.08))
   group.add([v.index],1-weight,'REPLACE');low.add([v.index],weight,'REPLACE')
 else:group.add(list(range(len(o.data.vertices))),1,'REPLACE')
 mod=o.modifiers.new('Rig','ARMATURE');mod.object=rig;o.parent=rig

def actor():
 global rig
 reset();skin=mat('Skin','bc8559');shirt=mat('Shirt','397da3');pants=mat('Pants','34445b');hair=mat('Hair','302927');white=mat('White','f3eee5');red=mat('Cap','ad4d41');dark=mat('Ink','242936');blue=mat('Iris','516679')
 data=bpy.data.armatures.new('YoungTrainerRig');rig=bpy.data.objects.new('YoungTrainerRig',data);bpy.context.collection.objects.link(rig);rig.select_set(True);bpy.context.view_layer.objects.active=rig
 bpy.ops.object.mode_set(mode='EDIT')
 bones=[('Root',(0,0,0),(0,0,.2),None),('Torso',(0,0,.82),(0,0,1.34),'Root'),('Head',(0,0,1.34),(0,0,1.77),'Torso'),('Arm.L',(-.23,0,1.27),(-.27,0,.71),'Torso'),('Arm.R',(.23,0,1.27),(.27,0,.71),'Torso'),('Leg.L',(-.09,0,.85),(-.09,0,.09),'Root'),('Leg.R',(.09,0,.85),(.09,0,.09),'Root')]
 bones.extend([('Knee.L',(-.09,0,.45),(-.09,0,.10),'Leg.L'),('Knee.R',(.09,0,.45),(.09,0,.10),'Leg.R'),('Forearm.L',(-.27,0,.98),(-.27,0,.71),'Arm.L'),('Forearm.R',(.27,0,.98),(.27,0,.71),'Arm.R')])
 for name,h,t,parent in bones:
  b=data.edit_bones.new(name);b.head=h;b.tail=t
  if parent:b.parent=data.edit_bones[parent]
 bpy.ops.object.mode_set(mode='OBJECT');rig.select_set(False)
 tube('Demo_Shirt',[(0,0,.85,.148,.077),(0,0,.92,.157,.083),(0,0,1.12,.186,.094),(0,0,1.25,.22,.10),(0,0,1.31,.195,.089)],shirt,'Torso')
 tube('Demo_ShirtCollar',[(0,-.018,1.315,.105,.068),(0,-.018,1.333,.10,.061)],white,'Torso')
 bind(cylinder('Demo_SkinNeck',(0,0,1.347),.056,.13,skin),'Head')
 head=sphere('Demo_SkinHead',(0,-.01,1.555),(.182,.151,.212),skin)
 for v in head.data.vertices:
  if v.co.z<-.06:v.co.x*=max(.66,1+(v.co.z+.06)*1.9)
 bind(head,'Head')
 for side,letter in [(-1,'L'),(1,'R')]:
  tube('Demo_SkinArm'+letter,[(side*.23,0,1.27,.047,.049),(side*.267,0,1.10,.049,.046),(side*.273,-.012,.98,.043,.043),(side*.275,-.026,.81,.036,.036),(side*.272,-.02,.75,.031,.030)],skin,'Arm.'+letter)
  bind(sphere('Demo_SkinHand'+letter,(side*.274,-.02,.705),(.04,.035,.064),skin),'Arm.'+letter)
  tube('Demo_SkinLeg'+letter,[(side*.09,0,.86,.068,.069),(side*.095,0,.60,.06,.062),(side*.096,0,.42,.047,.049),(side*.095,-.005,.17,.034,.039)],skin,'Leg.'+letter)
  tube('Demo_Pants'+letter,[(side*.09,0,.87,.083,.08),(side*.09,0,.74,.083,.08),(side*.095,0,.61,.078,.077)],pants,'Leg.'+letter)
  tube('Demo_Cuff'+letter,[(side*.095,0,.61,.08,.077),(side*.095,0,.632,.08,.077)],white,'Leg.'+letter)
  bind(sphere('Demo_Shoe'+letter,(side*.094,-.034,.106),(.046,.085,.050),dark),'Leg.'+letter)
  bind(box('Demo_Sole'+letter,(side*.094,-.034,.075),(.093,.154,.021),white,.008),'Leg.'+letter)
  bind(sphere('Demo_SkinEar'+letter,(side*.177,0,1.56),(.022,.027,.039),skin),'Head')
  # Flat almond eye planes: ink border, white, iris and restrained highlight.
  x=side*.066
  for name,w,h,y,m in [('Demo_EyeOutline',.044,.034,-.150,dark),('Demo_EyeWhite',.039,.026,-.153,white)]:
   pts=[(-w,0,0),(-w*.45,0,h),(w*.45,0,h),(w,0,0),(w*.45,0,-h*.7),(-w*.45,0,-h*.7)]
   o=mesh(name+letter,pts,[tuple(range(5,-1,-1))],m);o.location=(x,y,1.57);bind(o,'Head')
  bind(sphere('Demo_EyeIris'+letter,(x,-.157,1.571),(.015,.005,.024),blue),'Head')
  bind(sphere('Demo_EyePupil'+letter,(x,-.163,1.571),(.008,.003,.017),dark),'Head')
  bind(sphere('Demo_EyeLight'+letter,(x-.005,-.166,1.582),(.004,.002,.006),white),'Head')
  bind(box('Demo_Brow'+letter,(x,-.147,1.615),(.068,.007,.009),hair,.002),'Head')
 bind(sphere('Demo_SkinNose',(0,-.154,1.522),(.012,.018,.016),skin),'Head')
 bind(box('Demo_Mouth',(0,-.148,1.477),(.046,.005,.006),mat('Mouth','76584d'),.001),'Head')
 crown=sphere('Demo_Hair',(0,.016,1.682),(.188,.151,.099),hair);bind(crown,'Head')
 for i in range(5):
  x=(i-2)*.055
  o=mesh('Demo_HairFringe'+str(i),[(x-.034,-.155,1.689),(x+.032,-.155,1.689),(x+.018,-.164,1.602)],[(0,1,2)],hair);bind(o,'Head')
 bind(sphere('Demo_LongHair',(0,.11,1.49),(.175,.056,.22),hair),'Head')
 tube('Demo_Cap',[(0,0,1.71,.202,.17),(0,0,1.77,.192,.16),(0,0,1.84,.175,.145)],red,'Head')
 tube('Demo_CapBrim',[(0,0,1.715,.238,.205),(0,0,1.733,.22,.186)],red,'Head')
 bind(box('Demo_CapBadge',(0,-.175,1.794),(.08,.007,.032),dark,.003),'Head')
 bind(sphere('Demo_Bag',(0,.123,1.08),(.115,.049,.176),mat('Bag','b79b69')),'Torso')
 for x in [-.125,.125]:bind(box('Demo_Straps',(x,-.101,1.13),(.020,.012,.285),white,.004),'Torso')
 for frame in [1,7,13,19,25]:
  phase=(frame-1)/24*math.tau
  for name,offset in [('Leg.L',0),('Leg.R',math.pi),('Arm.L',math.pi),('Arm.R',0)]:
   b=rig.pose.bones[name];b.rotation_mode='XYZ';b.rotation_euler.x=math.sin(phase+offset)*.24;b.keyframe_insert(data_path='rotation_euler',frame=frame)
  for side,offset in [('L',0),('R',math.pi)]:
   b=rig.pose.bones['Knee.'+side];b.rotation_mode='XYZ';b.rotation_euler.x=max(0,math.sin(phase+offset))*.35;b.keyframe_insert(data_path='rotation_euler',frame=frame)
 rig.animation_data.action.name='Walk';bpy.context.scene.frame_start=1;bpy.context.scene.frame_end=25;bpy.context.scene.frame_set(1)
 # Preserve named skinned parts for palette changes.
 export('trainer')

def arch(x,y,z,w,h,depth,m):
 n=18;v=[];f=[]
 for dy in [-depth/2,depth/2]:
  for r in [w/2,w/2+.18]:
   for i in range(n+1):
    a=i*math.pi/n;v.append((x+math.cos(a)*r,y+dy,z+h+math.sin(a)*r))
 s=n+1
 for i in range(n):
  f.extend([(i,i+1,s+i+1,s+i),(2*s+i,3*s+i,3*s+i+1,2*s+i+1),(i,2*s+i,2*s+i+1,i+1),(s+i,s+i+1,3*s+i+1,3*s+i)])
 mesh('ArcadeArch',v,f,m)
 for side in [-1,1]:box('ArcadeColumn',(x+side*(w/2+.09),y,z+h/2),(.18,depth,h),m,.025)

def facade(kind):
 reset();wall=mat('Stucco','e2d9b9');trim=mat('Sandstone','cbbfa2');roofmat=mat('TealTile','367e85');dark=mat('Timber','635949');glass=mat('Window','709ba7',.05)
 width=7.2 if kind=='arcade' else 5.8;depth=4.8;height=4.6 if kind=='arcade' else 3.5
 box('Building',(0,0,height/2),(width,depth,height),wall,.11)
 box('Base',(0,0,.17),(width+.25,depth+.25,.34),trim)
 for x in [-width/2+.2,width/2-.2]:box('CornerStone',(x,-depth/2-.02,height/2),(.21,.13,height),trim)
 if kind=='arcade':
  for x in [-2.5,0,2.5]:arch(x,-3.1,0,2.16,1.2,.42,trim)
  box('PorchRoof',(0,-2.88,3.0),(width+.7,1.8,.2),roofmat)
  box('BalconyRim',(0,-3.2,3.26),(width+.5,.13,.5),trim)
  for x in [-2.5,0,2.5]:box('UpperWindow',(x,-2.46,3.8),(.95,.10,1.15),glass)
 else:
  for x in [-1.9,1.9]:
   box('WindowFrame',(x,-2.46,2.0),(1.1,.13,1.22),trim)
   box('Window',(x,-2.55,2.0),(.87,.08,.98),glass)
   for side in [-1,1]:box('Shutter',(x+side*.57,-2.53,2.0),(.21,.10,1.21),roofmat)
  arch(0,-2.51,0,1.2,1.32,.13,trim)
 box('Door',(0,-2.57,1.0),(1.15,.11,1.95),dark)
 roof(width+.65,depth+.8,height,.95,roofmat)
 for i in range(9):
  x=(i-4)*.78;z=height+.95*(1-abs(x)/(width/2+.325))+.025
  box('TileBand',(x,0,z),(.06,depth+.8,.055),roofmat,.008)
 box('Step',(0,-2.82,.10),(1.9,.75,.2),trim)
 if kind=='center':
  box('CenterSign',(0,-2.6,2.6),(1.35,.07,.4),mat('Red','bb6655'))
 elif kind=='shop':
  for i in range(8):
   aw=box('CanvasAwning',((i-3.5)*.70,-3.0,2.8),(.70,1.3,.07),mat('AwningWhite','f1e9d3') if i%2==0 else mat('AwningBlue','4e9dad'));aw.rotation_euler.x=.15
 export(kind)

def clocktower():
 reset();w=mat('Stucco','ded4b3');trim=mat('Stone','baae90');teal=mat('Roof','307c85');ink=mat('Ink','4c605f')
 box('Foundation',(0,0,.2),(3,3,.4),trim)
 box('Tower',(0,0,3.6),(2.25,2.25,7.2),w,.08)
 for z in [1.2,4.7,6.7]:box('Cornice',(0,0,z),(2.5,2.5,.16),trim)
 for side in [-1,1]:box('Inset',(side*.90,-1.15,3.1),(.15,.09,5.6),trim)
 cylinder('ClockFace',(0,-1.18,5.83),.63,.05,mat('Clock','f5e9d2')).rotation_euler.x=math.pi/2
 box('Hand',(0,-1.225,6.05),(.045,.02,.42),ink,.005);box('Hand',(.17,-1.225,5.83),(.35,.02,.045),ink,.005)
 sphere('Dome',(0,0,7.3),(1.3,1.3,.9),teal);cylinder('Finial',(0,0,8.4),.10,.9,trim)
 export('clocktower')

def pokemon(id):
 reset();skin=mat('Body',{'bulbasaur':'649f96','charmander':'df9456','squirtle':'6aaabd','pikachu':'e5c34d','rattata':'997aa5'}[id]);eye=mat('Eye','29363c');white=mat('White','f2ebd8')
 if id=='bulbasaur':
  sphere('Body',(0,0,.42),(.35,.44,.26),skin);sphere('Head',(0,-.39,.62),(.38,.29,.30),skin)
  for x in [-.25,.25]:
   for y in [-.23,.27]:sphere('Foot',(x,y,.19),(.12,.12,.20),skin)
  for x in [-.25,.25]:cylinder('Ear',(x,-.4,.92),.12,.24,skin,.02)
  bulb=mat('Bulb','497858');sphere('Bulb',(0,.12,.82),(.33,.36,.32),bulb)
  for i in range(5):
   a=i*math.tau/5;o=sphere('Leaf',(math.cos(a)*.16,.12+math.sin(a)*.16,1.04),(.12,.24,.06),bulb);o.rotation_euler.z=a
  for x in [-.20,.20]:sphere('Eye',(x,-.642,.70),(.068,.024,.084),mat('Iris','934457'))
 elif id=='charmander':
  sphere('Body',(0,0,.48),(.24,.21,.34),skin);sphere('Belly',(0,-.19,.43),(.17,.04,.24),mat('Belly','e9d2a0'));sphere('Head',(0,-.03,.94),(.29,.25,.30),skin)
  for x in [-.16,.16]:sphere('Foot',(x,-.06,.15),(.12,.18,.12),skin);sphere('Arm',(x*1.65,-.01,.56),(.07,.09,.19),skin)
  tail=mesh('Tail',[(0,.16,.26),(0,.26,.21),(.10,.65,.55),(-.1,.65,.55)],[(0,1,2),(0,2,3)],skin)
  sphere('Flame',(0,.64,.62),(.09,.09,.20),mat('Fire','db7834',emit=.1))
  for x in [-.11,.11]:sphere('Eye',(x,-.255,1.0),(.049,.022,.084),eye)
 elif id=='squirtle':
  sphere('Shell',(0,.08,.49),(.34,.21,.34),mat('Shell','96714e'));sphere('Belly',(0,-.15,.49),(.26,.075,.29),mat('Belly','dbc894'));sphere('Head',(0,-.06,1.0),(.30,.27,.30),skin)
  for x in [-.23,.23]:sphere('Arm',(x,-.05,.64),(.085,.10,.20),skin);sphere('Foot',(x*.75,-.09,.17),(.13,.17,.12),skin)
  sphere('Tail',(0,.38,.31),(.14,.19,.14),skin)
  for x in [-.13,.13]:sphere('Eye',(x,-.305,1.03),(.051,.022,.082),mat('Iris','714952'))
 elif id=='pikachu':
  sphere('Body',(0,0,.48),(.25,.20,.32),skin);sphere('Head',(0,-.02,.90),(.34,.25,.28),skin)
  for side in [-1,1]:
   ear=cylinder('Ear',(side*.20,0,1.26),.069,.48,skin,.028);ear.rotation_euler.y=side*.25
   cylinder('EarTip',(side*.26,0,1.51),.03,.14,eye,.01)
   sphere('Cheek',(side*.255,-.202,.85),(.063,.02,.052),mat('Cheek','c45a42'));sphere('Foot',(side*.15,-.06,.16),(.10,.16,.1),skin)
   sphere('Eye',(side*.12,-.244,.96),(.046,.02,.057),eye)
  mesh('LightningTail',[(0,.17,.32),(.08,.31,.31),(.27,.33,.60),(.1,.38,.62),(.25,.4,.97),(.02,.45,.85),(-.1,.36,.59),(.09,.28,.57)],[(0,1,2,3,4,5,6,7)],skin)
 else:
  sphere('Body',(0,.02,.35),(.29,.36,.22),skin);sphere('Head',(0,-.30,.57),(.28,.26,.24),skin)
  for side in [-1,1]:sphere('Ear',(side*.24,-.15,.76),(.12,.055,.13),skin);sphere('Eye',(side*.14,-.50,.62),(.044,.022,.06),eye);sphere('Foot',(side*.20,-.04,.14),(.10,.13,.08),white)
  sphere('Muzzle',(0,-.55,.48),(.16,.09,.09),white);sphere('Tail',(0,.48,.40),(.043,.21,.042),mat('Tail','cdb5ad'))
 sphere('Nose',(0,-.54 if id in ['bulbasaur','rattata'] else -.285,.5 if id=='rattata' else (.65 if id=='bulbasaur' else .87)),(.027,.015,.020),eye)
 export('pokemon-'+id)
actor()
for kind in ['arcade','center','shop','villa']:facade(kind)
clocktower()
for id in ['bulbasaur','charmander','squirtle','pikachu','rattata']:pokemon(id)
for asset in manifest:asset['author']='Original geometry by tools/create_demo_assets.py';asset['license']='Original file geometry; Pokemon character designs remain respective rights holders; demo redistribution requested by owner'
(OUT/'provenance.json').write_text(json.dumps({'generator':'tools/create_demo_assets.py','blender':'4.3.2','assets':manifest},indent=2)+'\n')
