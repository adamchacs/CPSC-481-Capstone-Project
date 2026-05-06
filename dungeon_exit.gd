extends Node2D

# set this in the Inspector on the DungeonExit node inside each scene, if created:
#   Dungeon1's exit -> "res://Dungeon2.tscn"
#   Dungeon2's exit -> blank for now, but onto next dungeon if we make it.
@export var next_scene_path: String = ""

func _on_player_detector_body_entered(_body: Node2D) -> void:
	await get_tree().create_timer(0.30).timeout  # ← wait for the 0.30s tween to finish, so player is visually on the exit tile
	var win := get_node_or_null("Win")
	if win:
		win.visible = true
	get_tree().paused = true  # freeze game while the win screen is visible

# connected to the "Next Dungeon" NextButton inside the Win CanvasLayer for DungeonExit inside dungeon_exit.gd
func _on_next_button_pressed() -> void:
	get_tree().paused = false
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	else:
		get_tree().change_scene_to_file("res://Dungeon1.tscn")

# connected to the "Try Again" RestartButton inside the Win CanvasLayer for DungeonExit inside dungeon_exit.gd
func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_button_pressed() -> void:
	get_tree().quit()
