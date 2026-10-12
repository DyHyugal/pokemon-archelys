extends "res://scripts/ui/pokemon_battle_panel.gd"
var enemy_label: Label
var player_label: Label
var enemy_hp: ProgressBar
var player_hp: ProgressBar
var action_panel: PanelContainer
func _ready() -> void:
 layer=45
 panel=PanelContainer.new();panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);panel.offset_left=24;panel.offset_right=-410;panel.offset_top=-205;panel.offset_bottom=-20;add_child(panel)
 var column:=VBoxContainer.new();panel.add_child(column)
 cards=Label.new();cards.hide();column.add_child(cards)
 message=Label.new();message.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;message.size_flags_vertical=Control.SIZE_EXPAND_FILL;column.add_child(message)
 action_panel=PanelContainer.new();action_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT);action_panel.offset_left=-390;action_panel.offset_right=-24;action_panel.offset_top=-300;action_panel.offset_bottom=-20;add_child(action_panel)
 var scroll:=ScrollContainer.new();scroll.follow_focus=true;action_panel.add_child(scroll)
 actions=VBoxContainer.new();actions.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(actions)
 var enemy:=PanelContainer.new();enemy.position=Vector2(28,30);enemy.custom_minimum_size=Vector2(320,90);add_child(enemy)
 var enemy_box:=VBoxContainer.new();enemy.add_child(enemy_box);enemy_label=Label.new();enemy_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;enemy_box.add_child(enemy_label);enemy_hp=ProgressBar.new();enemy_hp.show_percentage=false;enemy_hp.custom_minimum_size.y=14;enemy_box.add_child(enemy_hp)
 var player:=PanelContainer.new();player.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT);player.offset_left=-380;player.offset_right=-28;player.offset_top=30;player.offset_bottom=130;add_child(player)
 var player_box:=VBoxContainer.new();player.add_child(player_box);player_label=Label.new();player_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;player_box.add_child(player_label);player_hp=ProgressBar.new();player_hp.show_percentage=false;player_hp.custom_minimum_size.y=14;player_box.add_child(player_hp)
 for bar: ProgressBar in [player_hp,enemy_hp]:
  var fill:=StyleBoxFlat.new();fill.bg_color=Color("79b674");fill.set_corner_radius_all(6);bar.add_theme_stylebox_override("fill",fill)
  var background:=StyleBoxFlat.new();background.bg_color=Color("dce4d1");background.set_corner_radius_all(6);bar.add_theme_stylebox_override("background",background)
 visible=false
func render() -> void:
 super.render()
 if not battle:return
 var p: Dictionary=battle.current(0);var e: Dictionary=battle.current(1)
 enemy_label.text="%s • Nv.%d\n%s" % [name_of(e.species),e.level,Catalog.text("status_names",e.status,locale)]
 player_label.text="%s • Nv.%d • %d/%d PV\n%s" % [name_of(p.species),p.level,p.hp,Mon.stats(p).hp,Catalog.text("status_names",p.status,locale)]
 enemy_hp.max_value=Mon.stats(e).hp;enemy_hp.value=e.hp;player_hp.max_value=Mon.stats(p).hp;player_hp.value=p.hp
