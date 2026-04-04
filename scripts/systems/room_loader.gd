extends Node2D
## Attach to the root of every room scene. Spawns the player on _ready.

@export var room_id: String = ""


func _ready() -> void:
	if not room_id.is_empty():
		RoomManager.current_room_id = room_id
	# Spawn the player at the correct door
	call_deferred("_spawn_player")


func _spawn_player() -> void:
	RoomManager.spawn_player_in_room(self)
