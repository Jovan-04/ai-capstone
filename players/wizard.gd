extends Player

func get_initial_position() -> Vector2i:
	return Vector2i(2, 0)

func is_attack_valid(tile: Vector2i) -> bool:
	return true
