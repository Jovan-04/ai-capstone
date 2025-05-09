extends Entity
class_name Enemy

func make_action() -> float:
	var selected_move: Action
	
	selected_move = self.get_best_action()
	
	match selected_move.type:
		ActionType.WAIT:
			return self.action_costs[ActionType.WAIT]
		ActionType.MOVE:
			move(selected_move.params["direction"])
			return self.action_costs[ActionType.MOVE]
		ActionType.ATTACK:
			attack(selected_move.params["tile"])
			return self.action_costs[ActionType.ATTACK]
		_: # this default case feels like it shouldn't be needed... isn't the point of an enum that you can only have certain values?
			return 1.0

# still not sure how I feel about this AI, but it's what we have right now
func get_best_action() -> Action:
	var player: Player
	var smallest: int = 100000000
	
	for current_player in game.players:
		var diff = abs(current_player.position - self.position)
		if diff.x + diff.y < smallest:
			smallest = diff.x + diff.y
			player   = current_player
	
	
	if not player:
		var random_index = randi_range(0,3)
		var dir: Direction
		match random_index:
			0: dir = Direction.UP
			1: dir = Direction.RIGHT
			2: dir = Direction.DOWN
			3: dir = Direction.LEFT
		return Action.new(ActionType.MOVE, {"direction": dir})
	
	var direction = AStartPathFinding(get_current_tile(), player.get_current_tile())
	
	#Next to player, so they don't need to move
	if direction == -1:
		return Action.new(ActionType.ATTACK, {"tile": player.get_current_tile()})
		
	# if another enemy is in the way, just stand still
	for enemy in game.enemies:
		if enemy.get_current_tile() == self.get_current_tile() + Utils.DIRECTION_OFFSETS[direction]:
			return Action.new(ActionType.WAIT)
	
	return Action.new(ActionType.MOVE, {"direction": direction})


func AStartPathFinding(startTile: Vector2i, endTile : Vector2i):
	var astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(1, 1, 18, 12)
	astar_grid.cell_size = Vector2(TILE_SIZE, TILE_SIZE)
	astar_grid.diagonal_mode = 1
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.update()
	for x in range(17):
		for y in range(11):
			var temp_tile = Vector2i(x, y) 
			if not tile_map.get_cell_tile_data(temp_tile + Vector2i(-9,-6)).get_custom_data("Walkable"):
				astar_grid.set_point_solid((temp_tile))
				
	var path = astar_grid.get_id_path(startTile, endTile)
	var move_to_tile = "EMPTY"
	if len(path) <= 2:
		return -1
	else:
		move_to_tile = Vector2i(-Vector2i(startTile - path[1]).x, Vector2i(startTile - path[1]).y)
		match move_to_tile:
			Vector2i(-1, 0)  :
				return Direction.LEFT
			Vector2i( 1,  0) : 
				return Direction.RIGHT
			Vector2i( 0, -1) : 
				return Direction.DOWN
			Vector2i( 0,  1) : 
				return Direction.UP
	

func attack(tile: Vector2i):
	for player: Player in self.game.players:
		if player.get_current_tile() == tile:
			player.get_hurt(self.attack_strength)
