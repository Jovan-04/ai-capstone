extends Player

func get_initial_position() -> Vector2i:
	return Vector2i(-2, 5)

func attack(direction : Direction) -> void:
	super.attack(direction)
	print("assassin pokey")
