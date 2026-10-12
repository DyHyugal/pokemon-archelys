extends CanvasLayer
signal atlas_requested(region: String,site: int)
const CommercePages=preload("res://scripts/ui/commerce_pages.gd")
var commerce_pages: RefCounted
const AtlasPages=preload("res://scripts/ui/atlas_pages.gd")
var atlas_pages: RefCounted
const IslandPages=preload("res://scripts/ui/island_pages.gd")
var island_pages: RefCounted
## Presentation only: campaign and preferences remain owned by services.
const StoragePages=preload("res://scripts/ui/storage_pages.gd")
var storage_pages: RefCounted
const AdventurePages=preload("res://scripts/ui/adventure_pages.gd")
const ExplorationPages=preload("res://scripts/ui/exploration_pages.gd")
const CollectionPages=preload("res://scripts/ui/collection_pages.gd")
var collection_pages: RefCounted
const ComfortPages=preload("res://scripts/ui/comfort_pages.gd")
const StylePages=preload("res://scripts/ui/style_pages.gd")
var style_pages: RefCounted
signal appearance_changed
signal photo_requested
var comfort_pages: RefCounted
var comfort: RefCounted
signal comfort_changed
signal audio_preview_requested(kind: String)
var slots: RefCounted
signal scene_requested(id: String,replay: bool)
signal slot_requested(action: String,slot: int)
var exploration_pages: RefCounted
signal travel_requested(target: String,flight: bool)
var adventure: RefCounted
var adventure_pages: RefCounted
signal language_changed(value: String)
signal camera_changed(value: float)
signal speed_changed(value: float)
var speed: float=1.0
signal save_requested
signal load_requested
signal closed

var panel: Control
var title: Label
var body: VBoxContainer
var navigation: VBoxContainer
var page: String = "home"
var locale: String = "fr"
var tokens: int = 0
var completed: Dictionary = {}
var camera_size: float = 16.0
var item_details: Label
var zoom: HSlider
var language: OptionButton
var feedback: Label
var buttons: Dictionary = {}

func _ready() -> void:
	island_pages=IslandPages.new(self)
	atlas_pages=AtlasPages.new(self)
	commerce_pages=CommercePages.new(self)
	adventure_pages=AdventurePages.new(self)
	storage_pages=StoragePages.new(self)
	exploration_pages=ExplorationPages.new(self)
	collection_pages=CollectionPages.new(self)
	comfort_pages=ComfortPages.new(self)
	style_pages=StylePages.new(self)
	layer = 10
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.045, 0.075, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left=100; panel.offset_top=65; panel.offset_right=-100; panel.offset_bottom=-65
	add_child(panel)
	var margin := MarginContainer.new()
	for side: String in ["left","top","right","bottom"]:
		margin.add_theme_constant_override("margin_"+side,24)
	panel.add_child(margin)
	var row := HBoxContainer.new(); row.add_theme_constant_override("separation",32); margin.add_child(row)
	var nav_scroll:=ScrollContainer.new();nav_scroll.custom_minimum_size.x=250;nav_scroll.follow_focus=true;row.add_child(nav_scroll)
	navigation=VBoxContainer.new(); navigation.custom_minimum_size.x=230; nav_scroll.add_child(navigation)
	var content := VBoxContainer.new(); content.size_flags_horizontal=Control.SIZE_EXPAND_FILL; row.add_child(content)
	title=Label.new(); title.add_theme_font_size_override("font_size",28); content.add_child(title)
	var scroll := ScrollContainer.new(); scroll.follow_focus=true; scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL; content.add_child(scroll)
	body=VBoxContainer.new(); body.size_flags_horizontal=Control.SIZE_EXPAND_FILL; body.add_theme_constant_override("separation",16); scroll.add_child(body)
	feedback=Label.new(); feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; content.add_child(feedback)
	visible=false

func tr_text(fr: String, en: String) -> String:
	return fr if locale=="fr" else en

func button(parent: Node, text: String, action: Callable) -> Button:
	var control := Button.new(); control.text=text; control.custom_minimum_size.y=34
	parent.add_child(control); control.pressed.connect(action); return control

func label(text: String) -> Label:
	var control := Label.new(); control.text=text; control.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	body.add_child(control); return control

func clear(container: Node) -> void:
	for child: Node in container.get_children():
		container.remove_child(child); child.queue_free()

