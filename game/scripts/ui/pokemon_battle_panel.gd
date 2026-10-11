extends CanvasLayer
signal finished(result: String)
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
var battle: RefCounted
var locale: String="fr"
var cards: Label
var message: Label
var actions: VBoxContainer
var event_index: int=0
var choice_page: String="main"
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
	var scroll:=ScrollContainer.new();scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;stack.add_child(scroll)
	actions=VBoxContainer.new();actions.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(actions)
	visible=false
func t(fr: String,en: String) -> String:return fr if locale=="fr" else en
func name_of(id: String) -> String:return Catalog.name_of(id,locale)
func button(text: String,action: Callable,enabled: bool=true) -> Button:
	var control:=Button.new();control.text=text;control.custom_minimum_size.y=40;control.disabled=not enabled;actions.add_child(control);control.pressed.connect(action);return control
func open(simulator: RefCounted,language: String) -> void:
	battle=simulator;locale=language;visible=true;event_index=0;choice_page="main";render()
func execute(command: Dictionary) -> void:
	if not battle.execute(command):return
	event_index=0;choice_page="main";render()
func advance() -> void:
	if event_index<battle.events.size():event_index+=1;render()
func handle_key(event: InputEvent) -> bool:
	if not event is InputEventKey or not event.pressed:return false
	if event.keycode in [KEY_A,KEY_E,KEY_ENTER,KEY_SPACE] and event_index<battle.events.size():
		if not event.echo:advance()
		return true
	if event.keycode==KEY_ESCAPE:
		if not event.echo and event_index>=battle.events.size() and choice_page!="main":choice_page="main";render()
		return true
	return event.echo
func render() -> void:
	for child: Node in actions.get_children():actions.remove_child(child);child.queue_free()
	var player: Dictionary=battle.current(0);var enemy: Dictionary=battle.current(1)
	cards.text=t("Adversaire : %s Nv.%d • %d/%d PV %s\n\nÉquipe : %s Nv.%d • %d/%d PV %s\nTour %d • %s", "Opponent: %s Lv.%d • %d/%d HP %s\n\nParty: %s Lv.%d • %d/%d HP %s\nTurn %d • %s") % [name_of(enemy.species),enemy.level,enemy.hp,Mon.stats(enemy).hp,Catalog.text("status_names",enemy.status,locale),name_of(player.species),player.level,player.hp,Mon.stats(player).hp,Catalog.text("status_names",player.status,locale),battle.turn,t("sauvage","wild") if battle.trainer.is_empty() else t("dresseur","trainer")]
	if event_index<battle.events.size():
		message.text=battle.events[event_index][locale]
		button(t("Continuer • E / Entrée","Continue • E / Enter"),advance).grab_focus();return
	if not battle.active:
		visible=false;finished.emit(battle.result);return
	message.text=t("Que veux-tu faire ?","What will you do?")
	if player.hp<=0:
		message.text=t("Choisis un Pokémon pour remplacer le Pokémon K.O.","Choose a replacement for your fainted Pokémon.");render_team(true);return
	match choice_page:
		"main":
			button(t("Attaquer","Fight"),func():choice_page="moves";render()).grab_focus()
			button(t("Pokémon","Pokémon"),func():choice_page="team";render())
			button(t("Sac","Bag"),func():choice_page="bag";render())
			button(t("Fuir","Run"),func():execute({"kind":"run"}),battle.trainer.is_empty())
		"moves":
			if battle.available_moves(0).is_empty():button(t("Lutte (tous les PP épuisés)","Struggle (all PP depleted)"),func():execute({"kind":"move","slot":-1}))
			else:
				for i: int in range(player.moves.size()):
					var slot: int=i;var move: Dictionary=Catalog.move(player.moves[i].id)
					button("%s • %s • %d/%d PP" % [name_of(player.moves[i].id),Catalog.text("type_names",move.type,locale),player.moves[i].pp,move.pp],func():execute({"kind":"move","slot":slot}),player.moves[i].pp>0)
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
		button("%s Nv.%d • %d/%d PV" % [name_of(mon.species),mon.level,mon.hp,Mon.stats(mon).hp],func():
			if forced:
				if battle.replace_fainted(index):event_index=0;render()
			else:execute({"kind":"switch","index":index}),battle.valid_switch(index))
