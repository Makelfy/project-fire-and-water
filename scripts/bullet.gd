extends Area2D

@export var SPEED = 100

var dir: Vector2
var spawnPos: Vector2
var spawnRot: float
var zDex: int

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot
	z_index = zDex
	
func _physics_process(delta):
	global_position += -delta*SPEED*dir

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("hit")
		queue_free()
