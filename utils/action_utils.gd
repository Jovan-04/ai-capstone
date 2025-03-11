extends Node

enum Direction { UP, RIGHT, DOWN, LEFT }
enum ActionType { WAIT, MOVE, ATTACK }

class Action:
	var type: ActionType
	var params: Dictionary
	
	func _init(action_type: ActionType, params: Dictionary = {}) -> void:
		self.type = action_type
		self.params = params
