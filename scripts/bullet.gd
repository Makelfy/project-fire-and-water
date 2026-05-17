extends Area2D

@export var SPEED = 200 

var dir: Vector2
var spawnPos: Vector2
var spawnRot: float
var zDex: int

func _ready():
	global_position = spawnPos
	global_rotation = spawnRot
	z_index = zDex
	
	get_tree().create_timer(5.0).timeout.connect(queue_free)

func _physics_process(delta):
	global_position += dir * SPEED * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(30)
		
		body.start_timer()
		if body.has_method("apply_knockback"):
			body.apply_knockback(global_position)
		
	queue_free()
