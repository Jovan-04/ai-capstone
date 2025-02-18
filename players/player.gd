extends Node2D
class_name Player

enum Direction {UP, RIGHT, DOWN, LEFT}
var TILE_SIZE: int = 16
var played_by_real_player: bool = true
var health  = 10
var power   = 1
var game
func get_initial_position() -> Vector2i:
	return Vector2i(0, 0)

func get_hurt(damage :int) -> void:
	health -= damage


func _ready() -> void:
	self.position = get_initial_position() * TILE_SIZE + Vector2i(8, 8)
	game = get_tree().get_root().get_child(0)


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
	if Input.is_action_pressed("Attack"):
		self.attack(move)
	else:
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

func attack(direction : Direction) -> void:
	var attack_tile
	match direction:
		Direction.UP:
			attack_tile = get_current_tile() + Vector2(0,-1)
		Direction.RIGHT:
			attack_tile = get_current_tile() + Vector2(1,0)
		Direction.LEFT:
			attack_tile = get_current_tile() + Vector2(-1,0)
		Direction.DOWN:
			attack_tile = get_current_tile() + Vector2(0,1)
	print("Attacking Tile:", attack_tile)
	for enemy in game.enemies:
		print("Checking for Enemy")
		if enemy.get_current_tile() == attack_tile:
			print("Enemy Hurt")
			enemy.get_hurt(self.power)
			print(enemy.health)
