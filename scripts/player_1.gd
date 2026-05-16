extends CharacterBody2D


const MAX_SPEED = 500.0
const SPEED = 300.0
const ACC = 20.0
const JUMP_VELOCITY = -700.0
@export var KNOCKBACK_FORCE = 650.0
const KNOCKBACK_DURATION = 0.18
const KNOCKBACK_FRICTION = 1800.0

var knockback_time_left = 0.0

var is_attacking = false

func _ready():
	$attack/CollisionShape2D.set_deferred("disabled", true)
	$attack.hide()

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("attack") and not is_attacking):
		start_attack()
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += 1.5 * get_gravity() * delta

	if knockback_time_left > 0.0:
		knockback_time_left -= delta
		velocity.x = move_toward(velocity.x, 0, KNOCKBACK_FRICTION * delta)
	else:
		# Handle jump.
		if Input.is_action_just_pressed("up2") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left2", "right2")
		if direction:
			if(velocity.x == 0):
				velocity.x = direction * SPEED
			elif(velocity.x < MAX_SPEED and velocity.x > -MAX_SPEED):
				velocity.x += direction*ACC
			else:
				velocity.x = direction * MAX_SPEED
			$attack/Sprite2D.flip_h = false if direction == -1 else true
			$attack.position.x = -192 if velocity.x < 0 else 0 
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()

func start_attack():
	is_attacking = true
	$AttackTimer.start()
	$attack.show()
	$attack/CollisionShape2D.set_deferred("disabled", false)
	await get_tree().create_timer(0.1).timeout
	$attack/CollisionShape2D.set_deferred("disabled", true)
	$attack.hide()
	


func apply_knockback(source_position: Vector2) -> void:
	var knockback_direction := global_position - source_position
	if knockback_direction.length_squared() == 0.0:
		knockback_direction = Vector2.LEFT if velocity.x <= 0.0 else Vector2.RIGHT
	else:
		knockback_direction = knockback_direction.normalized()

	velocity = knockback_direction * KNOCKBACK_FORCE
	knockback_time_left = KNOCKBACK_DURATION

func start_timer():
	$Timer.start()

func _on_timer_timeout() -> void:
	$Sprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _on_attack_area_entered(area: Area2D) -> void:
	if(area.is_in_group("enemy")):
		pass


func _on_attack_timer_timeout() -> void:
	is_attacking = false
