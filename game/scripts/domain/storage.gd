extends RefCounted
## Stable slots are separate from individual data and party order.
const Mon=preload("res://scripts/domain/pokemon.gd")
const BOX_COUNT=8
const BOX_SIZE=30
const CAPACITY=BOX_COUNT*BOX_SIZE
static func valid(layout: Variant,boxed: Array) -> bool:
 if not layout is Dictionary or layout.size()!=boxed.size():return false
 var slots: Array=[]
 for mon: Dictionary in boxed:
  var key: String=str(int(mon.uid))
  if not Mon.integer(layout.get(key),0,CAPACITY-1) or int(layout[key]) in slots:return false
  slots.append(int(layout[key]))
 return true
static func reconcile(boxed: Array,current: Dictionary) -> Dictionary:
 var result: Dictionary={};var used: Array=[]
 for mon: Dictionary in boxed:
  var key: String=str(int(mon.uid));var slot: Variant=current.get(key)
  if Mon.integer(slot,0,CAPACITY-1) and int(slot) not in used:result[key]=int(slot);used.append(int(slot))
 for mon: Dictionary in boxed:
  var key: String=str(int(mon.uid))
  if not result.has(key):
   for slot: int in range(CAPACITY):
    if slot not in used:result[key]=slot;used.append(slot);break
 return result
static func first_free(layout: Dictionary) -> int:
 for slot: int in range(CAPACITY):
  if slot not in layout.values():return slot
 return -1
static func uid_at(layout: Dictionary,slot: int) -> int:
 for key: String in layout:
  if int(layout[key])==slot:return int(key)
 return 0
