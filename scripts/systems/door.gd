extends Area2D
## Door that transitions the player to another room.

@export var door_id: String = ""  ## Unique ID within this room.
@export var target_room_id: String = ""  ## Room to transition to.
@export var target_door_id: String = ""  ## Door in target room to spawn at.
@export var requires_ability: String = ""  ## Empty = no requirement.
@export var locked: bool = false
@export var auto_enter: bool = false  ## True = walk in, false = press interact.

var _player_inside: bool = false


func _ready() -> void:
	add_to_group("doors")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside:
		return
	if auto_enter:
		return
	if event.is_action_pressed("interact"):
		_enter_door()
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = true
	if auto_enter:
		_enter_door()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false


func _enter_door() -> void:
	if target_room_id.is_empty():
		return
	if locked:
		return
	if not requires_ability.is_empty() and not AbilityManager.has_ability(requires_ability):
		return
	EventBus.door_entered.emit(target_room_id, target_door_id)
	GameManager.change_room(target_room_id, target_door_id)
