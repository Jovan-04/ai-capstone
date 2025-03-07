extends Player

func _ready() -> void:
	super._ready()
	self.action_costs[ActionType.MOVE] = 0.5

func get_initial_position() -> Vector2i:
	return Vector2i(3, 3)

func make_action() -> float:
	await super.make_action()
	return 0.5
