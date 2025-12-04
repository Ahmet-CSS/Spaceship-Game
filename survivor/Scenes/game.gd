extends Node

# Overlay scenes
@export var pause_menu: PackedScene
@export var game_over_menu: PackedScene
@export var levelup_menu: PackedScene

@onready var bgm           := $Audio/bgm
@onready var sfx_shoot     := $Audio/sfx_shoot
@onready var sfx_hit       := $Audio/sfx_hit
@onready var sfx_takedmg   := $Audio/sfx_takedamage
@onready var sfx_xp        := $Audio/sfx_xp
@onready var sfx_move      := $Audio/sfx_move
@onready var sfx_clickUI   := $Audio/sfx_clickUI
@onready var sfx_ui        := $Audio/sfx_UI


@onready var pause_button: Button = $PauseButton   # NEW

var paused: bool = false
var player_stats: PlayerStatus = PlayerStatus.new()
# Game start timestamp
var start_ms: int = 0


func _ready() -> void:
	randomize()
	$Audio/bgm.play()
	# Store start time
	start_ms = Time.get_ticks_msec()
	# Binding player stats and death handler
	$Player.stats = player_stats
	$Player.died.connect(_on_player_died)
	
	
	for u in get_tree().get_nodes_in_group("ui"):
		if "bind_stats" in u:
			u.bind_stats(player_stats)
	player_stats.level_up_ready.connect(_on_level_up_ready)
	pause_button.pressed.connect(_on_pause_button_pressed)  # NEW


func _show_pause_menu() -> void:                            # CHANGED
	if paused:                                              # NEW
		return                                               # NEW

	sfx("ui")                                               # NEW
	Engine.time_scale = 0.0                                 # NEW

	var pause_menu_inst = pause_menu.instantiate() as PauseMenu  # CHANGED

	add_child(pause_menu_inst)                              # NEW (moved earlier so @onready vars are valid)
	pause_menu_inst.resume.connect(resume)                  # NEW
	pause_menu_inst.bind_stats(player_stats)                # NEW

	paused = true                                           # NEW
	
	
func _on_pause_button_pressed() -> void:            # NEW
	_show_pause_menu()                               # NEW
	
func sfx(name: String) -> void:
	match name:
		"shoot":     $Audio/sfx_shoot.play()
		"hit":       $Audio/sfx_hit.play()
		"takedmg":   $Audio/sfx_takedamage.play()
		"xp":        $Audio/sfx_xp.play()
		"move":      $Audio/sfx_move.play()
		"click":     $Audio/sfx_clickUI.play()
		"ui":        $Audio/sfx_UI.play()
		
	
func _on_level_up_ready(options: Array) -> void:
	sfx("ui_open")
	print("[LVL-UP] received options: ", options)
	if levelup_menu == null: return
	var m = levelup_menu.instantiate()
	add_child(m)
	m.show_options(options)
	m.chosen.connect(func(key: String):
		player_stats.apply_upgrade(key)
		Engine.time_scale = 1.0
	)
	
func _on_player_died() -> void:
	# Freeze time and show game-over menu
	Engine.time_scale = 0.0
	if game_over_menu:
		var m = game_over_menu.instantiate()
		add_child(m)

func _input(event: InputEvent) -> void:
	if event.is_action_released("pause") and !paused:
		
		_show_pause_menu()                           # NEW
		sfx("ui")
		Engine.time_scale = 0.0 #This pauses time. Essentially this multiplies delta by 0 for everything every frame. By default it is 1. 
		var pause_menu_inst = pause_menu.instandwstiate() as PauseMenu #Makes an instance of the pause menu
		pause_menu_inst.resume.connect(resume)  #Connects to the pause menus unpause signal so the pause menu can let us know when it dies
		
		pause_menu_inst.bind_stats(player_stats) # new

		paused = true #Tracks that the game is paused so we can't repause the game
		self.add_child(pause_menu_inst) #Adds the pause menu to the scene tree
		
func resume() -> void:
	sfx("ui")
	Engine.time_scale = 1.0 #Starts time again
	paused = false #Tracks the game is unpaused
