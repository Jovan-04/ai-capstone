extends Player

func _ready() -> void:
	super._ready()
	self.action_costs[ActionType.MOVE] = 0.5

func get_initial_position() -> Vector2i:
	return Vector2i(3, 3)

func special(tile: Vector2i) -> void:	
	self.position = (Vector2(tile) + Vector2(.5,.5)) * TILE_SIZE
	
func special_valid(tile: Vector2i)-> bool:
	
	for player in game.players:
		if tile == player.get_current_tile():
			return false
	for enemy in game.enemies:
		if tile == enemy.get_current_tile():
			return false
			
	var walkable = tile_map.get_cell_tile_data(tile + Vector2i(-9,-6)).get_custom_data("Walkable")
	if walkable:
		return true	
	return false

func prompt_llm() -> Action:
	while true:
		var paladin_prompt_start_prompt = "You play as a Assassin in our game. You can attack up, left, right, or down, and move in the same directions.
		There are two other players, a wizard who can attack anything in it's line of sight, and an paladin, that attacks and moves the same as you. A key difference is that you get two moves,
		Each player also has a special move. The Paladin can heal itself and teamates within 3 squares.
		The wizard can build walls in a plus sign formation. The assassin can teleport to anywhere on the map. On your turn, you will be given
		a board of displaying where each player is, A for Assassin, P for Paladin, W for Wizard, and E for enemies.Finally, an X means that there is a wall there, and
		both players and enemies are unable to pass through it.  It is important to note that the special moves have a FIVE TURN COOLDOWN. The cooldown starts at FIVE to start the game, so you can't special immediatley. 
		You must return a string with one of the following to make your move as the Assassin. {ATTACK_UP,ATTACK_LEFT,ATTACK_DOWN,ATTACK_RIGHT,MOVE_UP,MOVE_LEFT,MOVE_DOWN,MOVE_RIGHT,SPECIAL}."
		
		var current_grid = game.return_grid()
		var current_turn_prompt = "The current grid is:" + str(current_grid) + ". Your special cooldown is currently at:" + str(special_turn_cooldown_cur) + ". Using this info, return your move:{ATTACK_UP,ATTACK_LEFT,ATTACK_DOWN,ATTACK_RIGHT,MOVE_UP,MOVE_LEFT,MOVE_DOWN,MOVE_RIGHT,SPECIAL}.
		A tile position is also needed for SPECIAL or an ATTACK, in those cases, return 'YOUR_MOVE | (X, Y)]'"
		var error_prompt = ""
		var final_prompt = paladin_prompt_start_prompt + error_prompt + current_turn_prompt
		
		
		var string_actions = ["ATTACK_UP","ATTACK_LEFT","ATTACK_DOWN","ATTACK_RIGHT","MOVE_UP","MOVE_LEFT","MOVE_DOWN","MOVE_RIGHT","SPECIAL","WAIT"]
		var response = await $"../LLMHandler".dialogue_request(final_prompt)
		
		print("Prompt:", final_prompt)
		print("Response:", response)
		
		
		var target_tile
		if "SPECIAL" in response or "ATTACK" in response:
			target_tile = Vector2(
			float(response.substr(response.rfind("(") + 1, response.rfind(",") - response.rfind("(") - 1)),
			float(response.substr(response.rfind(",") + 1, response.rfind(")") - response.rfind(",") - 1))
			)
		
		
		var attempted_action = ""
		for string_action in string_actions:
			if string_action in response:
				attempted_action = string_action
				break
		
		
			
		
		
		match attempted_action:
			"ATTACK_UP":
				if is_attack_valid(self.get_current_tile() + Utils.DIRECTION_OFFSETS[Direction.UP]):
					error_prompt = ""
					return Action.new(ActionType.ATTACK, {"tile": target_tile})
				else:
					error_prompt = "There is no enemy above, you can't attack that way!"
			"ATTACK_LEFT":
				if is_attack_valid(self.get_current_tile() + Utils.DIRECTION_OFFSETS[Direction.LEFT]):
					error_prompt = ""
					return Action.new(ActionType.ATTACK, {"tile": target_tile})
				else:
					error_prompt = "There is no enemy to your left, you can't attack that way!"
			"ATTACK_DOWN":
				if is_attack_valid(self.get_current_tile() + Utils.DIRECTION_OFFSETS[Direction.DOWN]):
					error_prompt = ""
					return Action.new(ActionType.ATTACK, {"tile": target_tile})
				else:
					error_prompt = "There is no enemy below, you can't attack that way!"
			"ATTACK_RIGHT":
				if is_attack_valid(self.get_current_tile() + Utils.DIRECTION_OFFSETS[Direction.RIGHT]):
					error_prompt = ""
					return Action.new(ActionType.ATTACK, {"tile": target_tile})
				else:
					error_prompt = "There is no enemy to your right, you can't attack that way!"
			"MOVE_UP":
				if is_move_valid(Direction.UP):
					error_prompt = ""
					return Action.new(ActionType.MOVE, {"direction": Direction.UP})
				else:
					error_prompt = "Something is in the way above, you can't move that way!"
			"MOVE_LEFT":
				if is_move_valid(Direction.LEFT):
					error_prompt = ""
					return Action.new(ActionType.MOVE, {"direction": Direction.LEFT})
				else:
					error_prompt = "Something is in the way to your left, you can't move that way!"
			"MOVE_DOWN":
				if is_move_valid(Direction.DOWN):
					error_prompt = ""
					return Action.new(ActionType.MOVE, {"direction": Direction.DOWN})
				else:
					error_prompt = "Something is in the way below, you can't move that way!"
			"MOVE_RIGHT":
				if is_move_valid(Direction.RIGHT):
					error_prompt = ""
					return Action.new(ActionType.MOVE, {"direction": Direction.RIGHT})
				else:
					error_prompt = "Something is in the way to your right, you can't move that way!"
			"SPECIAL":
				if special_valid(Vector2(0,0)):
					error_prompt = ""
					return Action.new(ActionType.SPECIAL, {"tile": target_tile})
				else:
					error_prompt = "You may have chosen and invalid location to teleport! You must also wait til your special cooldown is 0 to perform your special action if you hadn't already."
			"WAIT":
				error_prompt = ""
				return Action.new(ActionType.WAIT)	
			_:
				pass
				
	return Action.new(ActionType.MOVE, {"direction": Direction.UP})
