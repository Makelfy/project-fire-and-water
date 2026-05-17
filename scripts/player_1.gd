extends CharacterBody2D

var HEALTH = Config.PLAYER_HEALTH

var MAX_SPEED = Config.PLAYER_MAX_SPEED
var SPEED = Config.PLAYER_SPEED
const ACC = 20.0
var JUMP_VELOCITY = Config.PLAYER_JUMP_FORCE

@export var attack_sound1 :AudioStream
@export var attack_sound2 :AudioStream
var attack_sounds : Array
@export var attackhit_sound1 :AudioStream
@export var attackhit_sound2 :AudioStream
var attackhit_sounds : Array
@export var hit_sound : AudioStream
# Knockback parameters
@export var KNOCKBACK_FORCE = 300
const KNOCKBACK_DURATION = 0.18
const KNOCKBACK_FRICTION = 1800.0

var knockback_time_left = 0.0

var is_attacking = false
var is_dead = false

func _ready():
	attack_sounds.append(attack_sound1)
	attack_sounds.append(attack_sound2)
	attackhit_sounds.append(attackhit_sound1)
	attackhit_sounds.append(attackhit_sound2)
	HEALTH = Config.PLAYER_HEALTH
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1.0)
	$AnimatedSprite2D.play("default")
	$attack.hide()
	$attack/CollisionShape2D.set_deferred("disabled", true)

func _process(delta: float) -> void:
	if is_dead:
		return

	if(Input.is_action_just_pressed("attack") and not is_attacking):
		start_attack()
	

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

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
		if Input.is_action_just_pressed("left2") or Input.is_action_just_pressed("right2") and not is_attacking:
			$AnimatedSprite2D.play("WALK")
		if (Input.is_action_just_released("left2") and not Input.is_action_pressed("right2") 
		) or (Input.is_action_just_released("right2") and not Input.is_action_pressed("left2")) and not is_attacking:
			$AnimatedSprite2D.play("default")
		

		if direction:
			$AnimatedSprite2D.flip_h = true
			if(velocity.x == 0):
				velocity.x = direction * SPEED
			elif(velocity.x < MAX_SPEED and velocity.x > -MAX_SPEED):
				velocity.x += direction*ACC
			else:
				velocity.x = direction * MAX_SPEED
			$attack.position.x = -80 if velocity.x < 0 else 0 
			$AnimatedSprite2D.flip_h = direction == -1
			$attack/Sprite2D.flip_h = direction == -1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()

func start_attack():
	is_attacking = true	
	$AudioStreamPlayer2D.stream = attackhit_sounds.pick_random()
	$AudioStreamPlayer2D.play()
	$AnimatedSprite2D.play("ATTACK")
	$AttackTimer.start()
	$attack.show()
	$attack/CollisionShape2D.set_deferred("disabled", false)
	await get_tree().create_timer(0.1).timeout
	$attack/CollisionShape2D.set_deferred("disabled", true)
	$attack.hide()
	$AnimatedSprite2D.play("default")

func handle_death() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	knockback_time_left = 0.0
	is_attacking = false
	$AttackTimer.stop()
	$attack.hide()
	$attack/CollisionShape2D.set_deferred("disabled", true)

	var scene_root := get_tree().current_scene if get_tree().current_scene != null else get_parent()
	var canvas_layer := scene_root.get_node_or_null("CanvasLayer")
	if canvas_layer:
		canvas_layer.visible = true
		var game_over_scene := canvas_layer.get_node_or_null("GameOverScene")
		if game_over_scene:
			game_over_scene.visible = true

	get_tree().paused = true

var damage_cooldown = false
func take_damage(damage: float) -> void:
	if is_attacking:
		return
	if is_dead:
		return
	
	$AudioStreamPlayer2D.stream = hit_sound
	$AudioStreamPlayer2D.play()

	if not damage_cooldown:
		damage_cooldown = true
		HEALTH -= damage
		if HEALTH <= 0:
			handle_death()
		await get_tree().create_timer(1).timeout
		damage_cooldown = false

func apply_knockback(source_position: Vector2) -> void:
	if is_dead:
		return

	var sprite = $AnimatedSprite2D
	sprite.modulate = Color(HEALTH/100, HEALTH/160, HEALTH/160, 1.0)

	var knockback_direction := global_position - source_position
	if knockback_direction.length_squared() == 0.0:
		knockback_direction = Vector2.LEFT if velocity.x <= 0.0 else Vector2.RIGHT
	else:
		knockback_direction = knockback_direction.normalized()

	velocity = knockback_direction * KNOCKBACK_FORCE
	knockback_time_left = KNOCKBACK_DURATION

func start_timer():
	pass



func _on_attack_area_entered(area: Area2D) -> void:
	if(area.is_in_group("enemy")):
		if(area.is_damagable):
			$AudioStreamPlayer2D.stream = attack_sounds.pick_random()
			$AudioStreamPlayer2D.play()
		area.take_damage()

func _on_attack_timer_timeout() -> void:
	is_attacking = false
