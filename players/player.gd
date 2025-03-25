extends Entity
class_name Player

var played_by_real_player: bool

func _ready() -> void:
	super._ready()
	self.played_by_real_player = true


func make_action() -> float:
	animated_sprite.modulate = Color(0, 1.2, 0)
	var selected_move: Action
	
	if self.played_by_real_player:
		selected_move = await get_player_input()
	else:
		selected_move = await prompt_llm()
	
	animated_sprite.modulate = Color(1, 1, 1)
	
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


func get_player_input() -> Action:
	var move_actions = {
		"move_up": Direction.UP,
		"move_right": Direction.RIGHT,
		"move_down": Direction.DOWN,
		"move_left": Direction.LEFT,
	}
	
	while true:
		await get_tree().process_frame
		
		for move_action: String in move_actions.keys():
			if not Input.is_action_just_pressed(move_action):
				continue
			
			var dir: Direction = move_actions[move_action]
			for enemy in game.enemies:
				if enemy.get_current_tile() == self.get_current_tile() + Utils.DIRECTION_OFFSETS[dir]:
					return Action.new(ActionType.ATTACK, {"tile": self.get_current_tile() + Utils.DIRECTION_OFFSETS[dir]})
			
			if not is_move_valid(dir):
				continue
			
			return Action.new(ActionType.MOVE, {"direction": dir})

		if Input.is_action_just_pressed("click"):
			var mouse_pos = get_global_mouse_position()
			var tile_pos: Vector2i = tile_map.local_to_map(tile_map.to_local(mouse_pos))
			tile_pos += Vector2i(9, 6) # not really sure why we need to add this...
			
			if not is_attack_valid(tile_pos): # attack out of range, etc.
				continue
			
			return Action.new(ActionType.ATTACK, {"tile": tile_pos})
		
		if Input.is_action_just_pressed("wait"):
			return Action.new(ActionType.WAIT)
	
	return Action.new(ActionType.WAIT)

# TODO: not sure how we want to do this
func prompt_llm() -> Action:
	return null


func attack(tile: Vector2i) -> void:
	for enemy in game.enemies:
		if enemy.get_current_tile() == tile:
			enemy.get_hurt(self.attack_strength)
