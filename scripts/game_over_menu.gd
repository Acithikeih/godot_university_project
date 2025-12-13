extends CanvasLayer

@onready var title_label = $VBoxContainer/Title
@onready var time_label = $VBoxContainer/Time/Value
@onready var graze_label = $VBoxContainer/Graze/Value
@onready var exit_button = $VBoxContainer/Quit

signal exit_pressed

func _ready():
	# Connect button signal
	exit_button.pressed.connect(_on_exit_pressed)

	# Hide by default
	hide()

	# Make sure this menu works when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_game_over(time: float, graze: int):
	# Update stats
	time_label.text = "%.2f" % time
	graze_label.text = "%d" % graze

	# Show menu
	show()
	get_tree().paused = true

func _on_exit_pressed():
	emit_signal("exit_pressed")
