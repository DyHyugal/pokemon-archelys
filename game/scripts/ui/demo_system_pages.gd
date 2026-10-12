extends RefCounted
const Catalog=preload("res://scripts/domain/pokemon_catalog.gd")
const Content=preload("res://scripts/domain/demo_content.gd")
var game: CanvasLayer
var menu: CanvasLayer
func _init(owner: CanvasLayer) -> void:game=owner;menu=game.menu
func label(text: String) -> void:menu.label(text)
func t(fr: String,en: String) -> String:return game.t(fr,en)
func picker(id: String,caption: String,values: Array,current: String,action: Callable) -> void:
 label(caption);var control:=OptionButton.new();control.name=id
 for value: String in values:control.add_item(value)
 control.select(values.find(current));menu.body.add_child(control)
 control.item_selected.connect(func(index: int):
  if not menu.adventure.in_battle:action.call(values[index]);game.persist_auto())
func render(page: String) -> void:
 var a: RefCounted=menu.adventure;var settings: RefCounted=a.exploration
 if page=="rules":
  label(t("Règles de cette partie, modifiables hors combat.","Rules for this save; change outside battle."))
  picker("DemoDifficulty",t("Difficulté IA","AI difficulty"),["chill","normal","hard"],settings.difficulty,func(v: String):settings.difficulty=v)
  picker("DemoBattleStyle",t("Style : Défini / Choix","Style: Set / Shift"),["set","shift"],settings.battle_style,func(v: String):a.set_battle_options(v,settings.bag_healing))
  for id: String in ["bag_healing","cap_enabled"]:
   var field: String=id;var control:=CheckButton.new();control.name="Rule_"+id;control.text=t("Soins du sac autorisés en combat","Allow bag healing in battle") if id=="bag_healing" else t("Plafond de niveau actif","Level cap enabled");control.set_pressed_no_signal(settings.get(id));menu.body.add_child(control)
   control.toggled.connect(func(v: bool):
    if not a.in_battle:settings.set(field,v);game.persist_auto())
  picker("DemoExperience",t("Multiplicateur EXP","XP multiplier"),["1","2","3","4","5"],str(settings.exp_multiplier),func(v: String):settings.exp_multiplier=int(v))
  picker("DemoShinyOdds",t("Chance chromatique des nouvelles rencontres : 1/N","New encounter shiny odds: 1/N"),["4096","1024","256","64","1"],str(settings.shiny_odds),func(v: String):settings.shiny_odds=int(v))
  label(t("Réactiver le cap ne diminue aucun niveau. Les soins hors combat restent autorisés. Modes Nuzlocke/Soul-link reportés.","Re-enabling the cap never lowers levels. Out-of-battle healing remains allowed. Nuzlocke/Soul-link deferred."))
 elif page=="bag":
  label(t("Sac • %d ₽","Bag • ₽%d") % a.money)
  var ids: Array=a.bag.keys();ids.sort()
  for id: String in ids:
   if int(a.bag[id])<=0:continue
   var item: String=id
   game.button(menu.body,"%s × %d" % [Catalog.name_of(id,game.locale),a.bag[id]],func():item_page(item),"Bag_"+id)
 elif page=="nursery":
  label(t("Œuf cadeau d’essai : espèces et distribution définitives en attente. Aucune reproduction.","Test gift egg: final species and distribution pending. No breeding."))
  var id: String=Content.data().gift_egg
  var receive: Button=game.button(menu.body,t("Recevoir l’œuf cadeau de %s","Receive gift %s egg") % Catalog.name_of(id,game.locale),func():a.nursery.receive(a,id);game.persist_auto();menu.render(),"ReceiveDemoEgg");receive.disabled=id in a.nursery.received
  for egg: Dictionary in a.nursery.eggs:
   var uid: int=int(egg.mon.uid);label(t("Œuf #%d • %.1f m restants","Egg #%d • %.1f m remaining") % [uid,egg.remaining])
   var hatch: Button=game.button(menu.body,t("Faire éclore #%d","Hatch #%d") % uid,func():
    var result: String=a.nursery.hatch(a,uid);game.persist_auto();menu.render();menu.feedback.text=t("Éclosion : ","Hatching: ")+result,"HatchDemo%d" % uid);hatch.disabled=egg.remaining>0
 elif page=="photo":
  label(t("Cadrage autour du héros de démo, sans déplacement. PNG à la résolution courante.","Frame the demo hero without moving. PNG at current resolution."))
  game.button(menu.body,t("Ouvrir Photo","Open Photo"),func():game.start_photo(),"OpenDemoPhoto")
func item_page(id: String) -> void:
 menu.clear(menu.body);var a: RefCounted=menu.adventure
 label(Catalog.name_of(id,game.locale)+" × "+str(a.bag.get(id,0)))
 var held: bool=id in ["oran-berry","leftovers","lucky-egg","venusaurite","charizardite-x","charizardite-y","blastoisinite"]
 var usable: bool=id in ["potion","antidote","paralyze-heal","thunder-stone","fire-stone"]
 if not held and not usable:label(t("Utilisable dans son contexte : combat, capture ou service.","Use in its context: battle, catching or service."))
 for mon: Dictionary in a.team:
  var uid: int=int(mon.uid)
  if held or usable:
   game.button(menu.body,(t("Équiper : ","Equip: ") if held else t("Utiliser sur : ","Use on: "))+Catalog.name_of(mon.species,game.locale),func():
    var ok: bool=a.equip(uid,id) if held else a.use(id,uid);game.persist_auto();item_page(id);menu.feedback.text=t("Action effectuée.","Action completed.") if ok else t("Aucun effet ou objet absent ; sac conservé.","No effect or item absent; bag preserved."),"ItemTarget%d" % uid)
 game.button(menu.body,t("Retour au sac","Back to bag"),func():menu.render(),"BackToDemoBag")
