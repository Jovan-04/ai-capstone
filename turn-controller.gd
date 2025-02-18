extends Node2D
@onready var tilemap = $TileMapLayer

@onready var player1 = $Player
@onready var enemy1 = $Enemy
@onready var player2 = $Player2
@onready var player1_health: Label = $"TileMapLayer/Player1 Health"
@onready var player2_health: Label = $"TileMapLayer/Player2 Health"
@onready var enemy_health: Label = $"TileMapLayer/Enemy Health"


var players: Array = []
var enemies: Array = []

func _ready() -> void:
	
	await get_tree().process_frame
	players.append(player1)
	enemies.append(enemy1)
	players.append(player2)

	while true:
		player1_health.text = "Player1 Health:" + str(player1.health)
		player2_health.text = "Player2 Health:" + str(player2.health)
		enemy_health.text = "Enemy Health:" + str(enemy1.health)
		
		for player in players:
			await player.make_action()
			await get_tree().create_timer(0.25).timeout
		
		for enemy in enemies:
			await enemy.make_action()
			await get_tree().create_timer(0.5).timeout
