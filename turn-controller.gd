extends Node2D
@onready var tilemap = $TileMapLayer


@onready var paladin = $Paladin
@onready var archer = $Archer
@onready var assassin = $Assassin
@onready var paladin_health_bar: TextureProgressBar = $Paladin/HealthBar/TextureProgressBar
@onready var archer_health_bar: TextureProgressBar = $Archer/HealthBar/TextureProgressBar
@onready var assassin_health_bar: TextureProgressBar = $Assassin/HealthBar/TextureProgressBar
@onready var wave_number_label: Label = $TileMapLayer/WaveNumberLabel

const ENEMY = preload("res://enemies/enemy.tscn")
var TILE_SIZE: int = 16
var players: Array = []
var enemies: Array = []
var wave_number = 1
func _ready() -> void:
	update_labels()
	await get_tree().process_frame
	players.append(paladin)
	players.append(archer)
	players.append(assassin)

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
		

func update_labels():
	paladin_health_bar.value = paladin.paladin_cur_health
	paladin_health_bar.max_value = paladin.paladin_max_health
	
	archer_health_bar.value = archer.archer_cur_health
	archer_health_bar.max_value = archer.archer_max_health
	
	assassin_health_bar.value = assassin.assassin_cur_health
	assassin_health_bar.max_value = assassin.assassin_max_health
	
	for enemy in enemies:
		enemy.get_child(1).get_child(0).value = enemy.enemy_cur_health
		enemy.get_child(1).get_child(0).max_value = enemy.enemy_max_health
		
	

func check_for_deaths():
	var i = 0
	while i < len(players):
		if not players[i].alive:
			var curr_enemy = players[i]
			players.remove_at(i)
			curr_enemy.queue_free()
		else:
			i += 1 
	
	i = 0
	while i < len(enemies):
		if not enemies[i].alive:
			var curr_enemy = enemies[i]
			enemies.remove_at(i)
			curr_enemy.queue_free()
		else:
			i += 1 
	
	


func spawn_enemy():
	
	var rand_x = randi_range(-9,8)
	var rand_y = randi_range(5,-6)
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
	
	
