extends CanvasLayer
## In-game HUD showing hearts, coins, and interact prompt.

@onready var hearts_container: HBoxContainer = $MarginContainer/HBoxContainer/HeartsContainer
@onready var coins_label: Label = $MarginContainer/HBoxContainer/CoinsLabel

var _heart_nodes: Array[Polygon2D] = []


func _ready() -> void:
	EventBus.hp_changed.connect(_on_hp_changed)
	GameManager.coins_changed.connect(_on_coins_changed)
	_build_hearts(GameManager.max_hp, GameManager.hp)
	_on_coins_changed(GameManager.coins)


func _build_hearts(max_hp: int, current_hp: int) -> void:
	for h in _heart_nodes:
		h.queue_free()
	_heart_nodes.clear()
	for i in range(max_hp):
		var heart := Polygon2D.new()
		# Simple diamond shape for hearts
		heart.polygon = PackedVector2Array([
			Vector2(0, -8), Vector2(8, -2), Vector2(0, 8), Vector2(-8, -2)
		])
		heart.color = Color(0.9, 0.2, 0.25) if i < current_hp else Color(0.3, 0.3, 0.3)
		var container := Control.new()
		container.custom_minimum_size = Vector2(22, 20)
		hearts_container.add_child(container)
		heart.position = Vector2(11, 12)
		container.add_child(heart)
		_heart_nodes.append(heart)


func _on_hp_changed(current: int, max_hp: int) -> void:
	if _heart_nodes.size() != max_hp:
		_build_hearts(max_hp, current)
		return
	for i in range(_heart_nodes.size()):
		_heart_nodes[i].color = Color(0.9, 0.2, 0.25) if i < current else Color(0.3, 0.3, 0.3)
		# Shake animation on damage
		if i == current:
			var tween := _heart_nodes[i].create_tween()
			tween.tween_property(_heart_nodes[i], "position:x", _heart_nodes[i].position.x + 4, 0.03)
			tween.tween_property(_heart_nodes[i], "position:x", _heart_nodes[i].position.x - 4, 0.03)
			tween.tween_property(_heart_nodes[i], "position:x", _heart_nodes[i].position.x, 0.03)


func _on_coins_changed(total: int) -> void:
	coins_label.text = "x %d" % total
