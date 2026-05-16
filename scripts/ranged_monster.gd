extends Area2D

@onready var main = $".."

@export var player1: CharacterBody2D
@export var player2: CharacterBody2D
@export var bullet: PackedScene

@onready var player1_raycast: RayCast2D = $Player1Raycast
@onready var player2_raycast: RayCast2D = $Player2Raycast

var player1_firable: bool = false
var player2_firable: bool = false
var isShooting: bool = false


func _ready() -> void:
	player1_raycast.enabled = true
	player2_raycast.enabled = true

	var timer := get_node_or_null("Timer") as Timer
	if timer == null and get_parent() != null:
		timer = get_parent().get_node_or_null("Timer") as Timer

	if timer != null and not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)


func _physics_process(delta: float) -> void:
	player1_firable = can_shoot_player(player1, player1_raycast)
	player2_firable = can_shoot_player(player2, player2_raycast)

	print(player1_firable)
	print(player2_firable)
func can_shoot_player(player: CharacterBody2D, raycast: RayCast2D) -> bool:
	if player == null:
		return false

	raycast.target_position = raycast.to_local(player.global_position)
	raycast.force_raycast_update()

	return raycast.is_colliding() and raycast.get_collider() == player


func shoot(player):
	print("shoot")
	if bullet == null:
		return

	var instance = bullet.instantiate()
	instance.dir = (player.global_position - global_position).normalized()
	instance.spawnPos = global_position
	instance.spawnRot = rotation
	instance.zDex = z_index - 1
	main.add_child.call_deferred(instance)

func _on_timer_timeout() -> void:
	if player1_firable and player2_firable:
		var dist1 = global_position.distance_squared_to(player1.global_position)
		var dist2 = global_position.distance_squared_to(player2.global_position)
		
		if dist1 < dist2:
			shoot(player1)
		else:
			shoot(player2)
			
	elif player1_firable:
		shoot(player1)
	elif player2_firable:
		shoot(player2)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var sprite := body.get_child(0) as Sprite2D
	if sprite:
		sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)

	if body.has_method("start_timer"):
		body.start_timer()

	if body.has_method("apply_knockback"):
		body.apply_knockback(global_position)
