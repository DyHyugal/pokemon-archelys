extends CanvasLayer
signal finished(result: String)
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
var comfort: RefCounted
var battle: RefCounted
var locale: String="fr"
var cards: Label
var message: Label
var actions: VBoxContainer
var mega_selected: bool=false
var event_index: int=0
var choice_page: String="main"
var journal_open: bool=false
var journal_page: int=0
var move_details: bool=false
var panel: PanelContainer
func _ready() -> void:
	layer=12
	var shade:=ColorRect.new();shade.color=Color("142b3e");shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(shade)
	panel=PanelContainer.new();panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);panel.offset_left=110;panel.offset_top=35;panel.offset_right=-110;panel.offset_bottom=-35;add_child(panel)
	var margin:=MarginContainer.new()
	for side: String in ["left","right","top","bottom"]:margin.add_theme_constant_override("margin_"+side,24)
	panel.add_child(margin)
	var stack:=VBoxContainer.new();stack.add_theme_constant_override("separation",16);margin.add_child(stack)
	cards=Label.new();cards.add_theme_font_size_override("font_size",23);stack.add_child(cards)
	message=Label.new();message.custom_minimum_size.y=95;message.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;stack.add_child(message)
	var scroll:=ScrollContainer.new();scroll.follow_focus=true;scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;stack.add_child(scroll)
	actions=VBoxContainer.new();actions.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(actions)
	visible=false
func t(fr: String,en: String) -> String:return fr if locale=="fr" else en
func name_of(id: String) -> String:return Catalog.name_of(id,locale)
func button(text: String,action: Callable,enabled: bool=true) -> Button:
	var control:=Button.new();control.text=text;control.custom_minimum_size.y=40;control.disabled=not enabled;actions.add_child(control);control.pressed.connect(action);return control
func open(simulator: RefCounted,language: String) -> void:
	if battle!=null and battle.has_signal("changed") and battle.changed.is_connected(_battle_changed):battle.changed.disconnect(_battle_changed)
	battle=simulator
	if battle.has_signal("changed"):battle.changed.connect(_battle_changed)
	locale=language;visible=true;event_index=0;choice_page="main";mega_selected=false;journal_open=false;journal_page=0;render()
func _battle_changed() -> void:
	event_index=0;journal_open=false;render()
func execute(command: Dictionary) -> void:
	if command.kind=="move" and mega_selected:command.mega=true
	if not battle.execute(command):return
	mega_selected=false
	event_index=0;choice_page="main";render()
func advance() -> void:
	if event_index<battle.events.size():event_index+=1;render()
func handle_key(event: InputEvent) -> bool:
	if not event is InputEventKey or not event.pressed:return false
	if journal_open:
		if not event.echo and (event.keycode==KEY_ESCAPE or (comfort!=null and comfort.matches(event,"menu"))):journal_open=false;render();return true
		return event.echo
	if ((comfort!=null and comfort.confirming(event)) or (comfort==null and event.keycode in [KEY_A,KEY_E,KEY_ENTER,KEY_SPACE])) and event_index<battle.events.size():
		if not event.echo:advance()
		return true
	if event.keycode==KEY_ESCAPE or (comfort!=null and comfort.matches(event,"menu")):
		if not event.echo and event_index>=battle.events.size() and choice_page!="main":choice_page="main";render()
		return true
	return event.echo
