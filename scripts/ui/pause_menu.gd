extends CanvasLayer
## Pause menu overlay. Toggle with ESC / pause action.

@onready var panel: Control = $PanelContainer
@onready var resume_button: Button = $PanelContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $PanelContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $PanelContainer/VBoxContainer/QuitButton

var _paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_resume)
	restart_button.pressed.connect(_restart)
	quit_button.pressed.connect(_quit)
	panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()
		get_viewport().set_input_as_handled()


func _toggle_pause() -> void:
	_paused = not _paused
	get_tree().paused = _paused
	panel.visible = _paused
	if _paused:
		resume_button.grab_focus()


func _resume() -> void:
	_paused = false
	get_tree().paused = false
	panel.visible = false


func _restart() -> void:
	_paused = false
	get_tree().paused = false
	GameManager.restart_level()


func _quit() -> void:
	_paused = false
	get_tree().paused = false
	GameManager.go_to_main_menu()
