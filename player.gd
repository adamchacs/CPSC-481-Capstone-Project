extends CharacterBody2D

var myTurn = true
var moving = false
var input_dir

signal turnTaken

@onready var astar_agent = get_parent().get_node("AStarAgent")
@onready var exit_node = get_parent().get_node("DungeonExit")

func _ready() -> void:
	# Starts the AI after the scene loads.
	call_deferred("player_turn")

	# DungeonLogic emits this after all monsters finish moving.
	if !get_parent().is_connected("playersTurn", player_turn):
		get_parent().connect("playersTurn", player_turn)

func player_turn():
	if moving:
		return

	myTurn = true

	var enemies = get_tree().get_nodes_in_group("Enemies")
	var start = astar_agent.world_to_grid(global_position)
	var goal = astar_agent.world_to_grid(exit_node.global_position)

	# Exclude the player from ray checks so A* does not block itself.
	var path = astar_agent.find_path(start, goal, enemies, [self])

	if path.size() > 1:
		var next_cell = path[1]
		var next_world = astar_agent.grid_to_world(next_cell)
		input_dir = (next_world - global_position).normalized()
		move()
	else:
		return

func move():
	if !input_dir:
		return

	if !moving:
		moving = true
		myTurn = false
		var tween = create_tween()
		tween.tween_property(self, "position", position + input_dir * 64, 0.35)
		tween.tween_callback(stop_move)

func stop_move():
	moving = false
	emit_signal("turnTaken")
