extends Node2D


signal playersTurn
signal monstersTurn
var numOfMonsters = 1
var monsterTurns = 0




func _on_player_turn_taken() -> void:
	emit_signal("monstersTurn")

#func on monster turn taken:
#monsterTurns++
#If monster turns >= numOfMonsters
#emit_signal(playersTurn)


#func on monster death
#numOfMonsters--
#If monsterTurns >= numOfMonsters
#emit_signal(playersTurn)


func _on_basic_monster_monster_turn_taken() -> void:
	monsterTurns += 1
	if monsterTurns >= numOfMonsters:
		emit_signal("playersTurn")