func sync(language_code: String, distance: float, progress: RefCounted) -> void:
	locale=language_code; camera_size=distance; tokens=progress.tokens; completed=progress.completed.duplicate()
	if visible:
		render()

func open(target: String = "home") -> void:
	page=target; visible=true; feedback.text=""; render()

func close() -> void:
	commerce_pages.pending={}
	comfort_pages.capture_action=""
	visible=false
	var focus := get_viewport().gui_get_focus_owner()
	if focus: focus.release_focus()
	closed.emit()

func render() -> void:
	if page not in ["services","wardrobe"]:commerce_pages.pending={}
	clear(navigation); clear(body); buttons.clear()
	var pages := ["home","bag","journal","settings"]
	if adventure!=null:
		pages.append_array(["team","pc","choices","map","services","rules","dex","cinema","saves","nursery","journey","appearance","photo","island","atlas","wardrobe"])
		adventure_pages.adventure=adventure
	var names := [tr_text("Pause","Pause"),tr_text("Sac","Bag"),tr_text("Journal","Journal"),tr_text("Paramètres","Settings")]
	if adventure!=null:names.append_array([tr_text("Équipe / Résumé","Party / Summary"),"PC",tr_text("Apprentissages (%d)","Learning (%d)") % adventure.pending.size(),tr_text("Carte / Vol","Map / Fly"),tr_text("Vie quotidienne","Daily services"),tr_text("Règles / Difficulté","Rules / Difficulty"),"Pokédex",tr_text("Cinématiques","Cinematics"),tr_text("Sauvegardes","Save slots"),tr_text("Œufs / Incubateur","Eggs / Incubator"),tr_text("Aventure","Adventure"),tr_text("Personnage","Character"),tr_text("Photo","Photo"),tr_text("Île proposée","Proposed island"),tr_text("Atlas / Studio","Atlas / Studio"),tr_text("Boutique de vêtements","Clothing shop")])
	for index: int in range(pages.size()):
		var target: String=pages[index]
		buttons[target]=button(navigation,names[index],func(): page=target; feedback.text=""; render())
	buttons.save=button(navigation,tr_text("Sauvegarder","Save"),func(): save_requested.emit())
	buttons.load=button(navigation,tr_text("Charger","Load"),func(): load_requested.emit())
	buttons.resume=button(navigation,tr_text("Reprendre • Échap","Resume • Esc"),close)
	title.text=names[pages.find(page)]
	match page:
		"wardrobe":commerce_pages.wardrobe()
		"atlas":atlas_pages.render()
		"island":island_pages.render()
		"appearance":style_pages.render()
		"photo":
			label(tr_text("Cadrage libre autour du personnage, sans déplacer la partie. Export PNG à la résolution de la fenêtre. Disponible seulement en exploration solo.","Free framing around your character without moving the campaign. PNG export at the window resolution. Available only in solo exploration."))
			button(body,tr_text("Ouvrir le mode photo","Open photo mode"),func():photo_requested.emit())
		"home":
			label(tr_text("Laboratoire solo — décors et contenu provisoires.","Solo laboratory — temporary scenery and content."))
			label(tr_text("Consulte ton sac et ton journal, règle la caméra ou sauvegarde ta progression.

Échap : menu / retour
I : sac · J : journal
E / Entrée : interagir dans le monde", "View your bag and journal, adjust the camera or save your progress.

Esc: menu / back
I: bag · J: journal
E / Enter: interact in the world"))
		"bag":
			if tokens==0:
				label(tr_text("Ton sac est vide. La caisse du laboratoire contient un jeton de test.","Your bag is empty. The laboratory crate contains a test token."))
			else:
				var item := ItemList.new(); item.custom_minimum_size.y=90; body.add_child(item)
				item.add_item(tr_text("Jeton de test × %d","Test token × %d") % tokens)
				item_details=label("")
				item.item_selected.connect(func(_index: int): show_item())
				item.select(0); show_item()
			if adventure!=null:adventure_pages.render_bag()
		"team", "pc", "choices":
			adventure_pages.render(page)
		"map","services","rules":exploration_pages.render(page)
		"dex","cinema","saves":collection_pages.render(page)
		"journey":
			button(body,tr_text("Explorer la première île proposée","Explore the proposed first island"),func():page="island";render())
			label(tr_text("Ouverture proposée d'Archélys — contenu et rendu à valider.","Proposed Archelys opening — content and visuals awaiting approval."))
			label(adventure.journey.objective(locale))
			if not adventure.journey.flags.has("briefing"):
				var start: Button=button(body,tr_text("Commencer le prologue","Start prologue"),func():
					if adventure.journey.begin(adventure):scene_requested.emit("slice-prologue",false))
				start.disabled=adventure.exploration.location!="village"
			elif not adventure.records.scenes.has("slice-prologue"):
				button(body,tr_text("Reprendre le prologue","Resume prologue"),func():scene_requested.emit("slice-prologue",false))
			if adventure.journey.flags.has("boss") and not adventure.journey.flags.has("ending"):
				button(body,tr_text("Voir la conclusion","Watch ending"),func():scene_requested.emit("slice-ending",false))
			label(tr_text("Parcours : village → sentier → épreuve → retour. Équipe et sauvegarde actuelles conservées. Les objets de départ ne sont donnés qu'une fois.","Route: village → trail → trial → return. Current party and save retained. Starting supplies are granted only once."))
		"nursery":
			adventure_pages.render_nursery()
		"journal":
			if adventure!=null:
				label(adventure.journey.objective(locale))
				if adventure.island.flags.has("started"):label(adventure.island.objective(locale))
			label(tr_text("Objectifs du laboratoire", "Laboratory objectives"))
			var ids := ["guide","sign","crate"]
			var tasks := [tr_text("Parler au guide","Talk to the guide"),tr_text("Lire le panneau au nord-ouest","Read the northwest sign"),tr_text("Ouvrir la caisse au sud-est","Open the southeast crate")]
			for index: int in range(ids.size()):
				label(("✓ " if completed.has(ids[index]) else "○ ")+tasks[index])
		"settings":
			label(tr_text("Langue", "Language"))
			language=OptionButton.new(); language.add_item("Français"); language.add_item("English"); language.select(0 if locale=="fr" else 1); body.add_child(language)
			language.item_selected.connect(func(index: int): language_changed.emit("fr" if index==0 else "en"))
			label(tr_text("Distance de caméra — proche ← → loin", "Camera distance — near ← → far"))
			zoom=HSlider.new(); zoom.min_value=12; zoom.max_value=22; zoom.step=0.5; zoom.set_value_no_signal(camera_size); body.add_child(zoom)
			var distance := label(str(camera_size))
			zoom.value_changed.connect(func(value: float): camera_size=value; distance.text=str(value); camera_changed.emit(value))
			label(tr_text("Vitesse labo — propositions 1× / 2× / 3× / 4×, musique inchangée", "Laboratory speed — proposed 1× / 2× / 3× / 4×, music unchanged"))
			var speeds:=OptionButton.new()
			for value: int in [1,2,3,4]:speeds.add_item("%d×" % value)
			speeds.select(int(speed)-1);body.add_child(speeds)
			speeds.item_selected.connect(func(index: int):speed=float(index+1);speed_changed.emit(speed))
			label(tr_text("Ces préférences sont conservées automatiquement, indépendamment de la sauvegarde de partie.","These preferences are saved automatically, independently of your game save."))
	if page=="home" and comfort!=null:
		var help: Label=body.get_child(1)
		help.text=tr_text("%s / Échap : menu · %s : sac · %s : journal\n%s / Entrée : interagir", "%s / Esc: menu · %s: bag · %s: journal\n%s / Enter: interact") % [comfort.caption("menu"),comfort.caption("bag"),comfort.caption("journal"),comfort.caption("interact")]
	if page=="settings":comfort_pages.render()
	if page=="pc" and body.has_node("StorageInspect"):body.get_node("StorageInspect").grab_focus()
	else:buttons[page].grab_focus()

func show_item() -> void:
	item_details.text=tr_text("Jeton de test
Quantité : %d
Objet témoin reçu dans la caisse du laboratoire. Non utilisable ; conservé dans la sauvegarde.","Test token
Quantity: %d
Sample item received from the laboratory crate. Cannot be used; retained in your game save.") % tokens

func handle_key(event: InputEventKey) -> bool:
	if comfort_pages.handle_key(event):return true
	if not event.pressed or event.echo: return false
	if event.keycode==KEY_ESCAPE or (comfort!=null and comfort.matches(event,"menu")):
		if page=="home": close()
		else: page="home"; feedback.text=""; render()
		return true
	return false
