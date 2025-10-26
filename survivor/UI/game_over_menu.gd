extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart)
	$CenterContainer/VBoxContainer/TitleButton.pressed.connect(_on_title)

func _on_restart() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_title() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
