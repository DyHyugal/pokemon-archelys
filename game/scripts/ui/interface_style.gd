extends RefCounted
## Original UI palettes; settings are local, not campaign-owned.
const PALETTES={"dark":["192d40","263f55","eef5ff","66c7dc"],"light":["edf1f5","d3dfe9","182838","286e97"],"contrast":["080808","202020","ffffff","ffdc49"]}
static func box(color: Color,border: Color,width: int=1) -> StyleBoxFlat:
 var style:=StyleBoxFlat.new();style.bg_color=color;style.border_color=border
 style.set_border_width_all(width);style.set_corner_radius_all(5)
 style.content_margin_left=10;style.content_margin_right=10;style.content_margin_top=6;style.content_margin_bottom=6
 return style
static func apply(theme: Theme,palette: String) -> void:
 var colors: Array=PALETTES.get(palette,PALETTES.dark)
 var base:=Color(colors[0]);var raised:=Color(colors[1]);var text:=Color(colors[2]);var accent:=Color(colors[3])
 for type: String in ["Label","Button","CheckButton","CheckBox","OptionButton","ItemList","LineEdit","TextEdit","SpinBox","PopupMenu","RichTextLabel"]:
  theme.set_color("font_color",type,text);theme.set_color("font_hover_color",type,text);theme.set_color("font_pressed_color",type,text)
  theme.set_color("icon_normal_color",type,text);theme.set_color("icon_hover_color",type,text);theme.set_color("icon_pressed_color",type,text)
  theme.set_color("font_focus_color",type,text);theme.set_color("font_disabled_color",type,text.lerp(base,0.45))
 theme.set_color("arrow_color","OptionButton",text)
 theme.set_color("default_color","RichTextLabel",text)
 theme.set_stylebox("panel","PanelContainer",box(base,accent))
 theme.set_stylebox("panel","PopupMenu",box(base,accent))
 for type: String in ["Button","OptionButton"]:
  theme.set_stylebox("normal",type,box(raised,base))
  theme.set_stylebox("hover",type,box(raised.lightened(0.09),accent))
  theme.set_stylebox("pressed",type,box(base,accent,2))
  theme.set_stylebox("disabled",type,box(base,raised))
  var focus:=box(Color.TRANSPARENT,accent,2);theme.set_stylebox("focus",type,focus)
 for type: String in ["LineEdit","TextEdit","ItemList"]:
  theme.set_stylebox("normal",type,box(base,raised));theme.set_stylebox("focus",type,box(base,accent,2))
 theme.set_color("font_hover_color","PopupMenu",text);theme.set_stylebox("hover","PopupMenu",box(raised,accent))
