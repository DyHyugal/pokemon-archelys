extends RefCounted
const Exploration=preload("res://scripts/domain/exploration.gd")
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const COLOR_NAMES={"shirt":[["Bleu","Blue"],["Corail","Coral"],["Vert","Green"],["Ocre","Ochre"]],"pants":[["Anthracite","Charcoal"],["Brun","Brown"],["Vert sombre","Dark green"]]}
const Appearance=preload("res://scripts/domain/appearance.gd")
var menu: CanvasLayer
var quantities: Dictionary={}
var pending: Dictionary={}
func _init(owner: CanvasLayer) -> void:menu=owner
func t(fr: String,en: String) -> String:return menu.tr_text(fr,en)
func shop() -> void:
 if not pending.is_empty() and pending.kind!="item":pending={}
 menu.label(t("Choisir une quantité puis confirmer ; aucune transaction partielle.","Choose quantity then confirm; no partial transactions."))
 for item: String in Exploration.PRICES:
  var id: String=item;var price: int=Exploration.PRICES[item]
  menu.label("%s × %d • %d ₽" % [Catalog.name_of(id,menu.locale),menu.adventure.bag.get(id,0),price])
  var row:=HBoxContainer.new();menu.body.add_child(row)
  var quantity:=SpinBox.new();quantity.name="ShopQuantity_"+id;quantity.min_value=1;quantity.max_value=99;quantity.step=1;quantity.value=quantities.get(id,1);row.add_child(quantity)
  quantity.value_changed.connect(func(value: float):quantities[id]=int(value))
  menu.button(row,t("Acheter","Buy"),func():offer({"kind":"item","item":id,"count":int(quantity.value),"sell":false}))
  menu.button(row,t("Vendre","Sell"),func():offer({"kind":"item","item":id,"count":int(quantity.value),"sell":true}))
 confirmation()
func wardrobe() -> void:
 if not pending.is_empty() and pending.kind!="wardrobe":pending={}
 menu.label(t("Boutique de palettes d'essai — au havre. Prix100₽ provisoire, résumé gratuit toujours disponible.","Test palette shop — at the haven. Provisional ₽100 price; free summary editor still available."))
 for field: String in ["shirt","pants"]:
  menu.label(t("Haut","Top") if field=="shirt" else t("Pantalon","Trousers"))
  for i: int in range(Appearance.COLORS[field].size()):
   var value: int=i;var key: String=field
   var row:=HBoxContainer.new();menu.body.add_child(row)
   var swatch:=ColorRect.new();swatch.color=Color(Appearance.COLORS[field][i]);swatch.custom_minimum_size=Vector2(32,32);swatch.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_child(swatch)
   var button: Button=menu.button(row,t(COLOR_NAMES[field][i][0],COLOR_NAMES[field][i][1]),func():offer({"kind":"wardrobe","field":key,"value":value}))
   button.name="Clothing_"+field+"_"+str(i);button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
   button.disabled=menu.adventure.exploration.location!="isle-shop" or menu.adventure.appearance[field]==i
 confirmation()
func offer(value: Dictionary) -> void:pending=value.duplicate();menu.render()
func confirmation() -> void:
 if pending.is_empty():return
 var box:=VBoxContainer.new();box.name="CommerceConfirmation";menu.body.add_child(box)
 var amount: int=100 if pending.kind=="wardrobe" else int(int(Exploration.PRICES[pending.item])*(1.0 if not pending.sell else 0.5))*int(pending.count)
 var description: String=(t("Haut","Top") if pending.field=="shirt" else t("Pantalon","Trousers"))+" • "+t(COLOR_NAMES[pending.field][int(pending.value)][0],COLOR_NAMES[pending.field][int(pending.value)][1]) if pending.kind=="wardrobe" else "%s × %d" % [Catalog.name_of(pending.item,menu.locale),pending.count]
 var detail:=Label.new();detail.text=description;box.add_child(detail)
 var text:=Label.new();text.text=t("Confirmer %s : %d ₽ (argent actuel %d)","Confirm %s: ₽%d (current balance %d)") % [t("vente","sale") if pending.get("sell",false) else t("achat","purchase"),amount,menu.adventure.money];box.add_child(text)
 var choice: Dictionary=pending.duplicate()
 var accept: Button=menu.button(box,t("Confirmer la transaction","Confirm transaction"),func():
  var ok: bool=false
  if choice.kind=="wardrobe":ok=menu.adventure.purchase_wardrobe(choice.field,int(choice.value))
  elif menu.adventure.exploration.location in ["shop","isle-shop"]:ok=menu.adventure.purchase(choice.item,int(choice.count),choice.sell)
  pending={};menu.render();menu.feedback.text=t("Transaction effectuée.","Transaction completed.") if ok else t("Transaction refusée ; aucun changement.","Transaction rejected; no changes.")
  if ok and choice.kind=="wardrobe":menu.appearance_changed.emit())
 accept.name="ConfirmCommerce";accept.grab_focus()
 menu.button(box,t("Annuler","Cancel"),func():pending={};menu.render())
