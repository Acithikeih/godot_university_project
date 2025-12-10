extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MenuContainer/Start.pressed.connect(_on_start_pressed)
	$MenuContainer/Settings.pressed.connect(_on_settings_pressed)
	$MenuContainer/Quit.pressed.connect(_on_quit_pressed)


func _on_start_pressed():
	SceneManager.change_scene("res://scenes/game.tscn")

func _on_settings_pressed():
	SceneManager.change_scene("res://scenes/settings.tscn")

func _on_quit_pressed():
	get_tree().quit()
