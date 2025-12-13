extends Node2D

enum PatternType {
	CIRCULAR,
	AIMED,
	SPIRAL,
	BURST,
	RING
}

@export var pattern_type: PatternType = PatternType.CIRCULAR
@export var projectile_speed = 150.0
@export var projectile_color = Color.RED
@export var shots_per_wave = 12
@export var wave_interval = 1.0  # Time between waves
@export var rotation_speed = 0.0  # For spiral patterns
@export var total_waves = 5  # How many waves before despawning
@export var lifetime = 10.0  # Auto-despawn after this time

var projectile_scene = preload("res://scenes/projectile.tscn")
var player: Node2D = null
var waves_fired = 0
var current_angle = 0.0
var position_offset = Vector2(0.0, 0.0)

@onready var wave_timer = Timer.new()

func _ready() -> void:
	# Setup timer
	add_child(wave_timer)
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	wave_timer.start(wave_interval)

	# Auto-despawn after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()
	queue_redraw()

func _draw() -> void:
	draw_circle(position_offset, 4.0, Color.WHITE)

func set_player_reference(p: Node2D) -> void:
	player = p

func _process(delta) -> void:
	# Update angle for spiral patterns
	if pattern_type == PatternType.SPIRAL:
		current_angle += rotation_speed * delta

func _on_wave_timer_timeout() -> void:
	fire_pattern()
	waves_fired += 1

	# Despawn after firing all waves
	if waves_fired >= total_waves:
		wave_timer.stop()
		await get_tree().create_timer(2.0).timeout  # Wait a bit before despawning
		queue_free()

func fire_pattern() -> void:
	match pattern_type:
		PatternType.CIRCULAR:
			fire_circular()
		PatternType.AIMED:
			fire_aimed()
		PatternType.SPIRAL:
			fire_spiral()
		PatternType.BURST:
			fire_burst()
		PatternType.RING:
			fire_ring()

func fire_circular() -> void:
	# Fire projectiles in all directions
	for i in range(shots_per_wave):
		var angle = (i / float(shots_per_wave)) * TAU
		spawn_projectile(angle)

func fire_aimed() -> void:
	# Fire projectiles aimed at player
	if not player:
		fire_circular()  # Fallback
		return

	var base_angle = global_position.angle_to_point(player.global_position)
	var spread = deg_to_rad(30)  # 30 degree spread

	for i in range(shots_per_wave):
		var offset = (i / float(shots_per_wave - 1) - 0.5) * spread
		spawn_projectile(base_angle + offset)

func fire_spiral() -> void:
	# Fire projectiles in a rotating pattern
	for i in range(shots_per_wave):
		var angle = current_angle + (i / float(shots_per_wave)) * TAU
		spawn_projectile(angle)

func fire_burst() -> void:
	# Fire multiple waves in quick succession
	for wave in range(3):
		await get_tree().create_timer(0.1).timeout
		for i in range(shots_per_wave / 3):
			var angle = (i / float(shots_per_wave / 3)) * TAU + wave * 0.2
			spawn_projectile(angle)

func fire_ring() -> void:
	# Fire a dense ring of projectiles
	var num_projectiles = shots_per_wave * 2
	for i in range(num_projectiles):
		var angle = (i / float(num_projectiles)) * TAU
		spawn_projectile(angle)

func spawn_projectile(angle: float) -> void:
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position

	var direction = Vector2(cos(angle), sin(angle))
	projectile.set_direction(direction)
	projectile.speed = projectile_speed
	projectile.projectile_color = projectile_color

	# Add to parent's projectile container
	get_parent().add_child(projectile)
