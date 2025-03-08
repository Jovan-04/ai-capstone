extends Node

const Direction = preload("res://utils/action_utils.gd").Direction

static func travel_distance_between(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

const DIRECTION_OFFSETS: Dictionary = {
	Direction.UP: Vector2i(0, -1),
	Direction.RIGHT: Vector2i(1, 0),
	Direction.DOWN: Vector2i(0, 1),
	Direction.LEFT: Vector2i(-1, 0),
}
