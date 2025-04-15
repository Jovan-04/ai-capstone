extends Node

const Direction = preload("res://utils/action_utils.gd").Direction

const DIRECTION_OFFSETS: Dictionary = {
	Direction.UP: Vector2i(0, -1),
	Direction.RIGHT: Vector2i(1, 0),
	Direction.DOWN: Vector2i(0, 1),
	Direction.LEFT: Vector2i(-1, 0),
}
