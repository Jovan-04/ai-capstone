extends Node2D

@onready var paladin: Player = $Paladin
@onready var wizard: Player = $Wizard
@onready var assassin: Player = $Assassin
@onready var wave_number_label: Label = $TileMapLayer/WaveNumberLabel

const TILE_SIZE: int = 16
var wave_number: int = 1

var players: Array[Player] = []
var enemies: Array = []

# change this lol
const ENEMY = preload("res://enemies/enemy.tscn")

func _ready() -> void:
	await get_tree().process_frame
	update_labels()
	
	players.push_back(paladin)
	players.push_back(wizard)
	players.push_back(assassin)	
	
	while true:
		if enemies == []:
			wave_number_label.text = "Wave\n" + str(wave_number)
			for i in range(wave_number):
				spawn_enemy()
			wave_number += 1
			
		for player in players:
			#Causes Assassin to get an extra turn
			if player.name == "Assassin":
				await player.make_action()
				check_for_deaths()
				update_labels()
			await player.make_action()
			check_for_deaths()
			update_labels()
			
			await get_tree().create_timer(0.25).timeout
		
		for enemy in enemies:
			await enemy.make_action()
			check_for_deaths()
			update_labels()
			await get_tree().create_timer(0.5).timeout
		
		print_grid()

func print_grid() -> void:
	var grid: Array = []
	for i in range(12):
		var array = [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
		grid.push_back(array)
	
	for player in players:
		var pos = player.get_current_tile()
		grid[pos.y][pos.x] = player.name.left(1)
	
	for enemy in enemies:
		var pos = enemy.get_current_tile()
		grid[pos.y][pos.x] = enemy.name.left(1)
	
	print("----------------------------------------------------------")
	for row in grid:
		print(row)


func check_for_deaths() -> void:
	for i in range(len(players)-1, -1, -1):
		var curr_player: Player = players[i]
		print(curr_player.name)
		if not curr_player.alive:
			players.remove_at(i)
			curr_player.queue_free()
			
	for i in range(len(enemies)-1, -1, -1):
		var curr_enemy = enemies[i]
		print(curr_enemy.name)
		if not curr_enemy.alive:
			players.remove_at(i)
			curr_enemy.queue_free()


func update_labels() -> void:
	for player: Player in players:
		if player:
			player.health_bar.max_value = player.max_health
			player.health_bar.value = player.health
	
	# TODO: make enemies have a .health_bar attribute too
	# really, since we're going to be implementing multiple enemy types, we should have the same class/subclass structure
	for enemy in enemies:
		enemy.get_child(1).get_child(0).value = enemy.enemy_cur_health
		enemy.get_child(1).get_child(0).max_value = enemy.enemy_max_health


# TODO: rewrite this to support multiple enemy types and other stuff
func spawn_enemy():
	var rand_x = randi_range(0, 15)
	var rand_y = randi_range(0, 11)
	var rand_tile = Vector2(rand_x, rand_y)
	
	for enemy in enemies:
		if enemy.get_current_tile() == rand_tile:
			spawn_enemy()
	for player in players:
		if player.get_current_tile() == rand_tile:
			spawn_enemy()
	var curr_enemy = ENEMY.instantiate()
	curr_enemy.position = rand_tile * TILE_SIZE + Vector2(8, 8)
	enemies.append(curr_enemy)
	curr_enemy.name = "Enemy" + str(len(enemies))
	add_child(curr_enemy)
	update_labels()
