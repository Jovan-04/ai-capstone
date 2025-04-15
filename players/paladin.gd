extends Player

func _ready() -> void:
	super._ready()
	self.max_health = 20
	self.health = self.max_health
	self.defense = 0.2

func get_initial_position() -> Vector2i:
	return Vector2i(5, 4)

func special(tile: Vector2i) -> void:
	print("I just healed me and those around me. Very good very good!")
	for player in game.players:
		var dist = abs(get_current_tile() - player.get_current_tile())
		if dist.x + dist.y <= 3:
			player.health += 3
	
func prompt_llm() -> Action:
	while true:
		var paladin_prompt_start_prompt = "You play as a Paladin in our game. You can attack up, left, right, or down, and move in the same directions. 
		There are two other players, a wizard who can attack anything in it's line of sight, and an assassin, that attacks the same as you,
		 but they get two moves each turn. Each player also has a special move. The Paladin can heal itself and teamates within 3 squares.
		The wizard can build walls in a plus sign formation. The assassin can teleport to anywhere on the map. On your turn, you will be given
		a board of displaying where each player is, A for Assassin, P for Paladin, W for Wizard, and finally E for enemies. It is important
		to note that the special moves have a FIVE TURN COOLDOWN. The cooldown starts at three to start the game, so you can't special immediatley. 
		You must return a string with one of the following to make your move as the paladin. {ATTACK_UP,ATTACK_LEFT,ATTACK_DOWN,ATTACK_RIGHT,MOVE_UP,MOVE_LEFT,MOVE_DOWN,MOVE_RIGHT,SPECIAL}."
		
		var current_grid = game.return_grid()
		var current_turn_prompt = "The current grid is:" + str(current_grid) + ". Your special cooldown is currently at:" + str(special_turn_cooldown_cur) + ". Using this info, return your move:{ATTACK_UP,ATTACK_LEFT,ATTACK_DOWN,ATTACK_RIGHT,MOVE_UP,MOVE_LEFT,MOVE_DOWN,MOVE_RIGHT,SPECIAL}"
		var error_prompt = ""
		var final_prompt = paladin_prompt_start_prompt + error_prompt + current_turn_prompt
		
		
		var string_actions = ["ATTACK_UP","ATTACK_LEFT","ATTACK_DOWN","ATTACK_RIGHT","MOVE_UP","MOVE_LEFT","MOVE_DOWN","MOVE_RIGHT","SPECIAL","WAIT"]
		var response = await $"../LLMHandler".dialogue_request(final_prompt)
		
		print("Prompt:", final_prompt)
		print("Response:", response)
		
		var attempted_action = ""
		for string_action in string_actions:
			if string_action in response:
				attempted_action = string_action
				break
		match attempted_action:
			"ATTACK_UP":
				if is_attack_valid(self.get_current_tile() + Utils.DIRECTION_OFFSETS[Direction.UP]):
					error_prompt = ""
					return Action.new(ActionType.ATTACK, {"tile": get_current_tile() + Vector2i(0,-1)})
				else:
					error_prompt = "There is no enemy above, you can't attack that way!"
			"ATTACK_LEFT":
				if is_attack_valid(self.get_current_tile() + Utils.DIRECTION_OFFSETS[Direction.LEFT]):
					error_prompt = ""
					return Action.new(ActionType.ATTACK, {"tile": get_current_tile() + Vector2i(-1,0)})
				else:
					error_prompt = "There is no enemy to your left, you can't attack that way!"
			"ATTACK_DOWN":
				if is_attack_valid(self.get_current_tile() + Utils.DIRECTION_OFFSETS[Direction.DOWN]):
					error_prompt = ""
					return Action.new(ActionType.ATTACK, {"tile": get_current_tile() + Vector2i(0,1)})
				else:
					error_prompt = "There is no enemy beloww, you can't attack that way!"
			"ATTACK_RIGHT":
				if is_attack_valid(self.get_current_tile() + Utils.DIRECTION_OFFSETS[Direction.RIGHT]):
					error_prompt = ""
					return Action.new(ActionType.ATTACK, {"tile": get_current_tile() + Vector2i(1,0)})
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
					return Action.new(ActionType.SPECIAL, {"tile": Vector2(0,0)})
				else:
					error_prompt = "You must wait til your special cooldown is 0 to perform your special action!"
			"WAIT":
				error_prompt = ""
				return Action.new(ActionType.WAIT)	
			_:
				pass
				
	return Action.new(ActionType.MOVE, {"direction": Direction.UP})
	
	
