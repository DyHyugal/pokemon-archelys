extends RefCounted
const MovePages=preload("res://scripts/ui/move_pages.gd")
var move_pages: RefCounted
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
var menu: CanvasLayer
var adventure: RefCounted
var selected_uid: int=0
var summary_from: String="team"
var iv_controls: Array=[]
var ev_controls: Array=[]
var nature_control: OptionButton
func _init(parent: CanvasLayer) -> void:menu=parent;move_pages=MovePages.new(menu)
func t(fr: String,en: String) -> String:return menu.tr_text(fr,en)
func name_of(id: String) -> String:return Catalog.name_of(id,menu.locale)
func refresh() -> void:menu.render()
func render(page: String) -> void:
	if adventure==null:return
	match page:
		"team":render_team()
		"pc":render_pc()
		"choices":render_choices()
func render_bag() -> void:
	menu.label(t("Objets du laboratoire","Laboratory items"))
	for id: String in adventure.bag:
		if int(adventure.bag[id])>0:menu.label("%s × %d" % [name_of(id),adventure.bag[id]])
	menu.label(t("Les objets s'utilisent depuis le résumé d'un Pokémon ou pendant le combat.","Use items from a Pokémon summary or during battle."))
func render_team() -> void:
	menu.label(t("Équipe %d/6 • cap %d • %d ₽","Party %d/6 • cap %d • ₽%d") % [adventure.team.size(),adventure.cap,adventure.money])
	var mon: Dictionary=adventure.find(selected_uid)
	if mon.is_empty() or (summary_from=="team" and mon not in adventure.team):
		for entry: Dictionary in adventure.team:
			var uid: int=int(entry.uid)
			menu.button(menu.body,"%s • Nv.%d • %d/%d PV %s" % [name_of(entry.species),entry.level,entry.hp,Mon.stats(entry).hp,Catalog.text("status_names",entry.status,menu.locale)],func():selected_uid=uid;summary_from="team";refresh())
		return
	menu.button(menu.body,t("← Retour au PC","← Back to PC") if summary_from=="pc" else t("← Retour à l'équipe","← Back to party"),func():menu.page="pc" if summary_from=="pc" else "team";selected_uid=0;refresh())
	menu.label("— %s #%d —" % [name_of(mon.species),mon.uid])
	menu.label(t("Types : %s\nTalent : %s\nObjet : %s\nEXP : %d • prochain niveau : %d", "Types: %s\nAbility: %s\nItem: %s\nEXP: %d • next level: %d") % [" / ".join(Catalog.species(mon.species).types.map(func(id: String):return Catalog.text("type_names",id,menu.locale))),Catalog.text("abilities",mon.ability,menu.locale),name_of(mon.item) if mon.item!="" else "—",mon.experience,Mon.experience(mini(100,int(mon.level)+1),Catalog.species(mon.species).growth)])
	menu.label(t("Puissance Cachée : %s (type calculé depuis les IV)","Hidden Power: %s (type calculated from IVs)") % Catalog.text("type_names",Mon.hidden_power(mon),menu.locale))
	for i: int in range(mon.moves.size()):
		var slot: Dictionary=mon.moves[i];menu.label("%d. %s • %d/%d PP" % [i+1,name_of(slot.id),slot.pp,Catalog.move(slot.id).pp])
		if i>0:
			var current: int=i
			menu.button(menu.body,t("Monter l'attaque %d","Move attack %d up") % (i+1),func():adventure.reorder_moves(selected_uid,current,current-1);refresh())
	var index: int=adventure.team.find(mon)
	if index>=0:
		if index>0:menu.button(menu.body,t("Placer en tête","Move to lead"),func():adventure.reorder(index,0);refresh())
		menu.button(menu.body,t("Déposer au PC","Deposit in PC"),func():
			var ok: bool=adventure.deposit(index)
			if ok:selected_uid=0;summary_from="team";refresh()
			menu.feedback.text=t("Déposé au PC.","Deposited in PC.") if ok else t("Garde au moins un Pokémon apte au combat dans l'équipe.","Keep at least one battle-ready Pokémon in the party."))
	menu.label(t("Édition gratuite, hors combat — appliquer pour confirmer","Free editing, outside battle — apply to confirm"))
	var grid:=GridContainer.new();grid.columns=4;menu.body.add_child(grid)
	for heading: String in [t("Statistique","Stat"),t("Valeur réelle","Actual value"),"IV (0–31)","EV (0–252)"]:
		var heading_label:=Label.new();heading_label.text=heading;grid.add_child(heading_label)
	iv_controls=[];ev_controls=[]
	var actual:=Mon.stats(mon)
	for i: int in range(6):
		var key:=Label.new();key.text=Catalog.text("stat_names",Mon.STATS[i],menu.locale);grid.add_child(key)
		var value:=Label.new();value.text=str(actual[Mon.STATS[i]]);grid.add_child(value)
		for field: String in ["iv","ev"]:
			var spin:=SpinBox.new();spin.min_value=0;spin.max_value=31 if field=="iv" else 252;spin.step=1;spin.value=mon[field][i];grid.add_child(spin)
			(iv_controls if field=="iv" else ev_controls).append(spin)
	nature_control=OptionButton.new()
	for nature: String in Mon.NATURES:nature_control.add_item(Catalog.data().natures[nature][menu.locale])
	nature_control.select(Mon.NATURES.find(mon.nature));menu.body.add_child(nature_control)
	menu.button(menu.body,t("Appliquer IV / EV / nature (510 EV maximum)","Apply IV / EV / nature (maximum 510 EVs)"),func():
		var iv: Array=[];var ev: Array=[]
		for control: SpinBox in iv_controls:iv.append(int(control.value))
		for control: SpinBox in ev_controls:ev.append(int(control.value))
		var ok: bool=adventure.edit(selected_uid,iv,ev,Mon.NATURES[nature_control.selected])
		if ok:refresh()
		menu.feedback.text=t("Statistiques recalculées.","Stats recalculated.") if ok else t("Réglage refusé : maximum 510 EV au total. Rien n'a été modifié.","Rejected: maximum 510 total EVs. Nothing was changed."))
	menu.label(t("Équipement et objets","Held items and items"))
	for item: String in ["","oran-berry","leftovers","lucky-egg","venusaurite","charizardite-x","charizardite-y","blastoisinite"]:
		var id: String=item
		menu.button(menu.body,t("Retirer l'objet","Remove held item") if id=="" else t("Tenir : ","Hold: ")+name_of(id),func():
			var ok: bool=adventure.equip(selected_uid,id);refresh();menu.feedback.text=t("Équipement modifié.","Equipment changed.") if ok else t("Objet absent du sac.","Item missing from bag."))
	for item: String in ["potion","antidote","paralyze-heal","thunder-stone","fire-stone"]:
		var id: String=item
		menu.button(menu.body,t("Utiliser : ","Use: ")+name_of(id),func():
			var ok: bool=adventure.use(id,selected_uid);refresh();menu.feedback.text=t("Objet utilisé.","Item used.") if ok else t("Impossible : objet absent ou aucun effet.","Cannot use: item missing or no effect."))
	menu.label(t("Talent — choix légaux du catalogue", "Ability — legal catalogue choices"))
	for ability: String in Catalog.species(mon.species).get("abilities",[]):
		var id: String=ability
		menu.button(menu.body,Catalog.text("abilities",id,menu.locale),func():adventure.set_ability(selected_uid,id);refresh())
	var shiny:=CheckButton.new();shiny.name="SummaryShiny";shiny.text=t("Chromatique","Shiny");shiny.set_pressed_no_signal(mon.get("shiny",false));menu.body.add_child(shiny)
	shiny.toggled.connect(func(value: bool):adventure.set_shiny(selected_uid,value))
	move_pages.render(mon)