func render() -> void:
	for child: Node in actions.get_children():actions.remove_child(child);child.queue_free()
	var player: Dictionary=battle.current(0);var enemy: Dictionary=battle.current(1)
	cards.text=t("Adversaire : %s Nv.%d • %d/%d PV %s\n\nÉquipe : %s Nv.%d • %d/%d PV %s\nTour %d • %s", "Opponent: %s Lv.%d • %d/%d HP %s\n\nParty: %s Lv.%d • %d/%d HP %s\nTurn %d • %s") % [name_of(enemy.species),enemy.level,enemy.hp,Mon.stats(enemy).hp,Catalog.text("status_names",enemy.status,locale),name_of(player.species),player.level,player.hp,Mon.stats(player).hp,Catalog.text("status_names",player.status,locale),battle.turn,t("sauvage","wild") if battle.trainer.is_empty() else t("dresseur","trainer")]
	cards.text+="\n"+field_caption()
	if battle.get("double_mode")==true:cards.text=double_cards()
	if battle.has_signal("changed"):cards.text+=t("\nMoteur : Showdown • règles 9G", "\nEngine: Showdown • Gen IX rules")
	if journal_open:
		render_journal();return
	if event_index<battle.events.size():
		message.text=battle.events[event_index][locale]
		message.text+=t("\nMessage %d / %d — avance manuelle","\nMessage %d / %d — manual advance") % [event_index+1,battle.events.size()]
		button(t("Continuer • %s / Entrée","Continue • %s / Enter") % (comfort.caption("interact") if comfort!=null else "E"),advance).grab_focus()
		journal_button();return
	if battle.get("busy")==true:
		message.text=t("Showdown résout le combat…", "Showdown is resolving the battle…");return
	if not battle.active:
		visible=false;finished.emit(battle.result);return
	message.text=t("Que veux-tu faire ?","What will you do?")
	if battle.has_signal("changed") and battle.available_moves(0).size()==1 and player.moves.size()>1:
		message.text+=t("\nUne seule attaque disponible : vérifie le verrouillage ou les PP.","\nOnly one move available: check locking or PP.")
	journal_button()
	if battle.get("double_mode")==true:
		render_double();return
	if player.hp<=0:
		message.text=t("Choisis un Pokémon pour remplacer le Pokémon K.O.","Choose a replacement for your fainted Pokémon.");render_team(true);return
	match choice_page:
		"main":
			button(t("Attaquer","Fight"),func():choice_page="moves";render()).grab_focus()
			button(t("Pokémon","Pokémon"),func():choice_page="team";render())
			button(t("Sac","Bag"),func():choice_page="bag";render())
			button(t("Fuir","Run"),func():execute({"kind":"run"}),battle.trainer.is_empty())
		"moves":
			details_toggle()
			render_mega_toggle()
			if battle.charging[0]>=0:
				button(t("Terminer l’attaque chargée","Complete charged move"),func():execute({"kind":"move","slot":battle.charging[0]}));return
			if battle.available_moves(0).is_empty():button(t("Lutte (tous les PP épuisés)","Struggle (all PP depleted)"),func():execute({"kind":"move","slot":-1}))
			else:
				for i: int in range(player.moves.size()):
					var slot: int=i;var move: Dictionary=Catalog.move(player.moves[i].id)
					var attack: Button=button("%s • %s • %d/%d PP" % [name_of(player.moves[i].id),Catalog.text("type_names",move.type,locale),player.moves[i].pp,move.pp],func():execute({"kind":"move","slot":slot}),slot in battle.available_moves(0))
					attack.tooltip_text=move_caption(move)
					if move_details:detail_label(move_caption(move))
			back()
		"team":render_team(false);back()
		"bag":
			for item: String in ["poke-ball","great-ball"]:
				var id: String=item
				button("%s × %d" % [name_of(id),battle.adventure.bag.get(id,0)],func():execute({"kind":"ball","item":id}),battle.valid_command({"kind":"ball","item":id}))
			for item: String in ["potion","antidote","paralyze-heal"]:
				var id: String=item
				button("%s × %d" % [name_of(id),battle.adventure.bag.get(id,0)],func():choice_page=id;render(),battle.adventure.bag.get(id,0)>0)
			back()
		_:
			for i: int in range(battle.adventure.team.size()):
				var index: int=i;var mon: Dictionary=battle.adventure.team[i]
				var command: Dictionary={"kind":"item","item":choice_page,"index":index}
				button("%s %d/%d PV" % [name_of(mon.species),mon.hp,Mon.stats(mon).hp],func():execute(command),battle.valid_command(command))
			back()
func back() -> void:button(t("Retour • Échap","Back • Esc"),func():choice_page="main";render())
func render_team(forced: bool) -> void:
	for i: int in range(battle.adventure.team.size()):
		var index: int=i;var mon: Dictionary=battle.adventure.team[i]
		button(t("%s Nv.%d • %d/%d PV %s","%s Lv.%d • %d/%d HP %s") % [name_of(mon.species),mon.level,mon.hp,Mon.stats(mon).hp,Catalog.text("status_names",mon.status,locale)],func():
			if forced:
				if battle.replace_fainted(index):event_index=0;render()
			else:execute({"kind":"switch","index":index}),battle.valid_switch(index))

