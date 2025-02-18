extends Node2D
class_name Player

enum Direction {UP, RIGHT, DOWN, LEFT}
var TILE_SIZE: int = 16
var played_by_real_player: bool = true
var health  = 10


func get_initial_position() -> Vector2i:
	return Vector2i(0, 0)

func get_hurt(damage :int) -> void:
	health -= damage


func _ready() -> void:
	self.position = get_initial_position() * TILE_SIZE + Vector2i(8, 8)

func get_current_tile():
	return position / TILE_SIZE - Vector2(.5,.5)

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
	self.modulate = Color(0, 1.2, 0)
	var move: Direction
	
	if played_by_real_player:
		move = await get_player_input()
	
	self.modulate = Color(1, 1, 1)
	self.move(move)


func get_player_input() -> Direction:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("move_up"):
			return Direction.UP
		elif Input.is_action_just_pressed("move_right"):
			return Direction.RIGHT
		elif Input.is_action_just_pressed("move_down"):
			return Direction.DOWN
		elif Input.is_action_just_pressed("move_left"):
			return Direction.LEFT
			
	push_error("something bad happened")
	return Direction.UP

func attack(col: int, row: int) -> void:
	print("make an attack!!!!!!!!")
