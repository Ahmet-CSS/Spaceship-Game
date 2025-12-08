#enemy_spawner.gd
## Spawns enemies around the player over time.[br]
## Keeps track of all live enemies and increases the maximum
## enemy count as the game progresses.
extends CollisionShape2D

## Cached reference to the player used for positioning the spawn ring.
var _player: Node2D = null

## Group name used to find the player node.
const GROUP_PLAYER := "Player"
## Group name assigned to enemies created by this spawner.
const GROUP_ENEMY  := "Enemy"

## Live enemies currently tracked by this spawner.
var enemies: Array[Node2D] = []

## Timer node that controls the spawn heartbeat.
## It is expected to be a child named "SpawnTime".
@onready var timer: Timer = $"SpawnTime" 

## Time between enemy spawn attempts in seconds.
@export var spawn_time: float = 2.0
## Initial maximum number of enemies allowed at the start.
@export var initial_cap: int = 3
## Interval in seconds after which the capacity is increased.
@export var growth_interval_sec: float = 10
## Amount by which the capacity increases every growth step.
@export var growth_per_step: int = 1
## Inner radius of the spawn ring around the player.
@export var ring_inner_radius: float = 300.0
## Outer radius of the spawn ring around the player.
@export var ring_outer_radius: float = 500.0
## Timestamp (in milliseconds) when the spawner started.
var _start_ms: int
						 
## Packed enemy scene used to instantiate new enemies.
var enemy_scene: PackedScene = preload("res://Enemy/Enemy.tscn")
## Node under which newly spawned enemies are parented.
@export var enemy_container: Node


## Initializes the spawner state, connects the timer and starts spawning.
func _ready() -> void:
	# Reset internal enemy list
	enemies.clear()
	
	# Mark start time for capacity growth
	var game := get_tree().current_scene
	if game != null and "start_ms" in game:
		_start_ms = game.start_ms
	else:
		_start_ms = Time.get_ticks_msec()
	
	_player = get_tree().get_first_node_in_group(GROUP_PLAYER) as Player
	
	# Prepare spawn timer
	timer.stop()
	timer.autostart = false
	timer.one_shot = false
	timer.wait_time = spawn_time
	
	# Ensure timer connects to spawn handler only once
	if timer.timeout.is_connected(spawn_enemy):
		timer.timeout.disconnect(spawn_enemy)
	timer.timeout.connect(spawn_enemy)

	#print("spawn_time export =", spawn_time, " wait_time before start =", timer.wait_time)
	timer.start(spawn_time)
	

## Returns the current maximum number of enemies based on elapsed time.
func current_cap() -> int:
	# Calculate current capacity based on time and growth settings
	var t := (Time.get_ticks_msec() - _start_ms) / 1000.0
	var steps := int(floor(t / growth_interval_sec))
	return initial_cap + steps * growth_per_step
	

## Picks a random point in the spawn ring around the player.
## If the player is missing, the spawner's own position is used.
func random_position_in_ring() -> Vector2:
	# Picks a random point in the ring around the player, falls back to spawner position if player is missing
	if _player == null:
		return self.global_position
	var ang := randf() * TAU
	var r   := randf_range(ring_inner_radius, ring_outer_radius)
	return _player.global_position + Vector2(cos(ang), sin(ang)) * r


## Called when a tracked enemy leaves the scene tree.[br]
## Removes the enemy from the internal list.
func _on_enemy_tree_exited(e: Node) -> void:
	enemies.erase(e)


## Attempts to spawn a new enemy instance if under capacity.[br]
## The new enemy is tracked and placed at a random position in the ring.
func spawn_enemy() -> void:
	# If under capacity, spawn enemy
	if enemies.size() >= current_cap():
		#print("spawn time", Time.get_ticks_msec() / 1000.0, "s  count=", enemies.size(), "/", current_cap())
		return
	
	# create the enemy
	var enemy_instance := enemy_scene.instantiate() as Node2D
	
	# track it and remove when despawns
	enemies.append(enemy_instance)
	enemy_instance.tree_exited.connect(_on_enemy_tree_exited.bind(enemy_instance))
	
	# place under container and position in the ring
	enemy_container.add_child(enemy_instance)
	enemy_instance.global_position = random_position_in_ring()
	
	#print("spawn time", Time.get_ticks_msec()/1000.0, "s  count=", enemies.size(), "/", current_cap())
