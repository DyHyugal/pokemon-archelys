extends "res://scripts/domain/adventure_battle.gd"
## Adventure adapter only. All battle actions/residuals/abilities resolve in Showdown.
signal changed
const Messages=preload("res://scripts/services/battle_messages.gd")
const Transport=preload("res://scripts/services/showdown_transport.gd")
var transport: Node
var busy: bool=false
var double_mode: bool=false
var sandbox: bool=false
var progression_handler: Callable
var player_slots: Array=[0,1]
var enemy_slots: Array=[0,1]
var selected_player: int=0
var selected_enemy: int=0
var queued: Dictionary={}
var request: Dictionary={}
var saved_campaign: Dictionary={}
var defeated: Array=[]
var imported: Dictionary={}
var last_error: String=""
var shift_offer: Dictionary={}
var pending_item: String=""
var history: Array=[]
func say(fr: String,en: String) -> void:
 var entry: Dictionary={"fr":fr,"en":en,"sequence":history.size(),"turn":turn}
 events.append(entry);history.append(entry.duplicate(true))
func begin(owner: RefCounted,opponents: Array,trainer_id: String="") -> bool:
 if active or owner.in_battle or opponents.is_empty() or trainer_id not in ["","trainer-1","trainer-2","weather-test","terrain-test","slice-boss","demo-trainer"]+adventure_ids():last_error="Combat déjà actif ou adversaire invalide";return false
 var ready: Array=[]
 var seen: Array=[]
 for mon: Dictionary in owner.team+opponents:
  if int(mon.uid) in seen:last_error="Identités Pokémon dupliquées";return false
  seen.append(int(mon.uid))
 for mon: Dictionary in opponents:
  if not Mon.validate(mon) or mon.hp<=0:last_error="Équipe adverse invalide";return false
 for i: int in range(owner.team.size()):
  if owner.team[i].hp>0 and owner.exploration.can_heal(owner.team[i]):ready.append(i)
 if ready.size()<(2 if double_mode else 1) or opponents.size()<(2 if double_mode else 1):last_error="Aucun Pokémon apte (ou deux Pokémon nécessaires en double)";return false
 transport=Transport.new()
 Engine.get_main_loop().root.add_child(transport)
 if not transport.start():last_error=transport.last_error;transport.queue_free();transport=null;return false
 saved_campaign=owner.snapshot();adventure=owner;enemies=opponents.duplicate(true);trainer=trainer_id
 player_index=int(ready[0]);enemy_index=0;player_slots=ready.slice(0,2);enemy_slots=[0,1]
 active=true;owner.in_battle=true;result="";turn=0;events=[];history=[];participants={current(0).uid:true};defeated=[]
 encounter_zone=owner.exploration.location;field=Field.new();request={};queued={};imported={};shift_offer={}
 transport.reply.connect(_received);transport.failed.connect(_failure)
 if trainer.is_empty() and not enemies[0].get("shiny",false) and not family_duplicate(enemies[0].species):owner.exploration.reserve_encounter(encounter_zone,int(enemies[0].uid))
 return _send({"op":"start","mode":"doubles" if double_mode else "singles","player":owner.team,"enemy":enemies,"difficulty":owner.exploration.difficulty,"battleStyle":owner.exploration.battle_style,"trainerBattle":not trainer.is_empty(),"bagHealing":owner.exploration.bag_healing})
func _send(payload: Dictionary) -> bool:
 busy=true
 if not transport.send(payload):_failure("Could not send simulator request");return false
 return true
func current(side: int) -> Dictionary:
 if double_mode:return adventure.team[int(player_slots[selected_player])] if side==0 else enemies[int(enemy_slots[selected_enemy])]
 return adventure.team[player_index] if side==0 else enemies[enemy_index]
func _active_request() -> Dictionary:
 var entries: Array=request.get("active",[])
 var slot: int=selected_player if double_mode else 0
 return entries[slot] if slot<entries.size() and entries[slot] is Dictionary else {}
