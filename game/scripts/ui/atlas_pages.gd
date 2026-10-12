extends RefCounted
const Atlas=preload("res://scripts/domain/atlas.gd")
var menu: CanvasLayer
var selected: String="tropical"
func _init(owner: CanvasLayer) -> void:menu=owner
func render() -> void:
 menu.label(menu.tr_text("Atlas proposé — six îles et ancien Æther. Deux lieux habités par site servent de premières propositions, pas d'inventaire final des villes.","Proposed atlas — six islands and former Aether. Two inhabited sites per region are initial proposals, not a final town inventory."))
 var choices:=OptionButton.new();choices.name="AtlasRegion"
 for id: String in Atlas.REGIONS:choices.add_item(Atlas.label(id,menu.locale))
 choices.select(Atlas.REGIONS.keys().find(selected));menu.body.add_child(choices)
 choices.item_selected.connect(func(index: int):selected=Atlas.REGIONS.keys()[index];menu.render())
 var region: String=selected
 menu.label(menu.tr_text("Occupation RR proposée","Proposed RR occupation") if Atlas.REGIONS[selected].occupied else menu.tr_text("Hors occupation RR — conformément au cahier","Outside RR occupation — per specification"))
 for i: int in range(4):
  var site: int=i
  var button: Button=menu.button(menu.body,Atlas.site(selected,i,menu.locale),func():menu.atlas_requested.emit(region,site))
  button.name="AtlasSite%d" % i
 menu.label(menu.tr_text("Le studio est séparé de la campagne : exploration figée, aucun déblocage, combat ou sauvegarde pendant la visite. L'île tropicale jouable reste dans Île proposée.","Studio is separate from campaign: frozen exploration, no unlocks/battles/saves during the visit. The playable tropical island remains in Proposed island."))
