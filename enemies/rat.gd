extends Enemy

func _ready() -> void:
	super._ready()
	self.max_health = 4
	self.health = self.max_health
