extends Player

func _ready() -> void:
	super._ready()
	self.action_costs[ActionType.MOVE] = 0.5

func get_initial_position() -> Vector2i:
	return Vector2i(3, 3)

func special(tile: Vector2i) -> void:	
	self.position = (Vector2(tile) + Vector2(.5,.5)) * TILE_SIZE
	
func special_valid(tile: Vector2i)-> bool:
	
	for player in game.players:
		if tile == player.get_current_tile():
			return false
	for enemy in game.enemies:
		if tile == enemy.get_current_tile():
			return false
			
	var walkable = tile_map.get_cell_tile_data(tile + Vector2i(-9,-6)).get_custom_data("Walkable")
	if walkable:
		return true	
	return false
