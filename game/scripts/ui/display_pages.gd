extends RefCounted
var menu: CanvasLayer
func _init(owner: CanvasLayer) -> void:menu=owner
func t(fr: String,en: String) -> String:return menu.tr_text(fr,en)
func select_option(field: String,values: Array,names: Array) -> void:
 var selector:=OptionButton.new();selector.name="Display_"+field
 for text: String in names:selector.add_item(text)
 selector.select(values.find(menu.comfort.data[field]));menu.body.add_child(selector)
 selector.item_selected.connect(func(index: int):save(field,values[index]))
func toggle(field: String,caption: String) -> void:
 var control:=CheckButton.new();control.name="Display_"+field;control.text=caption;control.button_pressed=menu.comfort.data[field];menu.body.add_child(control)
 control.toggled.connect(func(value: bool):save(field,value))
func save(field: String,value: Variant) -> void:
 var error: int=menu.comfort.set_option(field,value)
 if error==OK:menu.comfort_changed.emit()
 else:menu.feedback.text=error_string(error)
func render() -> void:
 menu.label(t("Affichage — préférences de ce PC, indépendantes de la sauvegarde","Display — local PC preferences, independent of campaign saves"))
 select_option("window_mode",["windowed","borderless","fullscreen"],[t("Fenêtre","Windowed"),t("Fenêtre sans bordure","Borderless window"),t("Plein écran","Fullscreen")])
 select_option("resolution",["1280x720","1600x900","1920x1080"],["1280 × 720","1600 × 900","1920 × 1080"])
 select_option("fps_limit",[0,30,60,120],[t("Images/s : sans limite","FPS: unlimited"),"30 FPS","60 FPS","120 FPS"])
 toggle("vsync",t("Synchronisation verticale","Vertical sync"))
 toggle("combat_animations",t("Transition des textes de combat (prototype)","Battle text transitions (prototype)"))
 toggle("reduced_motion",t("Réduire les mouvements de caméra et décors","Reduce camera and scenery movement"))
 toggle("world_labels",t("Afficher les repères dans le monde","Show world labels"))
 menu.label(t("Manette : stick gauche/croix pour marcher ; A interagir/confirmer, B retour, Start menu, X sac, Y journal. Dans les menus, la croix sélectionne et A confirme. Configuration standard ; remappage manette ultérieur.","Controller: left stick/D-pad to walk; A interact/confirm, B back, Start menu, X bag, Y journal. In menus use D-pad and A. Standard layout; controller remapping deferred."))
