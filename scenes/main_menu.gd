extends Control

@onready var play_button: Button = $PlayButton/Button
@onready var quit_button: Button = $Quit/Button
const GAME = preload("res://scenes/game.tscn")

func _ready() -> void:
	play_button.button_down.connect(_on_play_button_pressed)
	quit_button.button_down.connect(_on_quit_button_pressed)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
