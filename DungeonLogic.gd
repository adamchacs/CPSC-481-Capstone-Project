extends Node2D

signal playersTurn
signal monstersTurn

var numOfMonsters := 1
var monsterTurns  := 0
var game_over     := false

func _ready() -> void:
	# count monsters in the current scene
	numOfMonsters = get_tree().get_nodes_in_group("Enemies").size()
	if numOfMonsters < 1:
		numOfMonsters = 1

# called by basic_monster.gd when a monster lands on the player's tile
func player_caught() -> void:
	if game_over:
		return
	game_over = true
	await get_tree().create_timer(0.05).timeout
	var lose := get_node_or_null("LoseScreen")
	if lose:
		lose.visible = true
	get_tree().paused = true

func _on_player_turn_taken() -> void:
	if game_over:
		return
	emit_signal("monstersTurn")

func _on_basic_monster_monster_turn_taken() -> void:
	if game_over:
		return
	monsterTurns += 1
	if monsterTurns >= numOfMonsters:
		monsterTurns = 0
		emit_signal("playersTurn")

# connected to RestartButton.pressed in the dungeon scenes
func _on_restart_button_pressed() -> void:
	game_over = false
	get_tree().paused = false
	get_tree().reload_current_scene()
