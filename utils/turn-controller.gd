extends Node2D

@onready var paladin: Player = $Paladin
@onready var wizard: Player = $Wizard
@onready var assassin: Player = $Assassin
@onready var wave_number_label: Label = $TileMapLayer/WaveNumberLabel
@onready var HOVERED_TILE = load("res://materials/hoveredTile.tres")
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

const CYCLOPS = preload("res://enemies/cyclops.tscn")
const RAT = preload("res://enemies/rat.tscn")
const SORCERER = preload("res://enemies/sorcerer.tscn")

const TILE_SIZE: int = 16
var wave_number: int = 1

var players: Array[Player] = []
var enemies: Array[Enemy] = []

var mouseTilePos = floor(get_global_mouse_position() / 16) + Vector2(-1,-1);
var collision_tiles = []
func _ready() -> void:
	await get_tree().process_frame
	update_labels()
	
	#Changes the filemap to have collision
	for tile in collision_tiles:
		tile_map_layer.set_cell(Vector2i(tile[0],tile[1]), 0, Vector2i(4,3))
	players.push_back(paladin)
	players.push_back(wizard)
	players.push_back(assassin)
	
	
	while true:
		if enemies == []:
			# this logic is bizarre - we're adding the wave number after spawning everything?
			# yes we are, very good, very good -Nick
			wave_number_label.text = "Wave\n" + str(wave_number)
			for i in range(wave_number):
				spawn_enemy()
			wave_number += 1
			
		for player: Player in players:
			#HARD CODED
			if player.name == "Wizard":
				player.should_draw_line = true
			await process_turn(player)
			#Reduce special cooldown by 1 
			player.special_turn_cooldown_cur = max(player.special_turn_cooldown_cur - 1, 0)

			#HARD CODED
			if player.name == "Wizard":
				player.should_draw_line = false
			
			await get_tree().create_timer(0.25).timeout
			
		for enemy: Enemy in enemies:
			await process_turn(enemy)
			await get_tree().create_timer(0.5).timeout

func return_grid() -> String:
	var grid: Array = []
	for i in range(12):
		var array: Array[String] = []
		array.resize(18)
		array.fill(' ')
		grid.push_back(array)
	
	for player in players:
		var pos = player.get_current_tile()
		grid[pos.y][pos.x] = player.name.left(1)
	
	for enemy in enemies:
		var pos = enemy.get_current_tile()
		grid[pos.y][pos.x] = enemy.name.left(1)
	
	for x in range(17):
		for y in range(11):
			var temp_tile = Vector2i(x, y) 
			if not tile_map_layer.get_cell_tile_data(temp_tile + Vector2i(-9,-6)).get_custom_data("Walkable"):
				grid[y][x] = "X"
	
	
	var string_grid = ""
	string_grid += "----------------------------------------------------------\n"
	for row in grid:
		string_grid += str(row) + "\n"
	
	return string_grid


func process_turn(entity: Entity) -> void:
	var time_left: float = 1.0 - entity.extra_time_spent
	while time_left > 0.0:
		var time_spent = await entity.make_action()
		time_left -= time_spent
		check_for_deaths()
		update_labels()
	entity.extra_time_spent = time_left * -1 # we over-used time, so time_left is now negative; we need to make it positive so we can subtract it properly next turn


func check_for_deaths() -> void:
	for i in range(len(players)-1, -1, -1):
		var curr_player: Player = players[i]
		if not curr_player.alive:
			players.remove_at(i)
			curr_player.queue_free()
			
	for i in range(len(enemies)-1, -1, -1):
		var curr_enemy = enemies[i]
		if not curr_enemy.alive:
			enemies.remove_at(i)
			curr_enemy.queue_free()


func update_labels() -> void:
	for player: Player in players:
		if player:
			player.health_bar.max_value = player.max_health
			player.health_bar.value = player.health
	
	for enemy: Enemy in enemies:
		enemy.health_bar.max_value = enemy.max_health
		enemy.health_bar.value = enemy.health


# TODO: rewrite this to support multiple enemy types and other stuff
# TODO: also it's just a mess lol
func spawn_enemy():
	var rand_x = randi_range(0, 15)
	var rand_y = randi_range(0, 11)
	var rand_tile = Vector2i(rand_x, rand_y)
	var curr_enemy: Enemy
	match randi_range(0, 2):
		0: curr_enemy = CYCLOPS.instantiate()
		1: curr_enemy = RAT.instantiate()
		2: curr_enemy = SORCERER.instantiate()
	
	enemies.append(curr_enemy)
	curr_enemy.name = "Enemy" + str(len(enemies))
	add_child(curr_enemy)
	curr_enemy.position = rand_tile * TILE_SIZE + Vector2i(8, 8)
	update_labels()

#This is used to send the global mouse position to the shader, which highlights under the cursor
func _process(delta: float) -> void:
	mouseTilePos = floor(get_global_mouse_position() / 16) + Vector2(-1,-1);
	wizard.queue_redraw()
	HOVERED_TILE.set_shader_parameter("globalMousePos", get_global_mouse_position())
