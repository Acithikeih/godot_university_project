extends CanvasLayer


var awaiting_input = false
var current_action = ""
var previous_key = 0
var came_from_game = false


signal back_pressed


@onready var key_buttons = {
	"MoveUp": $SettingsContainer/KeyMoveUp/Button,
	"MoveDown": $SettingsContainer/KeyMoveDown/Button,
	"MoveLeft": $SettingsContainer/KeyMoveLeft/Button,
	"MoveRight": $SettingsContainer/KeyMoveRight/Button,
	"Focus": $SettingsContainer/KeyFocus/Button,
	"Pause": $SettingsContainer/KeyPause/Button,
}


func _ready() -> void:
	update_key_labels()
	
	for action in key_buttons:
		key_buttons[action].pressed.connect(_on_key_button_pressed.bind(action))
	
	$SettingsContainer/Back.pressed.connect(_on_back_pressed)
	
	came_from_game = get_tree().paused # if game paused then settings menu was accesed through pause menu 
	if came_from_game:
		process_mode = Node.PROCESS_MODE_ALWAYS


func update_key_labels() -> void:
	for key in key_buttons:
		var keycode = InputManager.get_key(key)
		key_buttons[key].text = OS.get_keycode_string(keycode)


func _on_key_button_pressed(action: String) -> void:
	awaiting_input = true
	current_action = action
	key_buttons[action].text = "Input key..."


func is_key_used(key: int, exclude_action: String) -> bool:
	for action in key_buttons:
		if action == exclude_action:
			continue
		if InputManager.get_key(action) == key:
			return true
	return false


func _input(event) -> void:
	if not awaiting_input:
		return

	if event is InputEventKey and event.pressed:
		var key = event.physical_keycode if event.physical_keycode != 0 else event.keycode

		if not is_key_used(key, current_action):
			InputManager.rebind_key(current_action, key)
			InputManager.save_keys()

		update_key_labels()

		awaiting_input = false
		current_action = ""
		get_viewport().set_input_as_handled() # without that ui action activets after rebinding


func _on_back_pressed() -> void:
	if came_from_game:
		back_pressed.emit()
	else:
		SceneManager.change_scene("res://scenes/menu.tscn")
