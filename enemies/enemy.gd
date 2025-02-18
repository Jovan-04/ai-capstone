extends Node2D

enum Direction {UP, RIGHT, DOWN, LEFT}
var tile_position: Vector2i = Vector2i(-4, -4)
var TILE_SIZE: int = 16
var game
var health = 10
var power = 1
func _ready() -> void:
	self.position = tile_position * TILE_SIZE + Vector2i(8, 8)
	#This will error if game is not in very specific spot in tree *TEMPORARY*
	game = get_tree().get_root().get_child(0)
	
	


func make_action():
	var player
	var smallest = 100000000
	for current_player in game.players:
		var diff = abs(current_player.position - self.position)
		if diff.x + diff.y < smallest:
			smallest = diff.x + diff.y
			player = current_player
	if player:
		var player_tile_vector = player.position / TILE_SIZE
		var enemy_tile_vector = position / TILE_SIZE
		var dist = abs(player_tile_vector - enemy_tile_vector)
		dist = Vector2(round(dist.x),round(dist.y))
		print(dist)

		var direction
		if dist.x + dist.y > 1:
			print("Move")
			if dist.x > dist.y:
				if player_tile_vector.x - enemy_tile_vector.x > 0:
					direction = Direction.RIGHT
				else:
					direction = Direction.LEFT
			else:
				if player_tile_vector.y - enemy_tile_vector.y > 0:
					direction = Direction.DOWN
				else:
					direction = Direction.UP
			self.move(direction)
		else:
			
			attack()
					
			
	else:
		#No player found on board
		var random_index = randi_range(0,3)
		var dir
		match random_index:
			0: dir = Direction.UP
			1: dir = Direction.RIGHT
			2: dir = Direction.DOWN
			3: dir = Direction.LEFT
		self.move(dir)

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

func attack() -> void:
	for current_player in game.players:
		var diff = current_player.get_current_tile() - get_current_tile()
		if abs(diff.x) + abs(diff.y) == 1:
			current_player.get_hurt(power)

func check_attack_radius():
	pass



func get_current_tile():
	return position / TILE_SIZE - Vector2(.5,.5)
