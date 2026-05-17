extends Control


func _on_play_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://levels/level_1.tscn")
