extends CanvasLayer


@onready var resume_button = $VBoxContainer/Resume
@onready var settings_button = $VBoxContainer/Settings
@onready var exit_button = $VBoxContainer/Quit

signal resume_pressed
signal settings_pressed
signal exit_pressed

func _ready():
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	# Hide by default
	hide()

	# Make sure this menu works when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		_on_resume_pressed()

func show_menu():
	show()
	get_tree().paused = true

func hide_menu():
	hide()
	get_tree().paused = false

func _on_resume_pressed():
	hide_menu()
	emit_signal("resume_pressed")

func _on_settings_pressed():
	emit_signal("settings_pressed")

func _on_exit_pressed():
	emit_signal("exit_pressed")
