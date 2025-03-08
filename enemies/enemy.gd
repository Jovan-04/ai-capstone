extends Node2D

const Utils = preload("res://utils/utils.gd")
const ActionUtils = preload("res://utils/action_utils.gd")
const Action = ActionUtils.Action
const Direction = ActionUtils.Direction
const ActionType = ActionUtils.ActionType

var tile_position: Vector2i = Vector2i(-4, -4)
var TILE_SIZE: int = 16
var game
var enemy_max_health = 10
var enemy_cur_health = enemy_max_health
var power = 1
var alive = true

func _ready() -> void:
	#This will error if game is not in very specific spot in tree *TEMPORARY*
	# what very specific spot?
	game = get_tree().get_root().get_child(0)


func make_action():
	var player: Player
	var smallest: int = 100000000
	
	for current_player in game.players:
		var diff = abs(current_player.position - self.position)
		if diff.x + diff.y < smallest:
			smallest = diff.x + diff.y
			player = current_player
	
	if not player:
		var random_index = randi_range(0,3)
		var dir
		match random_index:
			0: dir = Direction.UP
			1: dir = Direction.RIGHT
			2: dir = Direction.DOWN
			3: dir = Direction.LEFT
		self.move(dir)
		return
	
	var dist: int = Utils.travel_distance_between(player.get_current_tile(), self.get_current_tile())
	if dist <= 1: # within attack range, attack
		self.attack()
		return
	
	# too far away, we move
	var direction: Direction
	var delta: Vector2i = player.get_current_tile() - self.get_current_tile()
	
	if abs(delta.x) < abs(delta.y):
		# move vertically
		match delta.y < 0:
			true: direction = Direction.UP
			false: direction = Direction.DOWN
	else:
		# move horizontally
		match delta.x < 0:
			true: direction = Direction.LEFT
			false: direction = Direction.RIGHT
	
	# if another enemy is in the way, just stand still
	for enemy in game.enemies:
		if enemy.get_current_tile() == self.get_current_tile() + Utils.DIRECTION_OFFSETS[direction]:
			return
	
	self.move(direction)


func move(direction: Direction) -> void:
	self.position += Vector2(Utils.DIRECTION_OFFSETS[direction] * TILE_SIZE)

func attack() -> void:
	for current_player: Player in game.players:
		if Utils.travel_distance_between(current_player.get_current_tile(), self.get_current_tile()) == 1:
			current_player.get_hurt(power)
			break


func get_hurt(damage :int) -> void:
	enemy_cur_health = max(enemy_cur_health - damage, 0)
	if enemy_cur_health == 0:
		alive = false

func get_current_tile():
	return Vector2i(position / TILE_SIZE - Vector2(.5,.5))
