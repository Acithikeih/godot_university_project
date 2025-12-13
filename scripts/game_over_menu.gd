extends CanvasLayer


@onready var time_label = $VBoxContainer/Time/Value
@onready var graze_label = $VBoxContainer/Graze/Value
@onready var quit_button = $VBoxContainer/Quit


signal quit_pressed


func _ready() -> void:
	quit_button.pressed.connect(_on_quit_pressed)
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS


func show_game_over(time: float, graze: int) -> void:
	time_label.text = "%.2f" % time
	graze_label.text = "%d" % graze

	show()
	get_tree().paused = true


func _on_quit_pressed() -> void:
	quit_pressed.emit()
