extends Area2D


enum MovementHorizontal {
	LEFT,
	RIGHT,
	NONE,
}


enum MovementVertical {
	UP,
	DOWN,
	NONE,
}


@export var normal_speed = 200.0
@export var focused_speed = 100.0
@export var play_area = Rect2()
@export var initial_position = Vector2(50, 50)
@export var player_radius = 20.0
@export var hitbox_radius = 5.0
@export var graze_radius = 30.0
@export var player_color = Color.MAGENTA
@export var hitbox_color = Color.RED


var current_speed = normal_speed
var last_horizontal = MovementHorizontal.NONE
var last_vertical = MovementVertical.NONE


@onready var graze_area = $GrazeArea


signal player_hit
signal player_grazed


func _draw() -> void:
	draw_circle(Vector2.ZERO, player_radius, player_color)
	draw_circle(Vector2.ZERO, hitbox_radius, hitbox_color)


func _ready() -> void:
	$CollisionShape2D.scale = Vector2(hitbox_radius / player_radius, hitbox_radius / player_radius)
	$GrazeArea/CollisionShape2D.scale = Vector2(graze_radius / player_radius, graze_radius / player_radius)
	global_position = Vector2(play_area.position.x + initial_position.x, play_area.position.y + initial_position.y)
	
	area_entered.connect(_on_projectile_hit)
	graze_area.area_entered.connect(_on_projectile_grazed)


func _on_projectile_hit(projectile) -> void:
	player_hit.emit()


func _on_projectile_grazed(projectile) -> void:
	if projectile.has_method("is_grazed") and not projectile.is_grazed():
		projectile.mark_as_grazed()
		player_grazed.emit()


func _input(event) -> void:
	if event.is_action_pressed("MoveLeft"):
		last_horizontal = MovementHorizontal.LEFT
	elif event.is_action_pressed("MoveRight"):
		last_horizontal = MovementHorizontal.RIGHT
	elif event.is_action_released("MoveLeft") and last_horizontal == MovementHorizontal.LEFT:
		# if releasing left and right is still held switch to right
		if Input.is_action_pressed("MoveRight"):
			last_horizontal = MovementHorizontal.RIGHT
		else:
			last_horizontal = MovementHorizontal.NONE
	elif event.is_action_released("MoveRight") and last_horizontal == MovementHorizontal.RIGHT:
		# and vice versa
		if Input.is_action_pressed("MoveLeft"):
			last_horizontal = MovementHorizontal.LEFT
		else:
			last_horizontal = MovementHorizontal.NONE

	if event.is_action_pressed("MoveUp"):
		last_vertical = MovementVertical.UP
	elif event.is_action_pressed("MoveDown"):
		last_vertical = MovementVertical.DOWN
	elif event.is_action_released("MoveUp") and last_vertical == MovementVertical.UP:
		# if releasing up and down is still held switch to down
		if Input.is_action_pressed("MoveDown"):
			last_vertical = MovementVertical.DOWN
		else:
			last_vertical = MovementVertical.NONE
	elif event.is_action_released("MoveDown") and last_vertical == MovementVertical.DOWN:
		# and vice versa
		if Input.is_action_pressed("MoveUp"):
			last_vertical = MovementVertical.UP
		else:
			last_vertical = MovementVertical.NONE


func _process(delta) -> void:
	var velocity = Vector2.ZERO

	if last_horizontal == MovementHorizontal.LEFT:
		velocity.x = -1
	elif last_horizontal == MovementHorizontal.RIGHT:
		velocity.x = 1

	if last_vertical == MovementVertical.UP:
		velocity.y = -1
	elif last_vertical == MovementVertical.DOWN:
		velocity.y = 1
	
	# normalization for uniform velocity
	if velocity.length() > 0:
		velocity = velocity.normalized()
	
	if Input.is_action_pressed("Focus"):
		current_speed = focused_speed
	else:
		current_speed = normal_speed
	
	global_position += velocity * current_speed * delta
	
	global_position.x = clamp(global_position.x, play_area.position.x, play_area.position.x + play_area.size.x)
	global_position.y = clamp(global_position.y, play_area.position.y, play_area.position.y + play_area.size.y)

# to avoid movement after unpausing when no keys pressed
func _notification(what) -> void:
	if what == NOTIFICATION_PAUSED or what == NOTIFICATION_UNPAUSED:
		reset_movement_state()


func reset_movement_state() -> void:
	if Input.is_action_pressed("MoveLeft"):
		last_horizontal = MovementHorizontal.LEFT
	elif Input.is_action_pressed("MoveRight"):
		last_horizontal = MovementHorizontal.RIGHT
	else:
		last_horizontal = MovementHorizontal.NONE

	if Input.is_action_pressed("MoveUp"):
		last_vertical = MovementVertical.UP
	elif Input.is_action_pressed("MoveDown"):
		last_vertical = MovementVertical.DOWN
	else:
		last_vertical = MovementVertical.NONE
