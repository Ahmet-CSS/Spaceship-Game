extends Control

var game_scene: PackedScene = load("res://Scenes/game.tscn")

@onready var click: AudioStreamPlayer = $"Audio/sfx_clickUI"
@onready var bgm:   AudioStreamPlayer = $"Audio/bgm"

func _ready() -> void:
	bgm.play()
	
func _play_click_global() -> void:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = preload("res://Assets/audio/mixkit-clicking-on-UI-button-2037.mp3")
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func start_game() -> void: #Switches to the game scene
	_play_click_global()
	get_tree().change_scene_to_packed(game_scene)
