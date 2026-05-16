extends RigidBody2D

@onready var main = $".."

@export var player1: CharacterBody2D
@export var player2: CharacterBody2D
@export var bullet: PackedScene

var player1_firable: bool = false
var player2_firable: bool = false
var time: int = 3
var isShooting:bool = false


func _physics_process(delta: float) -> void:
	$Player1Raycast.target_position = player1.global_position
	$Player1Raycast.add_exception(player1)
	if !$Player1Raycast.is_colliding():
		player1_firable = false
	else:
		player1_firable = true
	
	$Player2Raycast.target_position = player1.global_position
	$Player2Raycast.add_exception(player2)
	if !$Player2Raycast.is_colliding():
		player2_firable = false
	else:
		player2_firable = true

	if player1_firable or player2_firable:
		isShooting = true
	else:
		isShooting = false


func shoot(player):
	isShooting = true
	if time == 3:
		var instance = bullet.instantiate()
		instance.dir = global_position - player.global_position
		instance.spawnPos = global_position+Vector2(30,30)
		instance.spawnRot = rotation
		instance.zDex = z_index - 1
		main.add_child.call_deferred(instance)
	
func _on_timer_timeout() -> void:

	if player1_firable and player2_firable:
		if player1.global_position.distance_to(global_position) < player2.global_position.distance_to(global_position):
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