func double_cards() -> String:
	var text: String=t("Combat double • tour %d", "Double battle • turn %d") % battle.turn
	if battle.get("sandbox")==true:text+=t(" • ESSAI SANS SAUVEGARDE"," • UNSAVED SANDBOX")
	for side: int in [1,0]:
		var slots: Array=battle.enemy_slots if side==1 else battle.player_slots
		var members: Array=battle.enemies if side==1 else battle.adventure.team
		for slot: int in range(2):
			var mon: Dictionary=members[int(slots[slot])]
			text+="\n%s %d : %s • %d/%d PV" % [t("Adversaire","Opponent") if side==1 else t("Équipe","Party"),slot+1,name_of(mon.species),mon.hp,Mon.stats(mon).hp]
			if battle.protected.has(int(mon.uid)):text+=t(" • Abri"," • Protect")
			if battle.helping.has(int(mon.uid)):text+=t(" • Coup d’Main"," • Helping Hand")
	text+="\n"+field_caption()
	return text
func render_double() -> void:
	cards.text=double_cards()
	if battle.replacement_needed():message.text=t("Remplacement obligatoire", "Replacement required");render_team(true);return
	if battle.current(0).hp<=0:battle.next_actor()
	message.text=t("Choisir pour %s (position %d). Les deux choix sont verrouillés avant le tour.","Choose for %s (position %d). Both choices are locked before the turn.") % [name_of(battle.current(0).species),battle.selected_player+1]
	details_toggle()
	render_mega_toggle()
	if not battle.queued.is_empty():message.text+=t("\nChoix allié verrouillé ; termine le choix du partenaire.","\nAlly choice locked; finish the partner’s choice.")
	var choices: Array=battle.available_moves(0)
	if battle.charging[0]>=0:choices=[battle.charging[0]]
	if choices.is_empty():choices=[-1]
	for slot: int in choices:
		var move: Dictionary=battle.move_for(0,slot)
		if move_details:detail_label(name_of(battle.move_id(0,slot))+" — "+move_caption(move))
		var target_kind: String=move.get("target","self" if move.get("self",false) else "single")
		if target_kind!="single":
			var command: Dictionary={"kind":"move","slot":slot,"target":0,"mega":mega_selected}
			var caption: String={"self":t("soi-même","self"),"opponents":t("tous les adversaires","all opponents"),"all-adjacent":t("adversaires ET allié","opponents AND ally"),"ally":t("allié","ally")}.get(target_kind,"")
			button("%s • %d PP → %s" % [name_of(battle.move_id(0,slot)),battle.current(0).moves[slot].pp if slot>=0 else 0,caption],func():execute(command),battle.valid_command(command))
			continue
		for target: int in range(2):
			var command: Dictionary={"kind":"move","slot":slot,"target":target,"target_side":1,"mega":mega_selected}
			var enemy: Dictionary=battle.enemies[int(battle.enemy_slots[target])]
			button("%s → %s [%d]" % [name_of(battle.move_id(0,slot)),name_of(enemy.species),target+1],func():execute(command),battle.valid_command(command))
		if slot==-1:continue
		var ally_target: int=1-battle.selected_player
		var ally: Dictionary=battle.adventure.team[int(battle.player_slots[ally_target])]
		var ally_command: Dictionary={"kind":"move","slot":slot,"target":ally_target,"target_side":0,"mega":mega_selected}
		button("%s → %s %s" % [name_of(battle.move_id(0,slot)),t("ALLIÉ","ALLY"),name_of(ally.species)],func():execute(ally_command),battle.valid_command(ally_command))
	for index: int in range(battle.adventure.team.size()):
		var next_index: int=index
		if battle.valid_switch(index):button(t("Changer : ","Switch: ")+name_of(battle.adventure.team[index].species),func():execute({"kind":"switch","index":next_index}))

	if battle.get("sandbox")==true:
		button(t("Terminer l’essai sans changer la partie","End sandbox without changing campaign"),func():battle.finish("escaped");event_index=battle.events.size();render())

