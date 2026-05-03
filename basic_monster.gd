extends CharacterBody2D

var playerRef: Node2D = null
var active := true
var movement := false
var desired_dir := Vector2.ZERO
var alerted := false              # true once the player comes within range
const ALERT_RANGE := 256.0       # 4 tiles (64px each) — tune this number up or down for monster activation

signal monster_turn_taken

const TILE_SIZE := 64
static var reserved_tiles: Array[Vector2] = [] 

func _ready() -> void:
	get_parent().connect("monstersTurn", monsterTurn)

func monsterTurn() -> void:
	# the first monster to move this round clears last round's reservations.
	# we know it's the first because the list was emptied in stop_move().
	if reserved_tiles.is_empty():
		reserved_tiles.clear()
	
	if !active or playerRef == null:
		var t := create_tween()
		t.tween_interval(0.35)
		t.tween_callback(func(): emit_signal("monster_turn_taken"))
		return

	# check if the player just entered the monster's alert range this turn
	var dist_to_player: float = global_position.distance_to(playerRef.global_position)
	if not alerted and dist_to_player <= ALERT_RANGE:
		alerted = true

	# if not yet alerted, monster stands still for this turn.
	if not alerted:
		# still reserve our current tile so other monsters don't walk into the current monster.
		reserved_tiles.append(global_position)
		var t := create_tween()
		t.tween_interval(0.35)
		t.tween_callback(func(): emit_signal("monster_turn_taken"))
		return

	var best := _find_best_direction()
	if best != Vector2.ZERO:
		desired_dir = best
		# reserve the destination tile immediately, before moving.
		reserved_tiles.append(global_position + desired_dir * TILE_SIZE)
		move()
	else:
		# blocked — reserve current tile so other monsters route around the current monster.
		reserved_tiles.append(global_position)
		var t := create_tween()
		t.tween_interval(0.35)
		t.tween_callback(func(): emit_signal("monster_turn_taken"))

func _find_best_direction() -> Vector2:
	var dirs := [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]
	var best_dir := Vector2.ZERO
	var best_dist := INF

	for dir in dirs:
		if not _direction_is_free(dir):
			continue
		var next_pos: Vector2 = global_position + dir * TILE_SIZE

		# priority of monster to always step onto the player's tile immediately, this is the kill player move.
		if next_pos.distance_to(playerRef.global_position) < 40.0:
			return dir

		# block tiles already reserved by other monsters this turn, so no overlapping monsters in same tile
		var already_reserved := false
		for tile in reserved_tiles:
			if next_pos.distance_to(tile) < 40.0:
				already_reserved = true
				break
		if already_reserved:
			continue

		var d: float = next_pos.distance_to(playerRef.global_position)
		if d < best_dist:
			best_dist = d
			best_dir = dir

	return best_dir

func _direction_is_free(dir: Vector2) -> bool:
	var ray_name := ""
	if   dir == Vector2.RIGHT: ray_name = "Right"
	elif dir == Vector2.LEFT:  ray_name = "Left"
	elif dir == Vector2.DOWN:  ray_name = "Down"
	else:                      ray_name = "Up"

	var ray := get_node_or_null(ray_name)
	if ray == null:
		return true
	return !ray.is_colliding()

func _on_player_detector_body_entered(_body: Node2D) -> void:
	# detector fires when the player enters the large detection radius.
	# grab the player from the group so we have a valid reference.
	playerRef = get_tree().get_first_node_in_group("Player")
	active = true

func move() -> void:
	if desired_dir == Vector2.ZERO:
		emit_signal("monster_turn_taken")
		return
	if !movement:
		movement = true
		var tween := create_tween()
		tween.tween_property(self, "position", position + desired_dir * TILE_SIZE, 0.35)
		tween.tween_callback(stop_move)

func stop_move() -> void:
	movement = false
	reserved_tiles.clear() # all monsters have landed, wipe reserved tiles for next round

	# check if monster landed on the player's tile.
	if playerRef != null:
		var _dist: float = global_position.distance_to(playerRef.global_position)
		if _dist < 48.0:
			var logic := get_parent()
			if logic.has_method("player_caught"):
				logic.player_caught()
				return  # game over, do not emit the next-turn signal

	emit_signal("monster_turn_taken")
