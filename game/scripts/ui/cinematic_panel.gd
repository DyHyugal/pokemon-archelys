extends CanvasLayer
signal advance_requested
signal skip_requested
var text: Label
var heading: Label
var next_button: Button
var skip_button: Button
var model: RefCounted
var locale: String="fr"
func _ready() -> void:
 layer=15
 for bottom: bool in [false,true]:
  var bar:=ColorRect.new();bar.color=Color(0.02,0.03,0.05,0.96);bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE if bottom else Control.PRESET_TOP_WIDE)
  if bottom:bar.offset_top=-210
  else:bar.offset_bottom=55
  add_child(bar)
 var box:=VBoxContainer.new();box.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);box.offset_left=80;box.offset_right=-80;box.offset_top=-190;box.offset_bottom=-15;add_child(box)
 heading=Label.new();heading.add_theme_font_size_override("font_size",20);box.add_child(heading)
 text=Label.new();text.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;text.size_flags_vertical=Control.SIZE_EXPAND_FILL;box.add_child(text)
 var actions:=HBoxContainer.new();box.add_child(actions)
 next_button=Button.new();next_button.name="NextShot";next_button.custom_minimum_size=Vector2(330,36);actions.add_child(next_button);next_button.pressed.connect(func():advance_requested.emit())
 skip_button=Button.new();skip_button.name="SkipScene";skip_button.custom_minimum_size=Vector2(250,36);actions.add_child(skip_button);skip_button.pressed.connect(func():skip_requested.emit())
 visible=false
func render(timeline: RefCounted,language: String) -> void:
 model=timeline;locale=language;visible=model.active
 if not visible:return
 var entry: Dictionary=model.library()[model.id]
 heading.text="%s · %d/%d" % [entry.names[locale],model.index+1,entry.steps.size()]
 text.text=model.current()[locale]
 next_button.text="Suite • E / Entrée" if locale=="fr" else "Next • E / Enter"
 skip_button.text="Passer • Échap" if locale=="fr" else "Skip • Esc";skip_button.visible=entry.skippable
 next_button.grab_focus()
func handle_key(event: InputEvent) -> bool:
 if not event is InputEventKey or not event.pressed or event.echo:return false
 if event.keycode in [KEY_E,KEY_ENTER,KEY_A,KEY_SPACE]:advance_requested.emit();return true
 if event.keycode==KEY_ESCAPE:skip_requested.emit();return true
 return false
