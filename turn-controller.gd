extends Node2D
@onready var tilemap = $TileMapLayer

@onready var player1 = $Player
@onready var enemy1 = $Enemy
@onready var player2 = $Player2
var players: Array = []
var enemies: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	players.append(player1)
	enemies.append(enemy1)
	players.append(player2)

	while true:
		for player in players:
			player.make_action()
			await get_tree().create_timer(1).timeout
		
		for enemy in enemies:
			enemy.make_action()
			await get_tree().create_timer(0.5).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
