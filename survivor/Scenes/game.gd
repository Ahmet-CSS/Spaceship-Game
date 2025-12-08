#game.gd
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
@onready var hud_hpxp      := $HPXP_UI
@onready var detail_status := $DetailStatus_UI

enum GameState { PLAYING, PAUSED, LEVELUP, GAME_OVER }
var state: GameState = GameState.PLAYING

var paused: bool = false
var player_stats: PlayerStatus = PlayerStatus.new()
# Game start timestamp
var start_ms: int = 0
var elapsed_time: float = 0.0

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
	
func _process(delta: float) -> void:
	if state == GameState.PLAYING:
		elapsed_time += delta
		if hud_hpxp and "set_time" in hud_hpxp:
			hud_hpxp.set_time(elapsed_time)

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
	
func _on_player_died() -> void:
	# Freeze time and show game-over menu
	state = GameState.GAME_OVER
	Engine.time_scale = 0.0
	if detail_status:
		detail_status.visible = false
	if game_over_menu:
		var m = game_over_menu.instantiate()
		add_child(m)

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
		
func resume() -> void:
	sfx("ui")
	Engine.time_scale = 1.0
	state = GameState.PLAYING
	paused = false
	
	if detail_status:
		detail_status.visible = false
