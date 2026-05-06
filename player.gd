extends CharacterBody2D

var myTurn := true
var moving := false
var input_dir: Vector2

signal turnTaken

@onready var astar_agent = get_parent().get_node("AStarAgent")
@onready var exit_node   = get_parent().get_node("DungeonExit")

func _ready() -> void:
	add_to_group("Player")  # lets the monster find the player via get_first_node_in_group
	call_deferred("player_turn")
	if !get_parent().is_connected("playersTurn", player_turn):
		get_parent().connect("playersTurn", player_turn)

func player_turn() -> void:
	if moving:
		return

	myTurn = true

	var enemies: Array    = get_tree().get_nodes_in_group("Enemies")
	var start:   Vector2i = astar_agent.world_to_grid(global_position)
	var goal:    Vector2i = astar_agent.world_to_grid(exit_node.global_position)
	
	# exclude the player node from ray checks so A* doesn't block on itself.
	var path:    Array    = astar_agent.find_path(start, goal, enemies, [self])

	if path.size() > 1:
		var next_cell  : Vector2i = path[1]
		var next_world : Vector2  = astar_agent.grid_to_world(next_cell)
		input_dir = (next_world - global_position).normalized()
		move()

func move() -> void:
	if !input_dir:
		return
	if !moving:
		moving  = true
		if(input_dir == Vector2(-1.0, 0.0)):
			$Sprite2D.play("move_left")
		elif(input_dir == Vector2(0.0, -1.0)):
			$Sprite2D.play("move_up")
		elif(input_dir == Vector2(1.0,0.0)):
			$Sprite2D.play("move_right")
		else:
			$Sprite2D.play("move_down")
		myTurn  = false
		var tween := create_tween()
		tween.tween_property(self, "position", position + input_dir * 64, 0.35)
		tween.tween_callback(stop_move)

func stop_move() -> void:
	moving = false
	emit_signal("turnTaken")
