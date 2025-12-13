extends Area2D

# Movement speeds
@export var normal_speed = 200.0
@export var focused_speed = 100.0

# Play area bounds (you can adjust these)
@export var play_area = Rect2()
@export var initial_position = Vector2(50, 50)

@export var player_radius = 20.0
@export var hitbox_radius = 5.0
@export var graze_radius = 30.0
@export var player_color = Color.MAGENTA
@export var hitbox_color = Color.RED

var current_speed = normal_speed
# Track most recent keys
var last_horizontal = ""  # "left" or "right"
var last_vertical = ""    # "up" or "down"

@onready var graze_area = $GrazeArea

signal player_hit
signal player_grazed

func _draw() -> void:
	draw_circle(Vector2.ZERO, player_radius, player_color)
	draw_circle(Vector2.ZERO, hitbox_radius, hitbox_color)

func _ready() -> void:
	# Position player at center of play area
	$CollisionShape2D.scale = Vector2(hitbox_radius / player_radius, hitbox_radius / player_radius)
	$GrazeArea/CollisionShape2D.scale = Vector2(graze_radius / player_radius, graze_radius / player_radius)
	global_position = Vector2(play_area.position.x + initial_position.x, play_area.position.y + initial_position.y)
	
	area_entered.connect(_on_projectile_hit)
	graze_area.area_entered.connect(_on_projectile_grazed)

func _on_projectile_hit(projectile):
	# Player was hit - game over
	emit_signal("player_hit")
	print("Player hit! Game Over")

func _on_projectile_grazed(projectile):
	# Check if this projectile has already been grazed
	if projectile.has_method("is_grazed") and not projectile.is_grazed():
		projectile.mark_as_grazed()
		emit_signal("player_grazed")
		print("Grazed!")

func _input(event) -> void:
	if event.is_action_pressed("MoveLeft"):
		last_horizontal = "left"
	elif event.is_action_pressed("MoveRight"):
		last_horizontal = "right"
	elif event.is_action_released("MoveLeft") and last_horizontal == "left":
		# If releasing left and right is still held, switch to right
		if Input.is_action_pressed("MoveRight"):
			last_horizontal = "right"
		else:
			last_horizontal = ""
	elif event.is_action_released("MoveRight") and last_horizontal == "right":
		# If releasing right and left is still held, switch to left
		if Input.is_action_pressed("MoveLeft"):
			last_horizontal = "left"
		else:
			last_horizontal = ""

	if event.is_action_pressed("MoveUp"):
		last_vertical = "up"
	elif event.is_action_pressed("MoveDown"):
		last_vertical = "down"
	elif event.is_action_released("MoveUp") and last_vertical == "up":
		# If releasing up and down is still held, switch to down
		if Input.is_action_pressed("MoveDown"):
			last_vertical = "down"
		else:
			last_vertical = ""
	elif event.is_action_released("MoveDown") and last_vertical == "down":
		# If releasing down and up is still held, switch to up
		if Input.is_action_pressed("MoveUp"):
			last_vertical = "up"
		else:
			last_vertical = ""

func _process(delta) -> void:
	var velocity = Vector2.ZERO

	# Use the most recently pressed direction
	if last_horizontal == "left":
		velocity.x = -1
	elif last_horizontal == "right":
		velocity.x = 1

	if last_vertical == "up":
		velocity.y = -1
	elif last_vertical == "down":
		velocity.y = 1
	
	# Normalize diagonal movement so it's not faster
	if velocity.length() > 0:
		velocity = velocity.normalized()
	
	# Check if focused (slow movement)
	if Input.is_action_pressed("Focus"):
		current_speed = focused_speed
	else:
		current_speed = normal_speed
	
	# Apply movement
	global_position += velocity * current_speed * delta
	
	# Clamp position to play area bounds
	global_position.x = clamp(global_position.x, play_area.position.x, play_area.position.x + play_area.size.x)
	global_position.y = clamp(global_position.y, play_area.position.y, play_area.position.y + play_area.size.y)

func _notification(what):
	if what == NOTIFICATION_PAUSED or what == NOTIFICATION_UNPAUSED:
		# Reset movement state when pausing/unpausing
		reset_movement_state()

func reset_movement_state():
	# Check actual key states and update movement
	if Input.is_action_pressed("MoveLeft"):
		last_horizontal = "left"
	elif Input.is_action_pressed("MoveRight"):
		last_horizontal = "right"
	else:
		last_horizontal = ""

	if Input.is_action_pressed("MoveUp"):
		last_vertical = "up"
	elif Input.is_action_pressed("MoveDown"):
		last_vertical = "down"
	else:
		last_vertical = ""
