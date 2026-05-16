extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _physics_process(delta: float) -> void:
	rotateToMouse()

var rotationSpeed = .2

func rotateToMouse():
	var direction = (get_viewport().get_mouse_position() - global_position)
	var angleTo = transform.x.angle_to(direction)
	rotate(sign(angleTo) * min(rotationSpeed, abs(angleTo)))
