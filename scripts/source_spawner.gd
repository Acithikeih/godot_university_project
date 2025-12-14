extends Node2D


@export var play_area_size = Vector2(800, 600)
@export var play_area_position = Vector2(20, 20)
@export var safe_radius = 100.0
@export var spawn_interval_min = 2.0
@export var spawn_interval_max = 5.0
@export var enabled = true


var source_scene = preload("res://scripts/projectile_source.gd")
var player: Node2D = null
var projectile_container: Node2D = null


@onready var spawn_timer = Timer.new()


func _ready() -> void:
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	start_spawning()


func set_player_reference(p: Node2D) -> void:
	player = p


func set_projectile_container(container: Node2D) -> void:
	projectile_container = container


func start_spawning() -> void:
	if enabled:
		spawn_timer.start(randf_range(spawn_interval_min, spawn_interval_max))


func _on_spawn_timer_timeout() -> void:
	spawn_random_source()
	spawn_timer.start(randf_range(spawn_interval_min, spawn_interval_max))


func spawn_random_source() -> void:
	if not player or not projectile_container:
		return

	var spawn_pos = get_safe_spawn_position()

	var source = Node2D.new()
	source.position = spawn_pos
	source.set_script(source_scene)

	source.position_offset = play_area_position
	source.pattern_type = randi() % 5
	source.projectile_speed = randf_range(100.0, 200.0)
	source.projectile_color = get_random_color()
	source.shots_per_wave = randi_range(8, 16)
	source.wave_interval = randf_range(0.5, 1.5)
	source.rotation_speed = randf_range(-2.0, 2.0)
	source.total_waves = randi_range(3, 6)
	source.lifetime = randf_range(8.0, 15.0)

	projectile_container.add_child(source)
	source.set_player_reference(player)


func get_safe_spawn_position() -> Vector2:
	var max_attempts = 20
	var spawn_pos = Vector2.ZERO

	for attempt in range(max_attempts):
		spawn_pos = Vector2(
			randf_range(20, play_area_size.x - 20),
			randf_range(20, play_area_size.y - 20)
		)

		var distance_to_player = spawn_pos.distance_to(player.position)
		if distance_to_player >= safe_radius:
			return spawn_pos

	return Vector2(play_area_size.x / 2, 0) # if couldn't find safe position in max_attemps


func get_random_color() -> Color:
	var colors = [
		Color.RED,
		Color.ORANGE,
		Color.YELLOW,
		Color.CYAN,
		Color.MAGENTA,
		Color.LIME_GREEN
	]
	return colors[randi() % colors.size()]
