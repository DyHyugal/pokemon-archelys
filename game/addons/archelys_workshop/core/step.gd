@tool
extends Resource
## Declarative data only: no arbitrary code or console bytecode execution.
@export_enum("dialogue", "set_flag", "require_flag", "give_item", "battle", "warp") var action: String = "dialogue"
@export var key: String = ""
@export_multiline var french: String = ""
@export_multiline var english: String = ""
@export var value: bool = true
@export_range(1, 999) var quantity: int = 1
@export var destination: Vector3 = Vector3.ZERO
