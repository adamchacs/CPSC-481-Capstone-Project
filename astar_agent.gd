extends Node

# A* pathfinding helper for the dungeon game.
# The project moves in 64px steps, so every grid cell is one player move.
const TILE_SIZE := 64
const GRID_ORIGIN := Vector2(-16, 32)
const SEARCH_PADDING := 8

var directions := [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1)
]

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		round((world_pos.x - GRID_ORIGIN.x) / TILE_SIZE),
		round((world_pos.y - GRID_ORIGIN.y) / TILE_SIZE)
	)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return GRID_ORIGIN + Vector2(grid_pos.x * TILE_SIZE, grid_pos.y * TILE_SIZE)

func heuristic(a: Vector2i, b: Vector2i) -> int:
	# Manhattan distance works because movement is only up, down, left, and right.
	return abs(a.x - b.x) + abs(a.y - b.y)

func enemy_penalty(cell: Vector2i, enemies: Array) -> int:
	# Higher cost near enemies makes the AI choose safer routes when possible.
	var penalty := 0
	for enemy in enemies:
		var enemy_cell := world_to_grid(enemy.global_position)
		var dist := heuristic(cell, enemy_cell)
		if dist == 0:
			penalty += 1000
		elif dist == 1:
			penalty += 50
		elif dist == 2:
			penalty += 15
	return penalty

func is_inside_search_area(cell: Vector2i, start: Vector2i, goal: Vector2i) -> bool:
	var min_x = min(start.x, goal.x) - SEARCH_PADDING
	var max_x = max(start.x, goal.x) + SEARCH_PADDING
	var min_y = min(start.y, goal.y) - SEARCH_PADDING
	var max_y = max(start.y, goal.y) + SEARCH_PADDING
	return cell.x >= min_x and cell.x <= max_x and cell.y >= min_y and cell.y <= max_y

func is_blocked(from_cell: Vector2i, to_cell: Vector2i, exclude_nodes: Array = []) -> bool:
	# Uses the actual Godot physics/raycast system, so walls still block A*.
	var from_world := grid_to_world(from_cell)
	var to_world := grid_to_world(to_cell)
	var query := PhysicsRayQueryParameters2D.create(from_world, to_world)
	query.exclude = exclude_nodes
	var hit: Dictionary = get_viewport().world_2d.direct_space_state.intersect_ray(query)
	return !hit.is_empty()

func find_path(start: Vector2i, goal: Vector2i, enemies: Array, exclude_nodes: Array = []) -> Array:
	var open_set: Array[Vector2i] = [start]
	var came_from := {}
	var g_score := {}
	var f_score := {}

	g_score[start] = 0
	f_score[start] = heuristic(start, goal)

	while open_set.size() > 0:
		var current: Vector2i = open_set[0]
		for node in open_set:
			if f_score.get(node, 999999) < f_score.get(current, 999999):
				current = node

		if current == goal:
			return reconstruct_path(came_from, current)

		open_set.erase(current)

		for dir in directions:
			var neighbor: Vector2i = current + dir

			if !is_inside_search_area(neighbor, start, goal):
				continue
			if is_blocked(current, neighbor, exclude_nodes):
				continue

			var tentative_g: int = g_score[current] + 1 + enemy_penalty(neighbor, enemies)
			if tentative_g < g_score.get(neighbor, 999999):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + heuristic(neighbor, goal)
				if !open_set.has(neighbor):
					open_set.append(neighbor)

	return []

func reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array:
	var path: Array[Vector2i] = [current]
	while came_from.has(current):
		current = came_from[current]
		path.insert(0, current)
	return path