func render_pc() -> void:
	menu.storage_pages.render()
func render_choices() -> void:
	if adventure.pending.is_empty():menu.label(t("Aucun apprentissage ni évolution en attente.","No pending move or evolution."));return
	var choice: Dictionary=adventure.pending[0];var mon: Dictionary=adventure.find(int(choice.uid))
	menu.label(t("%d choix en attente — %s Nv.%d","%d pending choices — %s Lv.%d") % [adventure.pending.size(),name_of(mon.species),mon.level])
	if choice.kind=="evolution":
		menu.label(t("Évoluer en %s ?","Evolve into %s?") % name_of(choice.target))
		menu.button(menu.body,t("Faire évoluer","Evolve"),func():adventure.resolve_choice(0,0);refresh())
	else:
		menu.label(t("Apprendre %s ?","Learn %s?") % name_of(choice.target))
		for slot: int in range(mini(4,mon.moves.size()+1)):
			var target: int=slot
			var text: String=t("Emplacement libre","Empty slot") if slot==mon.moves.size() else name_of(mon.moves[slot].id)
			menu.button(menu.body,t("Remplacer : ","Replace: ")+text,func():adventure.resolve_choice(0,target);refresh())
	menu.button(menu.body,t("Refuser ce choix","Decline this choice"),func():adventure.resolve_choice(0,-1);refresh())

func render_nursery() -> void:
	menu.label(t("Incubateur de laboratoire : cadeaux uniques, durée courte d'essai. Les œufs ne sont pas dans l'équipe de combat.","Laboratory incubator: one-time gifts, short test duration. Eggs are separate from the battle party."))
	for id: String in adventure.nursery.GIFTS:
		var species_id: String=id
		if id not in adventure.nursery.received:
			menu.button(menu.body,t("Recevoir un œuf de %s","Receive a %s egg") % name_of(id),func():
				adventure.nursery.receive(adventure,species_id);refresh())
	for egg: Dictionary in adventure.nursery.eggs:
		var uid: int=int(egg.mon.uid)
		menu.label(t("Œuf #%d • Marche restante : %.1f m","Egg #%d • Walking remaining: %.1f m") % [uid,egg.remaining])
		if egg.remaining<=0:
			menu.button(menu.body,t("Faire éclore #%d","Hatch #%d") % uid,func():
				var result: String=adventure.nursery.hatch(adventure,uid)
				refresh()
				menu.feedback.text=t("Éclosion → %s","Hatched → %s") % result if result in ["team","pc"] else t("Équipe et PC pleins : l'œuf est conservé.","Party and PC full: egg retained."))
	menu.label(t("Marche dans le monde puis reviens ici. Le Pokédex est mis à jour à l'éclosion. Sauvegarde possible à chaque étape.","Walk in the world, then return here. The Pokédex updates on hatching. You can save at every stage."))
