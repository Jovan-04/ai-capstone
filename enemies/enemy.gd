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
			player = current_player
	
	if not player:
		var random_index = randi_range(0,3)
		var dir: Direction
		match random_index:
			0: dir = Direction.UP
			1: dir = Direction.RIGHT
			2: dir = Direction.DOWN
			3: dir = Direction.LEFT
		return Action.new(ActionType.MOVE, {"direction": dir})
		
	var dist: int = Utils.travel_distance_between(player.get_current_tile(), self.get_current_tile())
	if dist <= 1: # within attack range, attack
		return Action.new(ActionType.ATTACK, {"tile": player.get_current_tile()})
	
	# too far away, we move
	var direction: Direction
	var delta: Vector2i = player.get_current_tile() - self.get_current_tile()
	
	if abs(delta.x) < abs(delta.y):
		# move vertically
		match delta.y < 0:
			true: direction = Direction.UP
			false: direction = Direction.DOWN
	else:
		# move horizontally
		match delta.x < 0:
			true: direction = Direction.LEFT
			false: direction = Direction.RIGHT
	
	# if another enemy is in the way, just stand still
	for enemy in game.enemies:
		if enemy.get_current_tile() == self.get_current_tile() + Utils.DIRECTION_OFFSETS[direction]:
			return Action.new(ActionType.WAIT)
	
	return Action.new(ActionType.MOVE, {"direction": direction})