func available_moves(side: int) -> Array:
 if busy:return []
 if side==1:return super.available_moves(side)
 var available: Array=[]
 var entries: Array=_active_request().get("moves",[])
 for i: int in range(entries.size()):
  if not entries[i].get("disabled",false) and int(entries[i].get("pp",1))>0:
   var request_id: String=str(entries[i].id)
   if request_id=="struggle":continue
   for j: int in range(current(0).moves.size()):
    if current(0).moves[j].id.replace("-","")==request_id:available.append(j)
 return available
func move_for(side: int,slot: int) -> Dictionary:
 var value:=super.move_for(side,slot).duplicate(true)
 if side==0:
  var target: String=""
  for entry: Dictionary in _active_request().get("moves",[]):
   if entry.id==move_id(side,slot).replace("-",""):target=entry.target
  value.target={"self":"self","allAdjacent":"all-adjacent","allAdjacentFoes":"opponents","adjacentAlly":"ally","allySide":"self","all":"self","field":"self"}.get(target,"single")
 return value
func can_mega(side: int) -> bool:
 return not busy and not mega_used[side] and (bool(_active_request().get("canMegaEvo",false)) if side==0 else false)
func valid_switch(index: Variant) -> bool:
 if busy or not Mon.integer(index,0,adventure.team.size()-1) or adventure.team[int(index)].hp<=0:return false
 if double_mode and int(index) in player_slots:return false
 if not double_mode and int(index)==player_index:return false
 if not replacement_needed() and _active_request().get("trapped",false):return false
 for command: Dictionary in queued.values():
  if command.kind=="switch" and int(command.index)==int(index):return false
 return adventure.exploration.can_heal(adventure.team[int(index)])
func valid_command(command: Dictionary) -> bool:
 if busy or not active or replacement_needed() or not shift_offer.is_empty():return false
 if command.get("kind")=="move":
  if command.get("mega",false) and not can_mega(0):return false
  if not Mon.integer(command.get("slot"),-1,3):return false
  var slot: int=int(command.slot)
  if slot==-1:return _active_request().get("moves",[]).any(func(m: Dictionary):return m.id=="struggle")
  if slot not in available_moves(0):return false
  if double_mode:
   if queued.has(selected_player):return false
   for entry: Dictionary in queued.values():
    if command.get("mega",false) and entry.get("mega",false):return false
   var target_kind: String=move_for(0,slot).get("target","single")
   if target_kind=="ally":return current(0).hp>0 and adventure.team[int(player_slots[1-selected_player])].hp>0
   if target_kind=="single":
    if not Mon.integer(command.get("target",0),0,1) or not Mon.integer(command.get("target_side",1),0,1):return false
    var side: int=int(command.get("target_side",1));var target: int=int(command.get("target",0))
    if side==0 and target==selected_player:return false
    var roster: Array=adventure.team if side==0 else enemies
    return roster[int((player_slots if side==0 else enemy_slots)[target])].hp>0
  return true
 if command.get("kind")=="switch":return valid_switch(command.get("index"))
 if double_mode:return false
 return super.valid_command(command)
func replacement_needed() -> bool:
 var force: Array=request.get("forceSwitch",[])
 return selected_player<force.size() and force[selected_player] if double_mode else (not force.is_empty() and force[0])
func _choice(command: Dictionary) -> String:
 if command.kind=="switch":
  var uid: int=int(adventure.team[int(command.index)].uid)
  for i: int in range(request.side.pokemon.size()):
   if str(request.side.pokemon[i].ident).ends_with(": "+str(uid)):return "switch %d" % (i+1)
  return ""
 var slot: int=int(command.slot)
 var moves: Array=_active_request().get("moves",[])
 var number: int=1
 for i: int in range(moves.size()):
  if moves[i].id==move_id(0,slot).replace("-",""):number=i+1;break
 var choice: String="move %d" % number
 if double_mode:
  var kind: String=move_for(0,slot).get("target","single")
  if kind=="single":choice+=" %d" % ((int(command.get("target",0))+1)*(1 if int(command.get("target_side",1))==1 else -1))
  if kind=="ally":choice+=" %d" % (-(1-selected_player+1))
 if command.get("mega",false):choice+=" mega"
 return choice
