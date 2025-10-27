extends Control

var game_scene: PackedScene = load("res://Scenes/game.tscn")

func start_game() -> void: #Switches to the game scene
	get_tree().change_scene_to_packed(game_scene)
