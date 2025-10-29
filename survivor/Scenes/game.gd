extends Node

# Overlay scenes
@export var pause_menu: PackedScene
@export var game_over_menu: PackedScene

var paused: bool = false
var player_stats: PlayerStatus = PlayerStatus.new()
# Game start timestamp
var start_ms: int = 0


func _ready() -> void:
	randomize()
	# Store start time
	start_ms = Time.get_ticks_msec()
	# Binding player stats and death handler
	$Player.stats = player_stats
	$Player.died.connect(_on_player_died)
	
	var ui = get_tree().get_first_node_in_group("ui")
	if ui and "bind_stats" in ui:
		ui.bind_stats(player_stats)
	
func _on_player_died() -> void:
	# Freeze time and show game-over menu
	Engine.time_scale = 0.0
	if game_over_menu:
		var m = game_over_menu.instantiate()
		add_child(m)

func _input(event: InputEvent) -> void:
	if event.is_action_released("pause") and !paused:
		Engine.time_scale = 0.0 #This pauses time. Essentially this multiplies delta by 0 for everything every frame. By default it is 1. 
		var pause_menu_inst = pause_menu.instantiate() #Makes an instance of the pause menu
		pause_menu_inst.resume.connect(resume)  #Connects to the pause menus unpause signal so the pause menu can let us know when it dies
		paused = true #Tracks that the game is paused so we can't repause the game
		self.add_child(pause_menu_inst) #Adds the pause menu to the scene tree
		
func resume() -> void:
	Engine.time_scale = 1.0 #Starts time again
	paused = false #Tracks the game is unpaused
