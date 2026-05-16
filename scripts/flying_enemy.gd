extends Area2D

const SPEED = 150

@export var Distance := 100.0

var start_pos_x: float
var direction: int = 1

var light_start_positions := {}

func _ready() -> void:
	# Save the initial starting position
	start_pos_x = global_position.x
	
	$Sprite2D.play("default")

	for child in $Sprite2D.get_children():
		if child is PointLight2D:
			light_start_positions[child] = child.position

func _physics_process(delta: float) -> void:
	# Do nothing if Distance is 0 or negative
	if Distance <= 0:
		return

	# 1. Move the object
	global_position.x += SPEED * delta * direction

	# 2. Check if it hit the right boundary
	if global_position.x >= start_pos_x + Distance:
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
		

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.start_timer()

		if body.has_method("take_damage"):
			body.take_damage(30)

		if body.has_method("apply_knockback"):
			body.apply_knockback(global_position)
