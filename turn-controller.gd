extends Node2D
@onready var tilemap = $TileMapLayer

@onready var enemy1 = $Enemy
@onready var paladin = $Paladin
@onready var archer = $Archer
@onready var assassin = $Assassin
@onready var paladin_health: Label = $"TileMapLayer/Paladin Health"
@onready var archer_health: Label = $"TileMapLayer/Archer Health"
@onready var enemy_health: Label = $"TileMapLayer/Enemy Health"


var players: Array = []
var enemies: Array = []

func _ready() -> void:
	update_labels()
	await get_tree().process_frame
	enemies.append(enemy1)
	players.append(paladin)
	players.append(archer)
	players.append(assassin)

	while true:
		
		for player in players:
			await player.make_action()
			update_labels()
			await get_tree().create_timer(0.25).timeout
		
		for enemy in enemies:
			await enemy.make_action()
			update_labels()
			await get_tree().create_timer(0.5).timeout
		

func update_labels():
	archer_health.text = "Archer Health:" + str(archer.health)
	paladin_health.text = "Paladin Health:" + str(paladin.health)
	enemy_health.text   = "Enemy Health:"   + str(enemy1.health)
