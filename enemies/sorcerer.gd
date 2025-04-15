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
	var tile_size := 16
	
	var x0 = int(start_point.x)
	var y0 = int(start_point.y)
	var x1 = int(end_point.x)
	var y1 = int(end_point.y)
	
	var tiles: Array = []
	
	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	var sx
	if x1 >= x0:
		sx = 1
	else:
		sx = -1
	var sy
	if y1 >= y0:
		sy = 1
	else:
		sy = -1
	
	var err = dx - dy
	
	while true:
		var pos := Vector2(x0, y0)
		if pos not in tiles:
			tiles.append(pos)
		
		if x0 == x1 and y0 == y1:
			break
		
		var e2 = 2 * err
		
		if e2 > -dy:
			if e2 == -dy and (pos + Vector2(0, sy)) not in tiles:
				tiles.append(pos + Vector2(0, sy))
			err -= dy
			x0 += sx
		
		if e2 < dx:
			if e2 == dx and (pos + Vector2(sx, 0)) not in tiles:
				tiles.append(pos + Vector2(sx, 0))
			err += dx
			y0 += sy
	
	#Remove the entity itself.
	tiles.remove_at(0)
	#Remove extra tile at end.
	tiles.remove_at(-1)
	return tiles
