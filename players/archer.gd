extends Player

func get_initial_position() -> Vector2i:
	return Vector2i(6, 4)

func attack(direction : Direction) -> void:
	super.attack(direction)
	print("archer shooty")
