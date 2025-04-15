extends Control

@onready var play_button: Button = $PlayButton/Button
@onready var quit_button: Button = $Quit/Button
@onready var check_box_assassin: CheckBox = $Selection/CheckBoxAssassin
@onready var check_box_paladin: CheckBox = $Selection/CheckBoxPaladin
@onready var check_box_wizard: CheckBox = $Selection/CheckBoxWizard
var played_by_real_player_assassin = true
var played_by_real_player_paladin = true
var played_by_real_player_wizard = true


var collision_tiles = []

func generate_terrain():
	while len(collision_tiles) < 5:
		var x = randi_range(0,17) - 9
		var y = randi_range(0,11) - 6
		collision_tiles.append(Vector2i(x,y))
	var temp_tiles = [Vector2i(9,1),Vector2i(9,2),Vector2i(9,3),Vector2i(9,4),Vector2i(9,5),Vector2i(9,6),Vector2i(8,6),Vector2i(7,6),Vector2i(6,6),Vector2i(5,6),]
	for tile in temp_tiles:
		collision_tiles.append(tile - Vector2i(9,6))
		
		
	



const GAME = "res://scenes/game.tscn"

func _ready() -> void:
	play_button.button_down.connect(_on_play_button_pressed)
	quit_button.button_down.connect(_on_quit_button_pressed)

func _on_play_button_pressed() -> void:
	var current_game = load(GAME).instantiate()
	get_tree().root.add_child(current_game)
	
	current_game.assassin.played_by_real_player = played_by_real_player_assassin
	current_game.paladin.played_by_real_player  = played_by_real_player_paladin
	current_game.wizard.played_by_real_player   = played_by_real_player_wizard
	generate_terrain()
	current_game.collision_tiles                = collision_tiles
	
	await get_tree().create_timer(1.0).timeout
	get_tree().current_scene.queue_free()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_check_box_assassin_toggled(toggled_on: bool) -> void:
	played_by_real_player_assassin = !toggled_on
	#print(played_by_real_player_assassin)


func _on_check_box_paladin_toggled(toggled_on: bool) -> void:
	played_by_real_player_paladin = !toggled_on
	print(played_by_real_player_paladin)
	


func _on_check_box_wizard_toggled(toggled_on: bool) -> void:
	played_by_real_player_wizard = !toggled_on
	#print(played_by_real_player_wizard)
	
	
