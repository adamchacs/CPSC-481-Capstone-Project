extends Control



func _on_dungeon_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Dungeon1.tscn")




func _on_dungeon_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Dungeon2.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
