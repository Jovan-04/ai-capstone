extends Node2D
class_name Entity

const Utils = preload("res://utils/utils.gd")
const ActionUtils = preload("res://utils/action_utils.gd")
const Action = ActionUtils.Action
const Direction = ActionUtils.Direction
const ActionType = ActionUtils.ActionType

var TILE_SIZE: int = 16
var max_health: float
var health: float
var defense: float
var attack_strength: float
var extra_time_spent: float
var alive: bool
var game

var action_costs: Dictionary

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: TextureProgressBar = $HealthBar/TextureProgressBar
@onready var tile_map: TileMapLayer = $"../TileMapLayer"


func _ready() -> void:
	self.position = get_initial_position() * TILE_SIZE + Vector2i(8, 8)
	self.max_health = 10.0
	self.health = self.max_health
	self.defense = 0.0 # percentage of damage negated
	self.attack_strength = 1.0
	self.extra_time_spent = 0.0
	self.alive = true
	self.game = get_tree().get_root().get_child(0)
	
	self.action_costs = {
		ActionType.MOVE: 1.0,
		ActionType.WAIT: 1.0,
		ActionType.ATTACK: 1.0
	}


func make_action() -> float:
	push_error("please implement this function in your subclass!")
	return 0.0


func get_current_tile():
	return Vector2i(position / TILE_SIZE - Vector2(0.5, 0.5))

func get_initial_position() -> Vector2i:
	return Vector2i(0, 0)

func get_hurt(damage: int) -> void:
	self.health = max(self.health - damage * (1.0 - self.defense), 0.0)
	if self.health == 0:
		self.alive = false


func is_attack_valid(tile: Vector2i) -> bool:
	return (self.get_current_tile() - tile) in Utils.DIRECTION_OFFSETS.values()

func is_move_valid(direction: Direction) -> bool:
	var target_tile: Vector2i = self.get_current_tile() + Utils.DIRECTION_OFFSETS[direction]
	# TODO: should probably make the game size (18 x 12) properties of `game`
	if target_tile.x < 0 or target_tile.x > 17 or target_tile.y < 0 or target_tile.y > 11:
		return false
	
	return true


func attack(tile: Vector2i):
	push_error("please implement this function in your subclass!")

func move(direction: Direction) -> void:
	self.position += Vector2(Utils.DIRECTION_OFFSETS[direction] * TILE_SIZE)
