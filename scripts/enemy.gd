extends Area2D

const SPEED = 150
const IDLE_ANIMATION := &"default"
const WALK_ANIMATION := &"walking"

@export var patrol_point_a: NodePath
@export var patrol_point_b: NodePath
@export_range(0.0, 1.0, 0.05) var wait_chance: float = 0.99
@export var min_wait_time: float = 0.35
@export var max_wait_time: float = 1.2

var patrol_points: Array[Vector2] = []
var target_point_index: int = 1
var direction: int = 1
var HEALTH = 2
var is_damagable := false
var is_waiting := false

func _ready() -> void:
	_setup_patrol_points()
	_update_sprite()
	_play_walk_animation()

func _physics_process(delta: float) -> void:
	if patrol_points.size() < 2 or is_waiting:
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
		# If direction is -1 (left), flip_h is true. Otherwise, false.
		$Sprite2D.flip_h = (direction == -1)

func _update_direction(movement_to_target: Vector2) -> void:
	if absf(movement_to_target.x) <= 0.01:
		return

	direction = 1 if movement_to_target.x > 0.0 else -1
	_update_sprite()

func _advance_patrol_target() -> void:
	target_point_index = 1 - target_point_index

	var movement_to_target: Vector2 = patrol_points[target_point_index] - global_position
	_update_direction(movement_to_target)
	_maybe_wait()

func _maybe_wait() -> void:
	if randf() > wait_chance:
		_play_walk_animation()
		return

	is_waiting = true
	_play_idle_animation()

	var wait_time: float = randf_range(min_wait_time, max_wait_time)
	await get_tree().create_timer(wait_time).timeout

	if not is_inside_tree():
		return

	is_waiting = false
	_play_walk_animation()

func _play_walk_animation() -> void:
	var animated_sprite := get_node_or_null("Sprite2D") as AnimatedSprite2D
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return

	if animated_sprite.sprite_frames.has_animation(WALK_ANIMATION):
		animated_sprite.play(WALK_ANIMATION)

func _play_idle_animation() -> void:
	var animated_sprite := get_node_or_null("Sprite2D") as AnimatedSprite2D
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return

	if animated_sprite.sprite_frames.has_animation(IDLE_ANIMATION):
		animated_sprite.play(IDLE_ANIMATION)
	else:
		animated_sprite.pause()

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
