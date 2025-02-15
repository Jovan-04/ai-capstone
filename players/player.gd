extends Node2D

enum Direction {UP, RIGHT, DOWN, LEFT}

var tile_position: Vector2i = Vector2i(0, 0)
var TILE_SIZE: int = 16

func _ready() -> void:
	self.position = tile_position * TILE_SIZE + Vector2i(8, 8)
	

func move(direction: Direction):
	match direction:
		Direction.UP:
			self.position += Vector2(0, -1) * TILE_SIZE
		Direction.RIGHT:
			self.position += Vector2(1, 0) * TILE_SIZE
		Direction.LEFT:
			self.position += Vector2(-1, 0) * TILE_SIZE
		Direction.DOWN:
			self.position += Vector2(0, 1) * TILE_SIZE

func make_action():
	self.move(Direction.values()[randi() % Direction.size()])
