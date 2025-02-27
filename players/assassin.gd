extends Player

var assassin_max_health = 10
var assassin_cur_health = assassin_max_health

var assassin_power = 2




func get_initial_position() -> Vector2i:
	return Vector2i(3, 3)

func get_hurt(damage :int) -> void:
	assassin_cur_health = max(assassin_cur_health - damage, 0)
	if assassin_cur_health == 0:
		alive = false


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
			enemy.get_hurt(assassin_power)

	
