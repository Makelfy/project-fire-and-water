extends Area2D

const SPEED := 150.0

@export var Distance := 0.0

var default_position_x := 0.0
var direction := 1


func _ready() -> void:
	default_position_x = global_position.x


func _physics_process(delta: float) -> void:
	if Distance <= 0:
		return
	
	if abs(default_position_x - global_position.x) <= Distance:
		global_position.x += SPEED * delta * direction
		return

	direction *= -1
	global_position.x += direction * 10.0

	if has_node("Sprite2D"):
		$Sprite2D.flip_h = direction != -1


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
