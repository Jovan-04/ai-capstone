extends Node2D
class_name Player

enum Direction {UP, RIGHT, DOWN, LEFT}

var TILE_SIZE: int = 16

func get_initial_position() -> Vector2i:
	return Vector2i(0, 0)

func _ready() -> void:
	self.position = get_initial_position() * TILE_SIZE + Vector2i(8, 8)


func move(direction: Direction) -> void:
	match direction:
		Direction.UP:
			self.position += Vector2(0, -1) * TILE_SIZE
		Direction.RIGHT:
			self.position += Vector2(1, 0) * TILE_SIZE
		Direction.LEFT:
			self.position += Vector2(-1, 0) * TILE_SIZE
		Direction.DOWN:
			self.position += Vector2(0, 1) * TILE_SIZE

func make_action() -> void:
	self.move(Direction.values()[randi() % Direction.size()])

func attack(col: int, row: int) -> void:
	print("make an attack!!!!!!!!")
