#game_over_menu.gd
## Game over menu overlay.[br]
## Provides buttons to restart the run or return to the title screen,
## and plays a click sound when a button is pressed.
extends Control

## Connects button signals when the menu is created.
func _ready() -> void:
	$CenterContainer/VBoxContainer/RestartButton.pressed.connect(_on_restart)
	$CenterContainer/VBoxContainer/TitleButton.pressed.connect(_on_title)


## Creates a temporary audio player to play a UI click sound.
func _play_click() -> void:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = preload("res://Assets/audio/mixkit-clicking-on-UI-button-2037.mp3")
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)


## Handles the Restart button press.[br]
## Plays the click sound, unpauses the engine and reloads the game scene.
func _on_restart() -> void:
	_play_click()
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


## Handles the Title button press.[br]
## Plays the click sound, unpauses the engine and returns to the title screen.
func _on_title() -> void:
	_play_click()
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://Scenes/title_screen.tscn")
