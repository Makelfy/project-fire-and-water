extends Area2D

const SPEED = 150

@export var patrol_point_a: NodePath
@export var patrol_point_b: NodePath

var patrol_points: Array[Vector2] = []
var target_point_index: int = 1
var direction: int = 1

var HEALTH = 2
var is_damagable := false

var light_start_positions := {}

func _ready() -> void:
	_setup_patrol_points()
	
	$Sprite2D.play("default")

	for child in $Sprite2D.get_children():
		if child is PointLight2D:
			light_start_positions[child] = child.position

func _physics_process(delta: float) -> void:
	if patrol_points.size() < 2:
		return

	var target_position: Vector2 = patrol_points[target_point_index]
	var movement_to_target: Vector2 = target_position - global_position
	_update_direction(movement_to_target)

	if movement_to_target.length() <= SPEED * delta:
		global_position = target_position
		_advance_patrol_target()
		return

	global_position += movement_to_target.normalized() * SPEED * delta

func _setup_patrol_points() -> void:
	patrol_points.clear()

	var point_a := get_node_or_null(patrol_point_a) as Node2D
	var point_b := get_node_or_null(patrol_point_b) as Node2D

	if point_a == null or point_b == null:
		return

	patrol_points.append(point_a.global_position)
	patrol_points.append(point_b.global_position)
	target_point_index = 1

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
