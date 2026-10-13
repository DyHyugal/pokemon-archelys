extends RefCounted
const Comfort=preload("res://scripts/services/comfort_store.gd")
var menu: CanvasLayer
var sliders: Dictionary={}
var capture_action: String=""
const NAMES={"left":["Aller à gauche","Move left"],"right":["Aller à droite","Move right"],"up":["Aller vers le haut","Move up"],"down":["Aller vers le bas","Move down"],"interact":["Interagir / texte suivant","Interact / next text"],"menu":["Ouvrir le menu","Open menu"],"bag":["Ouvrir le sac","Open bag"],"journal":["Ouvrir le journal","Open journal"],"run":["Courir (maintenir)","Run (hold)"]}
func _init(owner: CanvasLayer) -> void:menu=owner
func t(fr: String,en: String) -> String:return menu.tr_text(fr,en)
func render() -> void:
 if menu.comfort==null:return
 menu.label(t("Thème de l'interface","Interface theme"))
 var palettes:=OptionButton.new();palettes.name="InterfaceTheme"
 for text: String in [t("Sombre","Dark"),t("Clair","Light"),t("Contraste renforcé","High contrast")]:palettes.add_item(text)
 palettes.select(["dark","light","contrast"].find(menu.comfort.data.get("theme","dark")));menu.body.add_child(palettes)
 palettes.item_selected.connect(func(index: int):
  var error: int=menu.comfort.set_theme(["dark","light","contrast"][index])
  if error==OK:menu.comfort_changed.emit()
  else:menu.feedback.text=error_string(error))
 menu.label(t("Lisibilité","Readability"))
 var size:=OptionButton.new();size.name="TextSize"
 for value: int in [16,20,24]:size.add_item(t("Texte : %d px","Text: %d px") % value)
 size.select([16,20,24].find(int(menu.comfort.data.text_size)));menu.body.add_child(size)
 size.item_selected.connect(func(index: int):apply_value("text_size",[16,20,24][index]))
 menu.label(t("Volumes — sons d'essai originaux, aucune musique finale","Volumes — original test sounds, no final soundtrack"))
 sliders.clear()
 for key: String in ["master","music","effects"]:
  var label: String={"master":t("Général","Master"),"music":t("Musique","Music"),"effects":t("Effets","Effects")}[key]
  var value: Label=menu.label("%s : %d %%" % [label,menu.comfort.data[key]])
  var slider:=HSlider.new();slider.name=key+"Volume";slider.min_value=0;slider.max_value=100;slider.step=1;slider.set_value_no_signal(menu.comfort.data[key]);menu.body.add_child(slider);sliders[key]=slider
  slider.value_changed.connect(func(amount: float):
   var error: int=menu.comfort.set_value(key,int(amount))
   if error==OK:value.text="%s : %d %%" % [label,amount];menu.comfort_changed.emit()
   else:menu.feedback.text=error_string(error))
 for kind: String in ["music","effects"]:
  menu.button(menu.body,t("Écouter la mélodie d'essai","Play test melody") if kind=="music" else t("Écouter le son d'effet","Play test effect"),func():menu.audio_preview_requested.emit(kind))
 menu.button(menu.body,t("Arrêter les sons d'essai","Stop test sounds"),func():menu.audio_preview_requested.emit("stop"))
 preload("res://scripts/ui/display_pages.gd").new(menu).render()
 menu.label(t("Commandes clavier","Keyboard controls"))
 menu.label(t("Choisis une commande, puis appuie sur une touche physique. Échap annule et reste toujours disponible pour revenir au menu. Entrée/Espace gardent la confirmation des interfaces ; F3 reste réservé au laboratoire. Les doublons entre commandes sont refusés.","Choose an action, then press a physical key. Escape cancels and always remains available to return to the menu. Enter/Space retain interface confirmation; F3 remains reserved for the lab. Conflicting action bindings are rejected."))
 for action: String in Comfort.ACTIONS:
  menu.button(menu.body,(t(NAMES[action][0],NAMES[action][1])+" : "+menu.comfort.caption(action)),func():capture_action=action;menu.feedback.text=t("Appuie sur une touche pour : ","Press a key for: ")+t(NAMES[action][0],NAMES[action][1])+t(" (Échap pour annuler)"," (Escape to cancel)"))
 menu.button(menu.body,t("Restaurer uniquement les touches par défaut","Restore default keys only"),func():capture_action="";var error: int=menu.comfort.reset_keys();menu.feedback.text=error_string(error);menu.comfort_changed.emit();menu.render())
func apply_value(field: String,value: int) -> void:
 var error: int=menu.comfort.set_value(field,value)
 if error==OK:menu.comfort_changed.emit()
 else:menu.feedback.text=error_string(error)
func handle_key(event: InputEventKey) -> bool:
 if capture_action.is_empty():return false
 if menu.page!="settings":capture_action="";return false
 if not event.pressed or event.echo:return true
 if event.keycode==KEY_ESCAPE:capture_action="";menu.feedback.text=t("Modification annulée.","Change cancelled.");return true
 var code: int=event.physical_keycode if event.physical_keycode!=0 else event.keycode
 var error: int=menu.comfort.bind(capture_action,code)
 if error!=OK:
  menu.feedback.text=t("Touche réservée ou déjà utilisée. Choisis une autre touche, ou Échap pour annuler.","Reserved or conflicting key. Choose another key, or Escape to cancel.");return true
 capture_action="";menu.comfort_changed.emit();menu.render();menu.feedback.text=t("Touche conservée.","Key saved.");return true
