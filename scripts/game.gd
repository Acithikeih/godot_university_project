extends Node2D

@export var play_area_rect = Rect2(20, 20, 800, 600)

@onready var background = $Space/Background
@onready var player = $Space/Clip/Player
@onready var clip = $Space/Clip
@onready var projectiles = $Space/Clip/Projectiles

@onready var time_label = $UI/VBoxContainer/Time
@onready var graze_label = $UI/VBoxContainer/Graze

@onready var pause_menu = $PauseMenu
@onready var game_over_menu = $GameOverMenu

var projectile_scene = preload("res://scenes/projectile.tscn")
var settings_scene = preload("res://scenes/settings.tscn")
var settings_instance = null

func _ready() -> void:
	# Set background size and position
	background.position = play_area_rect.position
	background.size = play_area_rect.size
	
	clip.position = play_area_rect.position
	clip.size = play_area_rect.size

	# Pass play area to player
	player.play_area = Rect2(play_area_rect.position, play_area_rect.size)
	
	player.player_hit.connect(_on_player_hit)
	player.player_grazed.connect(_on_player_grazed)
	
	GameManager.graze_updated.connect(_on_graze_updated)
	GameManager.time_updated.connect(_on_time_updated)

	pause_menu.resume_pressed.connect(_on_pause_resume)
	pause_menu.settings_pressed.connect(_on_pause_settings)
	pause_menu.exit_pressed.connect(_on_pause_exit)
	
	# Connect game over menu signals
	game_over_menu.exit_pressed.connect(_on_game_over_exit)

	# Start game
	GameManager.start_game()
	update_ui()

func _process(delta):
	if not get_tree().paused:
		GameManager.update_time(delta)

func _input(event):
	if event.is_action_pressed("Pause") and settings_instance == null and not pause_menu.visible:
		pause_menu.show_menu()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_accept"):  # SPACE key
		spawn_test_projectile()

func spawn_test_projectile():
	var projectile = projectile_scene.instantiate()

	# Spawn at top center of play area (relative to ClipRect)
	projectile.position = Vector2(play_area_rect.size.x / 2, 0)

	# Set direction (downward)
	projectile.set_direction(Vector2.DOWN)

	# Set speed (optional, uses default if not set)
	projectile.speed = 150.0

	# Add to container
	projectiles.add_child(projectile)

# Generic spawn function you'll use later
func spawn_projectile(pos: Vector2, dir: Vector2, projectile_speed: float = 200.0):
	var projectile = projectile_scene.instantiate()
	projectile.position = pos
	projectile.set_direction(dir)
	projectile.speed = projectile_speed
	projectiles.add_child(projectile)

func _on_player_hit():
	GameManager.stop_game()
	game_over_menu.show_game_over(GameManager.get_time(), GameManager.get_graze_count())

func _on_player_grazed():
	GameManager.increment_graze()

func _on_graze_updated(new_count):
	graze_label.text = "%d" % new_count

func _on_time_updated(new_time):
	time_label.text = "%.2f" % new_time

func update_ui():
	time_label.text = "%.2f" % GameManager.get_time()
	graze_label.text = "%d" % GameManager.get_graze_count()

func _on_pause_resume():
	# Already handled by pause_menu.hide_menu()
	pass

func _on_pause_settings():
	# Hide pause menu temporarily
	pause_menu.hide()

	settings_instance = settings_scene.instantiate()
	settings_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_instance.came_from_game = true
	add_child(settings_instance)

	# Connect back signal
	settings_instance.back_pressed.connect(_on_settings_back)

func _on_settings_back():
	# Remove settings
	if settings_instance:
		settings_instance.queue_free()
		settings_instance = null

	# Show pause menu again
	pause_menu.show()

func _on_pause_exit():
	# Unpause before changing scene
	get_tree().paused = false
	GameManager.stop_game()
	SceneManager.change_scene("res://scenes/menu.tscn")

func _on_game_over_exit():
	# Unpause before changing scene
	get_tree().paused = false
	GameManager.stop_game()
	SceneManager.change_scene("res://scenes/menu.tscn")
