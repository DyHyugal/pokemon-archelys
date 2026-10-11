extends RefCounted
const Fossils=preload("res://scripts/domain/fossils.gd")
const Mon=preload("res://scripts/domain/pokemon.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Exploration=preload("res://scripts/domain/exploration.gd")
var menu: CanvasLayer
func _init(parent: CanvasLayer) -> void:menu=parent
func t(fr: String,en: String) -> String:return menu.tr_text(fr,en)
func render(page: String) -> void:
	var owner: RefCounted=menu.adventure
	var state: RefCounted=owner.exploration
	if page=="map":
		menu.label(t("Carte du laboratoire — géographie provisoire, pas l'archipel final.","Laboratory map — placeholder geography, not the final archipelago."))
		var diagram:=GridContainer.new();diagram.columns=3;menu.body.add_child(diagram)
		for text: String in ["",t("Quartier visuel","Visual district"),"",t("Village / Centre / Boutique","Village / Center / Shop"),"↔",t("Crique / Pêche","Cove / Fishing")]:
			var tile:=Label.new();tile.text=text;tile.custom_minimum_size=Vector2(190,65);diagram.add_child(tile)
		menu.label(t("Vol : après le premier dresseur, uniquement vers les lieux visités. Aucun Pokémon volant requis.","Fly: after trainer 1, only to visited locations. No Flying Pokémon required."))
		for id: String in ["village","cove","district"]:
			var target: String=id
			var fly: Button=menu.button(menu.body,t("Voler vers : ","Fly to: ")+id,func():menu.travel_requested.emit(target,true))
			fly.disabled=not (state.field_unlocked("fly",owner.victories) and id in state.visited)
	elif page=="services":
		menu.label(t("Lieu actuel : %s • Argent : %d ₽","Current location: %s • Money: ₽%d") % [state.location,owner.money])
		menu.label(t("Centre et boutique : entre par les portes du village. La jetée au sud mène à la crique ; le passage nord au quartier visuel. Interagis avec E / Entrée.","Center and shop: enter through the village doors. The south pier leads to the cove; the north passage to the visual district. Interact with E / Enter."))
		if state.location=="shop":
			for item: String in Exploration.PRICES:
				var id: String=item
				menu.label("%s × %d • %d ₽" % [Catalog.name_of(id,menu.locale),owner.bag.get(id,0),Exploration.PRICES[id]])
				var row:=HBoxContainer.new();menu.body.add_child(row)
				for count: int in [1,5]:
					var quantity: int=count
					menu.button(row,t("Acheter × %d","Buy × %d") % count,func():transaction(id,quantity,false))
				menu.button(row,t("Vendre × 1 (moitié du prix)","Sell × 1 (half price)"),func():transaction(id,1,true))
		elif state.location=="center":
			menu.label(t("Restauration de fossiles — service provisoire du laboratoire, Pokémon niveau5.","Fossil restoration — temporary laboratory service, level5 Pokémon."))
			if state.nuzlocke=="on":menu.label(t("Fossiles indisponibles en défi : intégration des quotas reportée.","Fossils unavailable in challenge mode: quota integration deferred."))
			if not owner.fossil_samples_received:
				var samples: Button=menu.button(menu.body,t("Labo : recevoir trois fossiles d'essai (une fois)","Lab: receive three sample fossils (once)"),func():
					var ok: bool=Fossils.grant_samples(owner);menu.render()
					menu.feedback.text=t("Fossiles ajoutés au sac.","Fossils added to bag.") if ok else t("Réception impossible ; sac inchangé.","Cannot receive; bag unchanged."))
				samples.disabled=not Fossils.available(owner)
			for item: String in Fossils.RECIPES:
				var fossil: String=item
				var restore: Button=menu.button(menu.body,t("Restaurer : %s × %d → %s","Restore: %s × %d → %s") % [Catalog.name_of(item,menu.locale),owner.bag.get(item,0),Catalog.name_of(Fossils.RECIPES[item],menu.locale)],func():
					var result: Dictionary=Fossils.restore_fossil(owner,fossil);menu.render()
					menu.feedback.text=t("%s reçu → %s","Received %s → %s") % [Catalog.name_of(result.species,menu.locale),result.result] if result.result in ["team","pc"] else t("Restauration impossible ; aucun fossile perdu.","Restoration unavailable; no fossil lost."))
				restore.disabled=not Fossils.available(owner) or int(owner.bag.get(item,0))<=0
			menu.button(menu.body,t("Soigner l'équipe","Heal party"),func():owner.heal_team();menu.render();menu.feedback.text=t("Soins terminés. Aucun Pokémon mort en défi n'est ressuscité.","Healing complete. Dead challenge Pokémon are never revived."))
		else:menu.label(t("Achats disponibles seulement dans la boutique.","Purchases are available only inside the shop."))
	elif page=="rules":
		menu.label(t("Réglages de campagne — modifiables hors combat","Campaign settings — change outside battle"))
		choice(t("Difficulté de l'IA","AI difficulty"),["chill","normal","hard"],state.difficulty,func(value: String):state.difficulty=value)
		var cap_toggle:=CheckButton.new();cap_toggle.text=t("Plafond de niveau actif","Level ceiling enabled");cap_toggle.button_pressed=state.cap_enabled;menu.body.add_child(cap_toggle)
		cap_toggle.toggled.connect(func(value: bool):state.cap_enabled=value)
		menu.label(t("Désactiver permet de dépasser le cap. Le réactiver conserve les niveaux, mais bloque l'EXP des membres déjà au-dessus.","Disabling allows levels above the cap. Re-enabling preserves levels but blocks XP for members already above it."))
		choice(t("Multiplicateur EXP","XP multiplier"),["1","2","3","4","5"],str(state.exp_multiplier),func(value: String):state.exp_multiplier=int(value))
		choice(t("Chance shiny pour les futures rencontres (1 sur N)","Shiny odds for future encounters (1 in N)"),["4096","1024","256","64","1"],str(state.shiny_odds),func(value: String):state.shiny_odds=int(value))
		menu.label(t("Nuzlocke : %s — un essai de capture par zone ; KO permanent, doublons familiaux ignorables. Les règles cadeaux/œufs/fossiles/Soul-link attendent ces systèmes.","Nuzlocke: %s — one capture attempt per zone; permanent fainting, family duplicates can be ignored. Gifts/eggs/fossils/Soul-link rules await those systems.") % state.nuzlocke)
		if state.nuzlocke=="off":menu.label(t("Nuzlocke / Soul-link reportés : aucun test demandé pour le moment.","Nuzlocke / Soul-link deferred: no testing requested for now."))
		elif state.nuzlocke=="on":
			menu.button(menu.body,t("Désactiver définitivement le défi (aucune réactivation)","Permanently disable challenge (cannot re-enable)"),func():state.retire_challenge();menu.render())
			menu.label(t("Quotas : %s\nMorts : %s","Claims: %s\nDead: %s") % [str(state.claims),str(state.dead)])
			if state.game_over(owner.team,owner.boxes):menu.label(t("Game over : équipe et PC sans survivant. La reprise avec Chapignon attend encore la décision sur les nouveaux quotas ; passer en normal permet de continuer.","Game over: no survivors in party or PC. Breloom recovery awaits the new quota decision; switch to normal to continue."))
		menu.label(t("Caps, prix et déblocages du laboratoire sont provisoires, pas l'équilibrage des îles.","Laboratory caps, prices and unlocks are provisional, not island balance."))
func choice(title: String,values: Array,current: String,action: Callable) -> void:
	menu.label(title)
	var picker:=OptionButton.new()
	for value: String in values:picker.add_item(value)
	picker.select(values.find(current));menu.body.add_child(picker)
	picker.item_selected.connect(func(index: int):action.call(values[index]))
func transaction(item: String,count: int,sell: bool) -> void:
	var ok: bool=menu.adventure.exploration.location=="shop" and menu.adventure.purchase(item,count,sell)
	menu.render();menu.feedback.text=t("Transaction effectuée.","Transaction completed.") if ok else t("Transaction refusée : argent, quantité ou place insuffisants. Aucun objet ni argent perdu.","Transaction rejected: insufficient money, quantity or space. No items or money lost.")
