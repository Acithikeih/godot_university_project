extends CanvasLayer


@onready var resume_button = $VBoxContainer/Resume
@onready var settings_button = $VBoxContainer/Settings
@onready var exit_button = $VBoxContainer/Quit

signal resume_pressed
signal settings_pressed
signal exit_pressed

func _ready() -> void:
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	# Hide by default
	hide()

	# Make sure this menu works when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event) -> void:
	if visible and event.is_action_pressed("Pause"):
		_on_resume_pressed()
		get_viewport().set_input_as_handled()

func show_menu() -> void:
	show()
	get_tree().paused = true

func hide_menu() -> void:
	hide()
	get_tree().paused = false

func _on_resume_pressed() -> void:
	hide_menu()
	emit_signal("resume_pressed")

func _on_settings_pressed() -> void:
	emit_signal("settings_pressed")

func _on_exit_pressed() -> void:
	emit_signal("exit_pressed")
