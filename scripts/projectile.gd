extends Area2D

@export var speed = 200.0
@export var projectile_radius = 20.0
@export var projectile_color = Color.RED
@export var hitbox_radius = 5.0

var direction = Vector2.DOWN  # Default direction
var has_grazed = false  # Track if this projectile has been grazed

func _ready() -> void:
	$CollisionShape2D.scale = Vector2(hitbox_radius / projectile_radius, hitbox_radius / projectile_radius)
	collision_layer = 2  # Projectile layer
	collision_mask = 5

func _draw() -> void:
	# Draw filled circle
	draw_circle(Vector2.ZERO, projectile_radius, projectile_color)

func _process(delta) -> void:
	# Move in the set direction
	global_position += direction * speed * delta

	# Delete if far outside play area (cleanup)
	if global_position.length() > 2000:
		queue_free()

func set_direction(new_direction: Vector2) -> void:
	direction = new_direction.normalized()

func set_velocity(velocity: Vector2) -> void:
	direction = velocity.normalized()
	speed = velocity.length()

func is_grazed() -> bool:
	return has_grazed

func mark_as_grazed():
	has_grazed = true
