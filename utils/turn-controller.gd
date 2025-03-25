extends Node2D

@onready var paladin: Player = $Paladin
@onready var wizard: Player = $Wizard
@onready var assassin: Player = $Assassin
@onready var wave_number_label: Label = $TileMapLayer/WaveNumberLabel

const CYCLOPS = preload("res://enemies/cyclops.tscn")
const RAT = preload("res://enemies/rat.tscn")
const SORCERER = preload("res://enemies/sorcerer.tscn")

const TILE_SIZE: int = 16
var wave_number: int = 1

var players: Array[Player] = []
var enemies: Array[Enemy] = []

func _ready() -> void:
	await get_tree().process_frame
	update_labels()
	
	players.push_back(paladin)
	players.push_back(wizard)
	players.push_back(assassin)
	
	while true:
		if enemies == []:
			# this logic is bizarre - we're adding the wave number after spawning everything?
			wave_number_label.text = "Wave\n" + str(wave_number)
			for i in range(wave_number):
				spawn_enemy()
			wave_number += 1
			
		for player: Player in players:
			await process_turn(player)
			await get_tree().create_timer(0.25).timeout
		
		for enemy: Enemy in enemies:
			await process_turn(enemy)
			await get_tree().create_timer(0.5).timeout
		
		print_grid()

func print_grid() -> void:
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
	
	print("----------------------------------------------------------")
	for row in grid:
		print(row)

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
	
	print(curr_enemy.position)
	curr_enemy.position = rand_tile * TILE_SIZE + Vector2i(8, 8)
	enemies.append(curr_enemy)
	curr_enemy.name = "Enemy" + str(len(enemies))
	add_child(curr_enemy)
	update_labels()
