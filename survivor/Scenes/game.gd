#game.gd
## Main gameplay scene controller.[br]
## Manages player stats, audio, HUD, level-up menus, victory and game-over state.
extends Node

## Packed scene for the pause menu overlay.
@export var pause_menu: PackedScene
## Packed scene for the game over menu overlay.
@export var game_over_menu: PackedScene
## Packed scene for the level-up choice menu.
@export var levelup_menu: PackedScene
## Packed scene for the victory menu overlay.
@export var victory_menu: PackedScene

## Background music audio player.
@onready var bgm           := $Audio/bgm
## Sound effect for player shots.
@onready var sfx_shoot     := $Audio/sfx_shoot
## Sound effect for hit impacts.
@onready var sfx_hit       := $Audio/sfx_hit
## Sound effect for the player taking damage.
@onready var sfx_takedmg   := $Audio/sfx_takedamage
## Sound effect for XP pickup.
@onready var sfx_xp        := $Audio/sfx_xp
## Looping movement sound for the player.
@onready var sfx_move      := $Audio/sfx_move
## Click sound used by UI buttons.
@onready var sfx_clickUI   := $Audio/sfx_clickUI
## Short UI feedback sound for menus.
@onready var sfx_ui        := $Audio/sfx_UI
## HUD bar that shows HP and XP.
@onready var hud_hpxp      := $HPXP_UI
## Optional detailed stats overlay.
@onready var detail_status := $DetailStatus_UI

## High-level game states the game can be in.
enum GameState { PLAYING, PAUSED, LEVELUP, GAME_OVER, VICTORY }
## Current game state.
var state: GameState = GameState.PLAYING

## Whether the pause menu is currently open.
var paused: bool = false
## Player stats object shared with UI and gameplay systems.
var player_stats: PlayerStatus = PlayerStatus.new()
## Timestamp of when the run started (in milliseconds).
var start_ms: int = 0
## Elapsed time since the run began (in seconds).
var elapsed_time: float = 0.0


## Initializes audio, player stats, HUD bindings and starts the run.
func _ready() -> void:
	randomize()
	elapsed_time = 0.0
	$Audio/bgm.play()
	# Store start time
	start_ms = Time.get_ticks_msec()
	
	if detail_status:
		detail_status.visible = false
	# Binding player stats and death handler
	$Player.stats = player_stats
	$Player.died.connect(_on_player_died)
	player_stats.init_from_player($Player)
	
	for u in get_tree().get_nodes_in_group("ui"):
		if "bind_stats" in u:
			u.bind_stats(player_stats)
	player_stats.level_up_ready.connect(_on_level_up_ready)
	
	#_show_victory_debug()

#func _show_victory_debug() -> void:
#	if victory_menu:
#		var m = victory_menu.instantiate()
#		add_child(m)
	

## Per-frame update while playing.[br]
## Tracks elapsed time, updates HUD, forwards time to the PlayerStatus
## and triggers victory after five minutes.
func _process(delta: float) -> void:
	if state == GameState.PLAYING:
		elapsed_time += delta
		if hud_hpxp and "set_time" in hud_hpxp:
			hud_hpxp.set_time(elapsed_time)
		if player_stats:
			player_stats.update(delta)
		if elapsed_time >= 300.0:
			_on_victory()


## Plays a sound effect based on the given kind string.
func sfx(kind: String) -> void:
	match kind:
		"shoot":
			$Audio/sfx_shoot.play()
		"hit":
			$Audio/sfx_hit.play()
		"takedmg":
			$Audio/sfx_takedamage.play()
		"xp":
			$Audio/sfx_xp.play()
		"move_on":
			$Audio/sfx_move.play()
		"move_off":
			$Audio/sfx_move.stop()
		"click":
			$Audio/sfx_clickUI.play()
		"ui":
			$Audio/sfx_UI.play()
		

## Handles a level-up event by pausing gameplay and showing upgrade options.
func _on_level_up_ready(options: Array) -> void:
	state = GameState.LEVELUP
	sfx("ui")
	print("[LVL-UP] received options: ", options)
	if levelup_menu == null: return
	var m = levelup_menu.instantiate()
	add_child(m)
	m.show_options(options)
	m.chosen.connect(func(key: String):
		player_stats.apply_upgrade(key)
		Engine.time_scale = 1.0
		state = GameState.PLAYING
	)
	

## Handles player death and shows the game-over menu once.
func _on_player_died() -> void:
	if state != GameState.PLAYING:
		return
	# Freeze time and show game-over menu
	state = GameState.GAME_OVER
	Engine.time_scale = 0.0
	if detail_status:
		detail_status.visible = false
	if game_over_menu:
		var m = game_over_menu.instantiate()
		add_child(m)
		

## Handles the victory condition when the run lasts long enough.
func _on_victory() -> void:
	state = GameState.VICTORY
	Engine.time_scale = 0.0
	if detail_status:
		detail_status.visible = false
	if victory_menu:
		var m = victory_menu.instantiate()
		add_child(m)


## Handles global input such as opening the pause menu.
func _input(event: InputEvent) -> void:
	if event.is_action_released("pause") and state == GameState.PLAYING and !paused:
		sfx("ui")
		Engine.time_scale = 0.0
		var pause_menu_inst = pause_menu.instantiate()
		pause_menu_inst.resume.connect(resume)
		paused = true
		state = GameState.PAUSED
		add_child(pause_menu_inst)
		
		if detail_status:
			detail_status.visible = true
		

## Resumes gameplay from the pause menu and hides the detail overlay.
func resume() -> void:
	sfx("ui")
	Engine.time_scale = 1.0
	state = GameState.PLAYING
	paused = false
	
	if detail_status:
		detail_status.visible = false
