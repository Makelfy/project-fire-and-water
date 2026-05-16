extends CharacterBody2D

var HEALTH = Config.PLAYER_HEALTH

var MAX_SPEED = Config.PLAYER_MAX_SPEED
var SPEED = Config.PLAYER_SPEED
const ACC = 20.0
var JUMP_VELOCITY = Config.PLAYER_JUMP_FORCE

# Knockback parameters
@export var KNOCKBACK_FORCE = 300
const KNOCKBACK_DURATION = 0.18
const KNOCKBACK_FRICTION = 1800.0

var knockback_time_left = 0.0
var damage_cooldown = false
var is_dead = false


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
		if Input.is_action_just_pressed("up1") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")

		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
			$AnimatedSprite2D.play("WALK")
		if (Input.is_action_just_released("ui_left") and not Input.is_action_pressed("ui_right")
		) or (Input.is_action_just_released("ui_right") and not Input.is_action_pressed("ui_left")):
			$AnimatedSprite2D.play("default")
		
		if direction:
			$AnimatedSprite2D.flip_h = true
			if(velocity.x == 0):
				velocity.x = direction * SPEED
			elif(velocity.x < MAX_SPEED and velocity.x > -MAX_SPEED):
				velocity.x += direction*ACC
			else:
				velocity.x = direction * MAX_SPEED
			$AnimatedSprite2D.flip_h = direction == -1
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()
func handle_death() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	knockback_time_left = 0.0

	var scene_root := get_tree().current_scene if get_tree().current_scene != null else get_parent()
	var canvas_layer := scene_root.get_node_or_null("CanvasLayer")
	if canvas_layer:
		canvas_layer.visible = true
		var game_over_scene := canvas_layer.get_node_or_null("GameOverScene")
		if game_over_scene:
			game_over_scene.visible = true

	get_tree().paused = true


func take_damage(damage: float) -> void:
	if is_dead:
		return

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
	sprite.modulate = Color(HEALTH/100, 0.0, 0.0, 1.0)

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
	$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_flashlight_area_entered(area: Area2D) -> void:
	if(area.is_in_group("enemy")):
		area.set_damagable(true)

func _on_flashlight_area_exited(area: Area2D) -> void:
	if(area.is_in_group("enemy")):
		area.set_damagable(false)
	
func _ready():
	$AnimatedSprite2D.play("default")
