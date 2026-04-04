extends Area2D
## Grants a permanent ability when the player interacts.

@export var ability_name: String = "dash"
@export var display_name: String = "Shadow Dash"
@export var description: String = "Press SHIFT to dash."
@export var glow_color: Color = Color(0.4, 0.8, 1.0)

var _collected: bool = false
var _player_inside: bool = false
var _time: float = 0.0

@onready var visuals: Node2D = $Visuals
@onready var prompt_label: Label = $PromptLabel


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Hide if already collected
	if AbilityManager.has_ability(ability_name):
		queue_free()
		return
	prompt_label.visible = false


func _process(delta: float) -> void:
	_time += delta
	# Floating bob + glow pulse
	visuals.position.y = sin(_time * 2.0) * 6.0
	var pulse: float = 0.7 + sin(_time * 3.0) * 0.3
	visuals.modulate = glow_color * pulse


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside or _collected:
		return
	if event.is_action_pressed("interact"):
		_collect()
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		prompt_label.visible = false


func _collect() -> void:
	_collected = true
	AbilityManager.unlock(ability_name)
	SaveManager.save_game()
	EventBus.screen_shake_requested.emit(5.0, 0.15)
	EventBus.hitstop_requested.emit(0.08)
	# TODO: Show "Ability Acquired!" overlay
	# For now, just sparkle and disappear
	var tween := create_tween()
	tween.tween_property(visuals, "scale", Vector2(3, 3), 0.3).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(visuals, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
