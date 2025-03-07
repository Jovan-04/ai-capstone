extends Node2D
class_name Player

const ActionUtils = preload("res://utils/action_utils.gd")
const Action = ActionUtils.Action
const Direction = ActionUtils.Direction
const ActionType = ActionUtils.ActionType

var TILE_SIZE: int = 16
var played_by_real_player: bool
var max_health: float
var health: float
var defense: float
var attack_strength: float
var timer_overflow: float
var alive: bool
var game

var action_costs: Dictionary

@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar/TextureProgressBar

func get_initial_position() -> Vector2i:
	return Vector2i(0, 0)

func get_hurt(damage: int) -> void:
	self.health = max(self.health - damage * (1.0 - self.defense), 0.0)
	if self.health == 0:
		self.alive = false

func _ready() -> void:
	self.position = get_initial_position() * TILE_SIZE + Vector2i(8, 8)
	self.played_by_real_player = true
	self.max_health = 10.0
	self.health = self.max_health
	self.defense = 0.0 # percentage of damage negated
	self.attack_strength = 1.0
	self.timer_overflow = 0.0
	self.alive = true
	self.game = get_tree().get_root().get_child(0)
	
	self.action_costs = {
		ActionType.MOVE: 1.0,
		ActionType.WAIT: 1.0,
		ActionType.ATTACK: 1.0
	}

func get_current_tile():
	return position / TILE_SIZE - Vector2(0.5, 0.5)

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
	animated_sprite.modulate = Color(0, 1.2, 0)
	var move: Direction
	
	if played_by_real_player:
		move = await get_player_input()
	
	animated_sprite.modulate = Color(1, 1, 1)
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
	for enemy in game.enemies:
		if enemy.get_current_tile() == attack_tile:
			enemy.get_hurt(self.attack_strength)
