extends RefCounted
## Standard Xbox/Godot layout. GUI retains native accept and directional focus.
static func stick(value: Vector2) -> Vector2:
 var magnitude: float=value.length()
 if magnitude<=0.22:return Vector2.ZERO
 return value.normalized()*minf(1.0,(magnitude-0.22)/0.78)
static func key_for(event: InputEventJoypadButton,world: Node) -> int:
 if not event.pressed:return 0
 if event.button_index==JOY_BUTTON_START:return KEY_ESCAPE
 var modal: bool=world.atlas_studio.active or world.photo_mode.active or world.cinematic.active or world.battle_panel.visible or world.pause_menu.visible or world.dialogue.active
 if event.button_index==JOY_BUTTON_B and modal:return KEY_ESCAPE
 if event.button_index==JOY_BUTTON_A:
  if world.dialogue.active or world.cinematic.active:return KEY_ENTER
  if world.battle_panel.visible and not world.battle_panel.journal_open and world.battle_panel.event_index<world.pokemon_battle.events.size():return KEY_ENTER
  if not modal:return int(world.comfort.keys("interact")[0])
 if not modal and event.button_index==JOY_BUTTON_X:return int(world.comfort.keys("bag")[0])
 if not modal and event.button_index==JOY_BUTTON_Y:return int(world.comfort.keys("journal")[0])
 return 0
