extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var sprite := body.get_child(0) as Sprite2D
	if sprite:
		sprite.modulate = Color(1.0, 0.0, 0.0, 1.0)

	if body.has_method("start_timer"):
		body.start_timer()

	if body.has_method("take_damage"):
		body.take_damage(30)

	if body.has_method("apply_knockback"):
		body.apply_knockback(global_position)
