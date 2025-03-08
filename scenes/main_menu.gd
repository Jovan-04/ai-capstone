extends Control

@onready var play_button: Button = $PlayButton/Button
@onready var quit_button: Button = $Quit/Button
@onready var check_box_assassin: CheckBox = $Selection/CheckBoxAssassin
@onready var check_box_paladin: CheckBox = $Selection/CheckBoxPaladin
@onready var check_box_wizard: CheckBox = $Selection/CheckBoxWizard
var played_by_real_player_assassin = false
var played_by_real_player_paladin = false
var played_by_real_player_wizard = false





const GAME = preload("res://scenes/game.tscn")

func _ready() -> void:
	play_button.button_down.connect(_on_play_button_pressed)
	quit_button.button_down.connect(_on_quit_button_pressed)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_check_box_assassin_toggled(toggled_on: bool) -> void:
	played_by_real_player_assassin = toggled_on
	print(played_by_real_player_assassin)


func _on_check_box_paladin_toggled(toggled_on: bool) -> void:
	played_by_real_player_paladin = toggled_on
	print(played_by_real_player_paladin)
	


func _on_check_box_wizard_toggled(toggled_on: bool) -> void:
	played_by_real_player_wizard = toggled_on
	print(played_by_real_player_wizard)
	
	
