extends Node2D
class_name Player

const Utils = preload("res://utils/utils.gd")
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
var extra_time_spent: float
var alive: bool
var game

var action_costs: Dictionary

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: TextureProgressBar = $HealthBar/TextureProgressBar
@onready var tile_map: TileMapLayer = $"../TileMapLayer"


func _ready() -> void:
	self.position = get_initial_position() * TILE_SIZE + Vector2i(8, 8)
	self.played_by_real_player = true
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

func get_current_tile():
	return Vector2i(position / TILE_SIZE - Vector2(0.5, 0.5))

func get_initial_position() -> Vector2i:
	return Vector2i(0, 0)

func get_hurt(damage: int) -> void:
	self.health = max(self.health - damage * (1.0 - self.defense), 0.0)
	if self.health == 0:
		self.alive = false


func make_action() -> float:
	animated_sprite.modulate = Color(0, 1.2, 0)
	var selected_move: Action
	
	if self.played_by_real_player:
		selected_move = await get_player_input()
	else:
		selected_move = await prompt_llm()
	
	animated_sprite.modulate = Color(1, 1, 1)
	
	match selected_move.type:
		ActionType.WAIT:
			return self.action_costs[ActionType.WAIT]
		ActionType.MOVE:
			move(selected_move.params["direction"])
			return self.action_costs[ActionType.MOVE]
		ActionType.ATTACK:
			attack(selected_move.params["tile"])
			return self.action_costs[ActionType.ATTACK]
		_: # this default case feels like it shouldn't be needed... isn't the point of an enum that you can only have certain values?
			return 1.0


func get_player_input() -> Action:
	var move_actions = {
		"move_up": Direction.UP,
		"move_right": Direction.RIGHT,
		"move_down": Direction.DOWN,
		"move_left": Direction.LEFT,
	}
	
	while true:
		await get_tree().process_frame
		
		for move_action: String in move_actions.keys():
			if not Input.is_action_just_pressed(move_action):
				continue
			
			var dir: Direction = move_actions[move_action]
			for enemy in game.enemies:
				if enemy.get_current_tile() == self.get_current_tile() + Utils.DIRECTION_OFFSETS[dir]:
					return Action.new(ActionType.ATTACK, {"tile": self.get_current_tile() + Utils.DIRECTION_OFFSETS[dir]})
			
			if not is_move_valid(dir):
				continue
			
			return Action.new(ActionType.MOVE, {"direction": dir})

		if Input.is_action_just_pressed("click"):
			var mouse_pos = get_global_mouse_position()
			var tile_pos: Vector2i = tile_map.local_to_map(tile_map.to_local(mouse_pos))
			tile_pos += Vector2i(9, 6) # not really sure why we need to add this...
			
			if not is_attack_valid(tile_pos): # attack out of range, etc.
				continue
			
			return Action.new(ActionType.ATTACK, {"tile": tile_pos})
		
		if Input.is_action_just_pressed("wait"):
			return Action.new(ActionType.WAIT)
	
	return Action.new(ActionType.WAIT)

# TODO: not sure how we want to do this
func prompt_llm() -> Action:
	return null


func is_move_valid(direction: Direction) -> bool:
	return true

func is_attack_valid(tile: Vector2i) -> bool:
	return true


func attack(tile: Vector2i) -> void:
	for enemy in game.enemies:
		if enemy.get_current_tile() == tile:
			enemy.get_hurt(self.attack_strength)

func move(direction: Direction) -> void:
	self.position += Vector2(Utils.DIRECTION_OFFSETS[direction] * TILE_SIZE)
