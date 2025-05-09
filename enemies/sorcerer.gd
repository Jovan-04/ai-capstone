extends Enemy

func get_best_action() -> Action:
	var player: Player
	var smallest: int = 100000000
	print("____________________________________________________________")
	print(game.players)
	for current_player in game.players:
		print(current_player.get_current_tile(),is_attack_valid(current_player.get_current_tile()))
		if is_attack_valid(current_player.get_current_tile()):
			return Action.new(ActionType.ATTACK, {"tile": current_player.get_current_tile()})
			
		var diff = abs(current_player.position - self.position)
		if diff.x + diff.y < smallest:
			smallest = diff.x + diff.y
			player   = current_player
	print("____________________________________________________________")
	if not player:
		var random_index = randi_range(0,3)
		var dir: Direction
		match random_index:
			0: dir = Direction.UP
			1: dir = Direction.RIGHT
			2: dir = Direction.DOWN
			3: dir = Direction.LEFT
		return Action.new(ActionType.MOVE, {"direction": dir})
	else:
		var direction = AStartPathFinding(get_current_tile(), player.get_current_tile())
		return Action.new(ActionType.MOVE, {"direction": direction})


func is_attack_valid(tile: Vector2i) -> bool:
	var line_of_sight = get_line_tiles(get_current_tile(), tile)
	print(line_of_sight)
	for viewed_tile in line_of_sight:
		var walkable = tile_map.get_cell_tile_data(Vector2i(viewed_tile) + Vector2i(-9,-6)).get_custom_data("Walkable")
		if walkable:
			for player in game.players:
				if Vector2(player.get_current_tile()) == Vector2(viewed_tile) and Vector2i(viewed_tile) != tile:
					print("Hit Player", viewed_tile)
					return false
			for enemy in game.enemies:
				if Vector2(enemy.get_current_tile()) == Vector2(viewed_tile):
					print("Hit Enemy Early", viewed_tile)
					return false
		else:
			print("Hit Wall", viewed_tile)
			return false
	for player in game.players:
		if Vector2i(player.get_current_tile()) == Vector2i(tile):
			#print("Attack Enemy")
			return true
	return false
	
	
func get_line_tiles(start_point: Vector2, end_point: Vector2) -> Array:
	var points = []
	var n = 20
	for i in range(n):
		var t = i / float(n - 1)  # normalized position from 0.0 to 1.0
		var point = start_point.lerp(end_point, t)
		points.append(point)
			
	var rounded = []
	for point in points:
		if round(point) != start_point and round(point) not in rounded:
			rounded.append(round(point))
	
	return rounded
