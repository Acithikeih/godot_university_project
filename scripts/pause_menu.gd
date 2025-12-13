extends CanvasLayer


@onready var resume_button = $VBoxContainer/Resume
@onready var settings_button = $VBoxContainer/Settings
@onready var quit_button = $VBoxContainer/Quit


signal resume_pressed
signal settings_pressed
signal quit_pressed


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	hide() # hidden by default
	process_mode = Node.PROCESS_MODE_ALWAYS # to bypass get_tree().paused


func _input(event) -> void:
	if visible and event.is_action_pressed("Pause"):
		_on_resume_pressed()
		get_viewport().set_input_as_handled() # to block ui action


func show_menu() -> void:
	show()
	get_tree().paused = true


func hide_menu() -> void:
	hide()
	get_tree().paused = false


func _on_resume_pressed() -> void:
	hide_menu()
	resume_pressed.emit()


func _on_settings_pressed() -> void:
	settings_pressed.emit()


func _on_quit_pressed() -> void:
	quit_pressed.emit()
