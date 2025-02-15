extends Player

func get_initial_position() -> Vector2i:
	return Vector2i(4, 4)
	
func attack(col: int, row: int) -> void:
	print("warrior stabby")
