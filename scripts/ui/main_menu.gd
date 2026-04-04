extends Control
## Main menu: New Game, Continue (if save exists), Quit.

@onready var title_label: Label = $VBoxContainer/Title
@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game)
	continue_button.pressed.connect(_on_continue)
	quit_button.pressed.connect(_on_quit)

	# Show/hide continue based on save existence
	continue_button.visible = SaveManager.has_save()

	if continue_button.visible:
		continue_button.grab_focus()
	else:
		new_game_button.grab_focus()

	_animate_title()
	_style_buttons()


func _animate_title() -> void:
	title_label.pivot_offset = title_label.size / 2.0
	title_label.scale = Vector2(0.5, 0.5)
	var tween := create_tween()
	tween.tween_property(title_label, "scale", Vector2.ONE, 0.5) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _style_buttons() -> void:
	for btn: Button in [new_game_button, continue_button, quit_button]:
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.2, 0.35, 0.55)
		normal.corner_radius_top_left = 6
		normal.corner_radius_top_right = 6
		normal.corner_radius_bottom_left = 6
		normal.corner_radius_bottom_right = 6
		normal.content_margin_left = 16
		normal.content_margin_right = 16
		normal.content_margin_top = 8
		normal.content_margin_bottom = 8
		btn.add_theme_stylebox_override("normal", normal)
		var hover := normal.duplicate()
		hover.bg_color = Color(0.25, 0.42, 0.65)
		btn.add_theme_stylebox_override("hover", hover)
		var focus := normal.duplicate()
		focus.bg_color = Color(0.25, 0.42, 0.65)
		focus.border_width_left = 2
		focus.border_width_right = 2
		focus.border_width_top = 2
		focus.border_width_bottom = 2
		focus.border_color = Color(0.5, 0.7, 1.0)
		btn.add_theme_stylebox_override("focus", focus)


func _on_new_game() -> void:
	SaveManager.delete_save()
	GameManager.start_game()


func _on_continue() -> void:
	SaveManager.load_game()
	# Resume from last bench
	RoomManager.change_room(GameManager.last_bench_room, GameManager.last_bench_door)


func _on_quit() -> void:
	get_tree().quit()
