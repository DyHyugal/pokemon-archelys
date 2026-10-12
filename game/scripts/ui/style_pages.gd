extends RefCounted
const Appearance=preload("res://scripts/domain/appearance.gd")
var menu: CanvasLayer
func _init(owner: CanvasLayer) -> void:menu=owner
func render() -> void:
 menu.label(menu.tr_text("Personnage d'essai — les choix sont conservés dans cette campagne. Modèle et coiffures provisoires, pas le héros définitif.","Test character — choices belong to this campaign. Temporary model and hairstyles, not the final hero."))
 var names: Dictionary={"skin":["Peau","Skin"],"shirt":["Haut","Top"],"pants":["Pantalon","Trousers"],"hair":["Cheveux","Hair colour"],"style":["Coiffure","Hairstyle"],"face":["Visage","Face"]}
 for field: String in Appearance.DEFAULT:
  menu.label(menu.tr_text(names[field][0],names[field][1]))
  var choices:=OptionButton.new();choices.name="Appearance_"+field
  var count: int=Appearance.COLORS[field].size() if Appearance.COLORS.has(field) else (3 if field=="style" else 2)
  for i: int in range(count):
   var text: String=menu.tr_text("Palette %d","Palette %d") % (i+1)
   if field=="style":text=[menu.tr_text("Sans cheveux","No hair"),menu.tr_text("Courts","Short"),menu.tr_text("Mi-longs","Medium")][i]
   if field=="face":text=[menu.tr_text("Neutre","Neutral"),menu.tr_text("Yeux plissés","Narrow eyes")][i]
   choices.add_item(text)
  choices.select(int(menu.adventure.appearance[field]));menu.body.add_child(choices)
  choices.item_selected.connect(func(index: int):
   if menu.adventure.set_appearance(field,index):menu.appearance_changed.emit()
   else:menu.feedback.text=menu.tr_text("Modification indisponible.","Change unavailable."))
 menu.button(menu.body,menu.tr_text("Revenir au personnage d'essai initial","Restore initial test character"),func():
  if not menu.adventure.in_battle:menu.adventure.appearance=Appearance.DEFAULT.duplicate();menu.appearance_changed.emit();menu.render())
 menu.label(menu.tr_text("Ferme le menu pour voir le résultat, ou ouvre Photo pour cadrer de près. Sauvegarde pour garder ces choix. La boutique du havre propose des palettes d'essai ; les assets finaux restent à produire.","Close the menu to see the result, or use Photo for a close view. Save to retain these choices. The haven shop offers test palettes; final assets are still pending."))
