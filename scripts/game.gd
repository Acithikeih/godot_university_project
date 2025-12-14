extends Node2D


@export var play_area_rect = Rect2(20, 20, 800, 600)


@onready var background = $Space/Background
@onready var player = $Space/Clip/Player
@onready var clip = $Space/Clip
@onready var projectiles = $Space/Clip/Projectiles
@onready var source_spawner = $Space/Clip/SourceSpawner
@onready var time_label = $UI/VBoxContainer/Time/Value
@onready var graze_label = $UI/VBoxContainer/Graze/Value
@onready var pause_menu = $PauseMenu
@onready var game_over_menu = $GameOverMenu


var projectile_scene = preload("res://scenes/projectile.tscn")
var settings_scene = preload("res://scenes/settings.tscn")
var settings_instance = null


func _ready() -> void:
	background.position = play_area_rect.position
	background.size = play_area_rect.size
	clip.position = play_area_rect.position
	clip.size = play_area_rect.size
	player.play_area = Rect2(play_area_rect.position, play_area_rect.size)
	source_spawner.play_area_size = play_area_rect.size
	source_spawner.play_area_position = play_area_rect.position
	source_spawner.set_player_reference(player)
	source_spawner.set_projectile_container(projectiles)
	
	GameManager.graze_updated.connect(_on_graze_updated)
	GameManager.time_updated.connect(_on_time_updated)
	player.player_hit.connect(_on_player_hit)
	player.player_grazed.connect(_on_player_grazed)
	pause_menu.resume_pressed.connect(_on_pause_resume)
	pause_menu.settings_pressed.connect(_on_pause_settings)
	pause_menu.quit_pressed.connect(_on_pause_quit)
	game_over_menu.quit_pressed.connect(_on_game_over_quit)

	GameManager.start_game()
	time_label.text = "0.00"
	graze_label.text = "0"


func _process(delta) -> void:
	if not get_tree().paused:
		GameManager.update_time(delta)


func _input(event) -> void:
	if event.is_action_pressed("Pause") and not pause_menu.visible:
		pause_menu.show_menu()
		get_viewport().set_input_as_handled() # blocking ui input


func _on_player_hit() -> void:
	GameManager.stop_game()
	game_over_menu.show_game_over(GameManager.get_time(), GameManager.get_graze_count())


func _on_player_grazed() -> void:
	GameManager.increment_graze()


func _on_graze_updated(new_count) -> void:
	graze_label.text = "%d" % new_count


func _on_time_updated(new_time) -> void:
	time_label.text = "%.2f" % new_time


func _on_pause_resume() -> void:
	# handled in pause_menu/_on_resume_pressed
	pass


func _on_pause_settings() -> void:
	pause_menu.hide()

	settings_instance = settings_scene.instantiate()
	settings_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_instance.came_from_game = true
	add_child(settings_instance)
	settings_instance.back_pressed.connect(_on_settings_back)


func _on_settings_back() -> void:
	if settings_instance:
		settings_instance.queue_free()
		settings_instance = null

	pause_menu.show()


func _on_pause_quit() -> void:
	get_tree().paused = false # otherwise game will freeze
	GameManager.stop_game()
	SceneManager.change_scene("res://scenes/menu.tscn")


func _on_game_over_quit() -> void:
	get_tree().paused = false # same as above
	GameManager.stop_game()
	SceneManager.change_scene("res://scenes/menu.tscn")
