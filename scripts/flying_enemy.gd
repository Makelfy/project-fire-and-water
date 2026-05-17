extends Area2D

const SPEED = 150

@export var Distance := 100.0
@export var start_dir : int

var patrol_points: Array[Vector2] = []
var target_point_index: int = 1
var direction: int = 1

var HEALTH = 2
var is_damagable := false

var light_start_positions := {}

func _ready() -> void:
	# Save the initial starting position
	start_pos_x = global_position.x
	$Sprite2D.play("default")

	for child in $Sprite2D.get_children():
		if child is PointLight2D:
			light_start_positions[child] = child.position

func _physics_process(delta: float) -> void:
	if patrol_points.size() < 2:
		return

	# 1. Move the object
	global_position.x += SPEED * delta * direction
	
	if start_dir == -1 or start_dir == 1:
		direction = start_dir
		_update_sprite()
		start_dir = 0
	# 2. Check if it hit the right boundary
	elif global_position.x > start_pos_x + Distance:
		direction = -1
		_update_sprite()

	# 3. Check if it hit the left boundary
	elif global_position.x <= start_pos_x - Distance:
		direction = 1
		_update_sprite()
	

# Extracted sprite logic to a helper function to keep the physics process clean
func _update_sprite() -> void:
	if has_node("Sprite2D"):
		# If direction is -1 (left), flip_h is false. Otherwise, true.
		$Sprite2D.flip_h = (direction == 1)

		for light in light_start_positions:
			var start_position: Vector2 = light_start_positions[light]
			light.position.x = start_position.x * direction * -1
		
func _update_direction(movement_to_target: Vector2) -> void:
	if absf(movement_to_target.x) <= 0.01:
		return

	direction = 1 if movement_to_target.x > 0.0 else -1
	_update_sprite()

func _advance_patrol_target() -> void:
	target_point_index = 1 - target_point_index

	var movement_to_target: Vector2 = patrol_points[target_point_index] - global_position
	_update_direction(movement_to_target)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.start_timer()

		if body.has_method("take_damage"):
			body.take_damage(30)

		if body.has_method("apply_knockback"):
			body.apply_knockback(global_position)

func take_damage():
	if is_damagable:
		HEALTH -= 1
	if HEALTH <= 0:
		queue_free()

func set_damagable(val):
	is_damagable = val
