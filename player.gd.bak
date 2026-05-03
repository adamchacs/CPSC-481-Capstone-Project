extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var myTurn = true
var moving = false
var input_dir;

signal turnTaken


func _unhandled_input(event: InputEvent) -> void:
	#if !myTurn:
		#return 
	if Input.is_action_just_pressed("moveUp"):
		if ($RayUp.is_colliding()):
			return
		myTurn = false
		emit_signal("turnTaken")
		input_dir = Vector2(0,-1)
		move()
	elif Input.is_action_just_pressed("moveDown"):
		if ($RayDown.is_colliding()):
			return
		myTurn = false
		emit_signal("turnTaken")
		input_dir = Vector2(0,1)
		move()
	elif Input.is_action_just_pressed("moveLeft"):
		if ($RayLeft.is_colliding()):
			return
		myTurn = false
		emit_signal("turnTaken")
		input_dir = Vector2.LEFT
		move()
	elif Input.is_action_just_pressed("moveRight"):
		if ($RayRight.is_colliding()):
			return
		myTurn = false
		emit_signal("turnTaken")
		input_dir = Vector2.RIGHT
		move()

#Connect the playersTurn signal from the DungeonLogic
func move():
	if !input_dir:
		return
	if !moving:
		moving = true
		var tween = create_tween()
		tween.tween_property(self, "position", position + input_dir*65, 0.35)
		tween.tween_callback(stop_move)
		 
func stop_move():
	moving = false
