extends CharacterBody2D


const MAX_SPEED = 500.0
const SPEED = 300.0
const ACC = 20.0
const JUMP_VELOCITY = -700.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += 1.5 * get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("up1") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		if(velocity.x == 0):
			velocity.x = direction * SPEED
		elif(velocity.x < MAX_SPEED and velocity.x > -MAX_SPEED):
			velocity.x += direction*ACC
		else:
			velocity.x = direction * MAX_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()


func _on_flashlight_area_entered(area: Area2D) -> void:
	if(area.is_in_group("enemy")):
		pass