func execute(command: Dictionary) -> bool:
 if not valid_command(command):return false
 events=[]
 if command.kind=="run":say("Tu prends la fuite.","You escaped.");finish("escaped");changed.emit();return true
 if command.kind=="ball":
  if try_capture(str(command.item)):changed.emit();return true
  return _send({"op":"external"})
 if command.kind=="item":
  pending_item=str(command.item)
  return _send({"op":"external","item":command.item,"uid":int(adventure.team[int(command.index)].uid)})
 var choice:=_choice(command)
 if not double_mode:return _send({"op":"act","choice":choice})
 queued[selected_player]={"choice":choice,"kind":command.kind,"index":command.get("index",-1),"mega":command.get("mega",false)}
 for slot: int in range(2):
  if adventure.team[int(player_slots[slot])].hp>0 and not queued.has(slot):selected_player=slot;changed.emit();return true
 var choices: Array=[]
 for slot: int in range(2):choices.append(queued.get(slot,{"choice":"pass"}).choice)
 queued.clear();return _send({"op":"act","choice":", ".join(choices)})
func replace_fainted(index: int) -> bool:
 if busy or not active or not replacement_needed() or not valid_switch(index):return false
 events=[]
 if not double_mode:return _send({"op":"act","choice":_choice({"kind":"switch","index":index})})
 queued[selected_player]={"choice":_choice({"kind":"switch","index":index}),"kind":"switch","index":index}
 var force: Array=request.get("forceSwitch",[])
 for slot: int in range(force.size()):
  if force[slot] and not queued.has(slot):
   var reserve: bool=false
   for index_left: int in range(adventure.team.size()):
    if valid_switch(index_left):reserve=true;break
   if reserve:selected_player=slot;changed.emit();return true
 var choices: Array=[]
 for slot: int in range(2):choices.append(queued.get(slot,{"choice":"pass"}).choice)
 queued.clear();return _send({"op":"act","choice":", ".join(choices)})
func next_actor() -> void:
 for slot: int in range(player_slots.size()):
  if adventure.team[int(player_slots[slot])].hp>0:selected_player=slot;return
func _sync(roster: Array,rows: Array) -> void:
 for row: Dictionary in rows:
  for mon: Dictionary in roster:
   if int(mon.uid)!=int(row.uid):continue
   mon.hp=int(row.hp);mon.status=str(row.status);mon.status_turns=int(row.status_turns);mon.item=str(row.item)
   for move: Dictionary in mon.moves:
    for pp: Dictionary in row.pp:
     if move.id.replace("-","")==pp.id:move.pp=int(pp.pp)
   if row.mega:
    for form: Dictionary in Catalog.data().mega_forms.values():
     if form.base==mon.species and form.ability.replace("-","")==row.ability:mon.battle_form=form.duplicate(true)
func _position(roster: Array,uid: int) -> int:
 for i: int in range(roster.size()):
  if int(roster[i].uid)==uid:return i
 return 0
