extends CharacterBody2D
#This monster should follow basic and predictable behavior, pathing towards the player in predictable ways
var playerRef
var active = true
var movement = false
var desired_dir

signal monster_turn_taken

func _ready() -> void:
	get_parent().connect("monstersTurn", monsterTurn)

func monsterTurn():
	if !active:
		return
		#TODO:
	#Determine how far the player is from itself and move in the direction it is furthest away in.
	#If the enemy cant advance in the desired direction, move in the other direction or a random one
	if $Right.is_colliding():
		return
	desired_dir = Vector2.RIGHT
	move()

func _on_player_detector_body_entered(body: Node2D) -> void:
	playerRef = body
	active = true

func move():
	if !desired_dir:
		return
	if !movement:
		movement = true
		var tween = create_tween()
		tween.tween_property(self, "position", position + desired_dir*64, 0.35)
		tween.tween_callback(stop_move)
		
func stop_move():
	movement = false
	emit_signal("monster_turn_taken")
