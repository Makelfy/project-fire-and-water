extends Area2D

const SPEED = 150

@export var Distance := 100.0
@export var dig_distance := Vector2(0,10.0)

var is_underground := false
var start_pos_x: float
var direction: int = 1
var HEALTH = 2
var is_damagable := false 

func _ready() -> void:
	# Save the initial starting position
	$Sprite2D.play("dig")
	start_pos_x = global_position.x

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
		# If direction is -1 (left), flip_h is true. Otherwise, false.
		$Sprite2D.flip_h = (direction == 1)

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


func _on_timer_timeout() -> void:
	if is_underground:
		dig(false)
	else:
		dig(true)
		

		
func dig(is_digging_down):
	var final_destination
	if is_digging_down:
		final_destination = global_position - dig_distance
		is_underground = true
		$GPUParticles2D.emitting = true
	else:
		final_destination = global_position + dig_distance
		is_underground = false
		$GPUParticles2D.emitting = false
		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", final_destination, 0.5)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