func _received(payload: Dictionary) -> void:
 busy=false
 if not active:return
 if not payload.get("ok",false):
  last_error=str(payload.get("error","Simulator error"));pending_item="";queued.clear()
  if request.is_empty():_failure(last_error);return
  say("Action refusée : "+last_error,"Action rejected: "+last_error);changed.emit();return
 if not pending_item.is_empty():adventure.bag[pending_item]-=1;pending_item=""
 last_error="";events=[];imported=payload;request=payload.request;turn=int(payload.turn)
 shift_offer=payload.shift.duplicate(true) if payload.get("shift") is Dictionary else {}
 _sync(adventure.team,payload.player);_sync(enemies,payload.enemy)
 player_slots=[];enemy_slots=[]
 for uid: Variant in payload.playerActive:player_slots.append(_position(adventure.team,int(uid)))
 for uid: Variant in payload.enemyActive:enemy_slots.append(_position(enemies,int(uid)))
 player_index=int(player_slots[0]);enemy_index=int(enemy_slots[0]);selected_player=0;selected_enemy=0
 for slot: int in range(player_slots.size()):
  participants[adventure.team[int(player_slots[slot])].uid]=true
  if request.get("forceSwitch",[]).size()>slot and request.forceSwitch[slot]:selected_player=slot;break
 for index: Variant in enemy_slots:adventure.records.observe(enemies[int(index)].species)
 mega_used=[mega_used[0] or payload.megaUsed[0],mega_used[1] or payload.megaUsed[1]]
 field.weather=payload.weather;field.weather_turns=int(payload.weatherTurns);field.terrain=payload.terrain;field.terrain_turns=int(payload.terrainTurns)
 for uid: Variant in payload.defeated:
  if int(uid) not in defeated:defeated.append(int(uid))
 for line: String in payload.logs:_event(line)
 adventure.exploration.record_deaths(adventure.team)
 if payload.ended:
  if payload.winner=="Player":finish("won")
  elif payload.winner=="Opponent":finish("lost")
  else:finish("draw")
 changed.emit()
func _event(line: String) -> void:
 var entry: Dictionary=Messages.format_line(line,adventure.team+enemies)
 if not entry.is_empty():say(entry.fr,entry.en)
func finish(outcome: String) -> void:
 if not active:return
 # Campaign progression occurs once after the battle, never changes Showdown's combat stats mid-turn.
 if outcome in ["won","escaped","lost"]:
  var previous: int=enemy_index
  for uid: int in defeated:enemy_index=_position(enemies,uid);award_experience()
  enemy_index=previous
 if outcome=="won" and trainer in ["trainer-1","trainer-2"] and not adventure.victories.has(trainer):
  adventure.victories[trainer]=true;adventure.raise_cap(18 if trainer=="trainer-1" else 36);adventure.money+=300
 if outcome=="won":adventure.journey.won(adventure,trainer);adventure.island.won(adventure,trainer)
 if outcome=="won" and progression_handler.is_valid():progression_handler.call(trainer)
 if outcome=="won":say("Victoire ! Cap actuel : %d." % adventure.cap,"Victory! Current level cap: %d." % adventure.cap)
 super.finish(outcome)
 if outcome=="lost":
  adventure.money=maxi(0,adventure.money-100);adventure.heal_team();say("Défaite : retour au Centre Pokémon.","Defeat: return to the Pokémon Center.")
 shift_offer={}
 busy=false;queued.clear()
 if transport!=null:transport.stop();transport.queue_free();transport=null
 changed.emit()
func _failure(reason: String) -> void:
 last_error=reason
 if adventure!=null:adventure.in_battle=false;adventure.restore(saved_campaign)
 active=false;busy=false;result="cancelled";events=[]
 say("Combat annulé, partie restaurée : "+reason,"Battle cancelled, campaign restored: "+reason)
 if transport!=null:transport.stop();transport.queue_free();transport=null
 changed.emit()

func choose_shift(index: int=-1) -> bool:
 if busy or not active or shift_offer.is_empty() or (index!=-1 and not valid_switch(index)):return false
 events=[]
 return _send({"op":"shift","uid":0 if index==-1 else int(adventure.team[index].uid)})

func adventure_ids() -> Array:return preload("res://scripts/domain/island.gd").BATTLES.keys()+preload("res://scripts/domain/demo_chapter.gd").IDS
