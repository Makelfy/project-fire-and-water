extends RigidBody2D

@onready var main = $".."
@onready var raycast_1 = $Player1Raycast
@onready var raycast_2 = $Player2Raycast

@export var player1: CharacterBody2D
@export var player2: CharacterBody2D
@export var bullet: PackedScene

var player1_firable: bool = false
var player2_firable: bool = false

func _physics_process(_delta: float) -> void:
	if player1:
		raycast_1.target_position = to_local(player1.global_position)
		raycast_1.force_raycast_update() 
		print(raycast_1.get_collider())
		player1_firable = (raycast_1.get_collider() == player1)
	else:
		player1_firable = false

	if player2:
		raycast_2.target_position = to_local(player2.global_position)
		raycast_2.force_raycast_update()
		player2_firable = (raycast_2.get_collider() == player2)
	else:
		player2_firable = false

func shoot(target_player: Node2D):
	var instance = bullet.instantiate()
	instance.dir = (target_player.global_position - global_position).normalized()
	
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
