#game_over_menu.gd
extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart)
	$CenterContainer/VBoxContainer/TitleButton.pressed.connect(_on_title)

func _play_click() -> void:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = preload("res://Assets/audio/mixkit-clicking-on-UI-button-2037.mp3")
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _on_restart() -> void:
	_play_click()
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_title() -> void:
	_play_click()
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
