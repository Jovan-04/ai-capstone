extends Player

func _ready() -> void:
	super._ready()
	self.max_health = 20
	self.health = self.max_health
	self.defense = 0.2

func get_initial_position() -> Vector2i:
	return Vector2i(5, 4)
