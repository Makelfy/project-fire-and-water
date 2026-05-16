extends Area2D

@onready var main = $".."
@onready var raycast_1 = $Player1Raycast
@onready var raycast_2 = $Player2Raycast

@export var player1: CharacterBody2D
@export var player2: CharacterBody2D
@export var bullet: PackedScene

@onready var player1_raycast: RayCast2D = $Player1Raycast
@onready var player2_raycast: RayCast2D = $Player2Raycast

var player1_firable: bool = false
var player2_firable: bool = false


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

	if player2:
		raycast_2.target_position = to_local(player2.global_position)
		raycast_2.force_raycast_update()
		player2_firable = (raycast_2.get_collider() == player2)
	else:
		player2_firable = false

func can_shoot_player(player: CharacterBody2D, raycast: RayCast2D) -> bool:
	if player == null:
		return false

	raycast.target_position = raycast.to_local(player.global_position)
	raycast.force_raycast_update()

	return raycast.is_colliding() and raycast.get_collider() == player


func shoot(player):
	if bullet == null:
		return

	isShooting = true
	if time == 3:
		var instance = bullet.instantiate()
		instance.dir = global_position - player.global_position
		instance.spawnPos = global_position+Vector2(30,30)
		instance.spawnRot = rotation
		instance.zDex = z_index - 1
		main.add_child.call_deferred(instance)
	
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
	
	if isShooting:
		if time < 0:
			time = 3
		else:
			time -= 1
	else:
		if time > 0 and time != 3:
			time -= 1
		else:
			time = 3

	
	print(time)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var sprite = body.get_child(0)
		sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)
		body.start_timer()
		if body.has_method("apply_knockback"):
			body.apply_knockback(global_position)