func render_mega_toggle() -> void:
	var mon: Dictionary=battle.current(0)
	var ready: bool=battle.can_mega(0)
	var reason: String=""
	if battle.mega_used[0]:reason=t("déjà utilisée dans ce combat","already used this battle")
	elif not Catalog.data().mega_forms.values().any(func(form: Dictionary):return form.base==mon.species):reason=t("aucune Méga pour cette espèce","no Mega for this species")
	elif not ready:reason=t("équiper une pierre compatible depuis le résumé, hors combat","equip a compatible stone from Summary outside battle")
	if battle.get("double_mode")==true:
		for command: Dictionary in battle.queued.values():
			if command.get("mega",false):ready=false;reason=t("réservée par l'autre Pokémon","reserved by the other Pokémon")
	if not ready:mega_selected=false
	var toggle:=CheckButton.new();toggle.name="MegaToggle";toggle.custom_minimum_size.y=40
	toggle.text=t("Méga-évolution","Mega Evolution")+(" — "+reason if reason!="" else "")
	toggle.disabled=not ready;toggle.set_pressed_no_signal(mega_selected);actions.add_child(toggle)
	toggle.toggled.connect(func(value: bool):mega_selected=value;render())

func field_caption() -> String:
	var weather: String={"sun":t("Soleil","Sun"),"rain":t("Pluie","Rain"),"snow":t("Neige","Snow"),"sand":t("Tempête de sable","Sandstorm")}.get(battle.field.weather,t("Aucun","None"))
	var terrain: String={"electric":t("Électrique","Electric"),"grass":t("Herbu","Grassy"),"misty":t("Brumeux","Misty"),"psychic":t("Psychique","Psychic")}.get(battle.field.terrain,t("Aucun","None"))
	return t("Climat : %s (%d tours) • Terrain : %s (%d tours)","Weather: %s (%d turns) • Terrain: %s (%d turns)") % [weather,battle.field.weather_turns,terrain,battle.field.terrain_turns]

func journal_button() -> void:
	if battle.get("history")==null:return
	var control: Button=button(t("Historique du combat","Battle history"),func():journal_open=true;journal_page=maxi(0,(history_entries().size()-1)/20);render())
	control.name="BattleHistory"
func history_entries() -> Array:
	var entries: Array=[]
	var all: Variant=battle.get("history")
	if not all is Array:return entries
	var limit: int=all.size()-1
	if event_index<battle.events.size():limit=int(battle.events[event_index].get("sequence",-1))
	for entry: Dictionary in all:
		if int(entry.sequence)<=limit:entries.append(entry)
	return entries
func render_journal() -> void:
	var entries: Array=history_entries()
	var pages: int=maxi(1,ceili(entries.size()/20.0))
	journal_page=clampi(journal_page,0,pages-1)
	message.text=t("Historique — page %d / %d. Lecture seule ; aucun message futur.","History — page %d / %d. Read only; no future messages.") % [journal_page+1,pages]
	for entry: Dictionary in entries.slice(journal_page*20,(journal_page+1)*20):
		detail_label(t("Tour %d : ","Turn %d: ") % entry.turn+str(entry[locale]))
	button(t("Page précédente","Previous page"),func():journal_page-=1;render(),journal_page>0)
	button(t("Page suivante","Next page"),func():journal_page+=1;render(),journal_page<pages-1)
	button(t("Retour au combat • Échap","Back to battle • Esc"),func():journal_open=false;render()).grab_focus()
func detail_label(text: String) -> void:
	var control:=Label.new();control.text=text;control.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;control.size_flags_horizontal=Control.SIZE_EXPAND_FILL;actions.add_child(control)
func details_toggle() -> void:
	var toggle:=CheckButton.new();toggle.name="BattleMoveDetails";toggle.text=t("Afficher les fiches d'attaques","Show move details");toggle.set_pressed_no_signal(move_details);actions.add_child(toggle)
	toggle.toggled.connect(func(value: bool):move_details=value;render())
func move_caption(move: Dictionary) -> String:
	var category: String={"physical":t("Physique","Physical"),"special":t("Spéciale","Special"),"status":t("Statut","Status")}.get(move.get("category","status"),"")
	var target: String={"single":t("une cible choisie","one selected target"),"self":t("soi-même","self"),"ally":t("allié","ally"),"opponents":t("tous les adversaires","all opponents"),"all-adjacent":t("adversaires ET allié","opponents AND ally")}.get(move.get("target","self" if move.get("self",false) else "single"),"")
	return t("%s • Puissance %s • Précision %s • Priorité %d • Cible : %s","%s • Power %s • Accuracy %s • Priority %d • Target: %s") % [category,str(int(move.get("power",0))) if move.get("power",0)>0 else "—",str(int(move.get("accuracy",0)))+"%" if move.get("accuracy",0)>0 else "—",move.get("priority",0),target]
