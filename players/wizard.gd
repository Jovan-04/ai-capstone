extends Player

var collision_tiles = [Vector2i(0,0),Vector2i(0,1),Vector2i(0,-1),Vector2i(1,0),Vector2i(-1,0)]
var should_draw_line = false
func get_initial_position() -> Vector2i:
	return Vector2i(2, 0)


#This code is not pretty but it does the job
func is_attack_valid(tile: Vector2i) -> bool:
	var line_of_sight = get_line_tiles(get_current_tile(), (Vector2(get_current_tile()) + game.mouseTilePos - Vector2(1,-1)))
	print(line_of_sight)
	for viewed_tile in line_of_sight:
		var walkable = tile_map.get_cell_tile_data(Vector2i(viewed_tile) + Vector2i(-9,-6)).get_custom_data("Walkable")
		if walkable:
			for player in game.players:
				if Vector2(player.get_current_tile()) == Vector2(viewed_tile):
					print("Hit Player", viewed_tile)
					return false
			for enemy in game.enemies:
				if Vector2(enemy.get_current_tile()) == Vector2(viewed_tile) and Vector2i(viewed_tile) != tile:
					print("Hit Enemy Early", viewed_tile)
					return false
		else:
			print("Hit Wall", viewed_tile)
			return false
	for enemy in game.enemies:
		if Vector2i(enemy.get_current_tile()) == Vector2i(tile):
			#print("Attack Enemy")
			return true
	return false

func _draw() -> void:
	var end_draw_tile = game.mouseTilePos
	var line_of_sight = get_line_tiles(get_current_tile(), (Vector2(get_current_tile()) + game.mouseTilePos - Vector2(1,-1)))
	for viewed_tile in line_of_sight:
		var walkable = tile_map.get_cell_tile_data(Vector2i(viewed_tile) + Vector2i(-9,-6)).get_custom_data("Walkable")
		if walkable:
			for player in game.players:
				if Vector2(player.get_current_tile()) == Vector2(viewed_tile):
					#print("Hit Player", viewed_tile)
					end_draw_tile = viewed_tile + Vector2(-1,-1)
					break
			for enemy in game.enemies:
				if Vector2(enemy.get_current_tile()) == Vector2(viewed_tile):
					#print("Hit Enemy Early", viewed_tile)
					end_draw_tile = viewed_tile + Vector2(-1,-1)
					break
		else:
			#print("Hit Wall", viewed_tile)
			end_draw_tile = viewed_tile + Vector2(-1,-1)
			break
	if should_draw_line:
		draw_line(Vector2.ZERO, (Vector2(2,0) - Vector2(get_current_tile()) + end_draw_tile - Vector2(1,-1)) * 16, Color.RED)
		
		
	
func special(tile: Vector2i) -> void:
	var temp = []
	for col_tile in collision_tiles:
		temp.append(col_tile + tile)
	for col_tile in temp:
		
		tile_map.set_cell(Vector2i(col_tile[0]-9,col_tile[1]-6), 0, Vector2i(4,3))

func special_valid(tile: Vector2i)-> bool:
	var temp = []
	for col_tile in collision_tiles:
		temp.append(col_tile + tile)
	
	if !(tile.x < 17 and tile.x > 1 and tile.y < 11 and tile.y > 1):
		return false
	
	for player in game.players:
		if player.get_current_tile() in temp:
			return false
	for enemy in game.enemies:
		if enemy.get_current_tile() in temp:
			return false
	return special_turn_cooldown_cur == 0

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
	
func prompt_llm() -> Action:
	while true:
		var paladin_prompt_start_prompt = "You play as a Wizard in our game. You can move up, left, right, or down, and attack by picking a tile in your line of sight with an enemy. 
		There are two other players, a paladin, and an assassin, that attacks only up, left down, and right and move the same,but assassin
		gets two moves each turn. Each player also has a special move. The Paladin can heal itself and teamates within 3 squares.
		The wizard can build walls in a plus sign formation. The assassin can teleport to anywhere on the map. On your turn, you will be given
		a board of displaying where each player is, A for Assassin, P for Paladin, W for Wizard, and finally E for enemies. It is important
		to note that the special moves have a FIVE TURN COOLDOWN. The cooldown starts at FIVE to start the game, so you can't special immediatley. For your special as wizard, you
		must also return a specific tile for the center of the plus sign of walls.  
		You must return a string with one of the following to make your move as the WIZARD. {ATTACK_UP,ATTACK_LEFT,ATTACK_DOWN,ATTACK_RIGHT,MOVE_UP,MOVE_LEFT,MOVE_DOWN,MOVE_RIGHT,SPECIAL}.
		A tile position is also needed for SPECIAL or an ATTACK, in those cases, return 'YOUR_MOVE | (X, Y)]'"
	
		
		var current_grid = game.return_grid()
		var current_turn_prompt = "The current grid is:" + str(current_grid) + ". Your special cooldown is currently at:" + str(special_turn_cooldown_cur) + ". Using this info, return your move:{ATTACK_UP,ATTACK_LEFT,ATTACK_DOWN,ATTACK_RIGHT,MOVE_UP,MOVE_LEFT,MOVE_DOWN,MOVE_RIGHT,SPECIAL}"
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
					error_prompt = "There is no enemy beloww, you can't attack that way!"
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
					error_prompt = "You must wait til your special cooldown is 0 to perform your special action!"
			"WAIT":
				error_prompt = ""
				return Action.new(ActionType.WAIT)	
			_:
				pass
				
	return Action.new(ActionType.MOVE, {"direction": Direction.UP})
	
	
