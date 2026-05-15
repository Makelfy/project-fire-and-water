extends Area2D

const SPEED = 150
const DELTA_TO_CHANGE = 30

@export var DISTANCE : float

var default_pos_x
var direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_pos_x = global_position.x
	direction = 1


func _physics_process(delta: float) -> void:
	if abs(default_pos_x - global_position.x) <= DISTANCE:
		global_position.x += SPEED * delta * direction
	else:
		direction *= -1
		global_position.x += direction * 10
		
		$Sprite2D.flip_h = false if direction == -1 else true  
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
