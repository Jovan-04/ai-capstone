extends Player

@onready var tile_map: TileMapLayer = $"../TileMapLayer"

func get_initial_position() -> Vector2i:
	return Vector2i(2, 0)

func make_action() -> float:
	animated_sprite.modulate = Color(0, 1.2, 0)
	await get_player_input()
	animated_sprite.modulate = Color(1, 1, 1)
	return 1.0

func get_player_input():
	var is_attack = false
	while true:
		await get_tree().process_frame
		# Toggle attack mode when "Attack" is pressed
		if Input.is_action_just_pressed("Attack"):
			is_attack = !is_attack
			if is_attack:
				animated_sprite.modulate = Color(1.2, 0, 0)
			else:
				animated_sprite.modulate = Color(0, 1.2, 0)
				
		# Handle movement if not in attack mode
		if not is_attack:
			if Input.is_action_just_pressed("move_up"):
				move(Direction.UP)
				break
			elif Input.is_action_just_pressed("move_right"):
				move(Direction.RIGHT)
				break
			elif Input.is_action_just_pressed("move_down"):
				move(Direction.DOWN)
				break
			elif Input.is_action_just_pressed("move_left"):
				move(Direction.LEFT)
				break

		# Handle attack mode input
		elif is_attack and Input.is_action_just_pressed("Click"):
			var mouse_pos = get_global_mouse_position()
			var tile_pos = tile_map.local_to_map(tile_map.to_local(mouse_pos))			
			for enemy in game.enemies:
				if enemy.get_current_tile() == Vector2(tile_pos):
					enemy.get_hurt(self.attack_strength)
					break
			break
	
