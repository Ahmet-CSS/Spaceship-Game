class_name Enemy
extends Area2D
## Enemy that chases and attacks the player.[br]
## Health scales with elapsed time, contact attacks damage the
## player, and late-game damage increases after a threshold.[br]
## On death, the enemy may drop an XP pickup.

## Movement speed in pixels per second.
@export var move_speed: float = 100
## Current visual tilt angle for a simple banking effect.
var tilt_angle := 0.0

# Base enemy health and health growth interval
## Base maximum health at the start of the game.
@export var base_health: int = 2
## Seconds between each step where enemy health increases by 1.
@export var health_interval_sec: int = 40
## Maximum health for this enemy instance.
var max_health: int = 1
## Current health value.
var health: int = 1

# XP drop settings
## Scene used to instantiate an XP pickup on death.
@export var xp_pickup_scene: PackedScene
## Probability that this enemy will drop XP when it dies.
@export var xp_drop_chance: float = 0.7
#@export var xp_min: int = 1
#@export var xp_max: int = 2

# attack settings
## Distance at which the enemy can start attacking the player.
@export var attack_range: float = 60.0
## Time in seconds between consecutive attacks.
@export var attack_interval: float = 0.5
## Base damage dealt by each attack before the late-game bonus.
@export var attack_damage: int = 3

## Time in seconds after which the enemy uses late-game damage.
@export var late_attack_time_sec: float = 240.0
## Damage per hit once the elapsed time passes late_attack_time_sec.
@export var late_attack_damage: int = 6

## Internal cooldown timer for the next attack.
var _attack_cd: float = 0.0
## Reference to the player being chased.
var _player: Player


## Initializes the enemy, finds the player, and scales health.[br]
## Health is increased based on how much time has passed since the
## game started, then the health bar is redrawn.
func _ready() -> void:
	add_to_group("Enemy")
	_player = get_tree().get_first_node_in_group("Player") as Player
	# Scale health by elapsed time
	var game := get_tree().current_scene
	var elapsed := 0.0
	if game and "start_ms" in game:
		elapsed = float(Time.get_ticks_msec() - game.start_ms) / 1000.0
	var steps := int(floor(elapsed / float(health_interval_sec)))
	max_health = base_health + steps
	health = max_health
	# refresh health bar drawing
	$HealthBar.queue_redraw()


## Updates movement, attack timing, and tilt each physics frame.[br]
## The enemy moves toward the player until it is in range, then
## uses a cooldown timer to deal contact damage and receive thorns
## damage back if the player has that stat.
func _physics_process(delta: float) -> void:
	# skip if player missing
	if _player == null or !is_instance_valid(_player):
		return
	
	# distance to player
	var dist := global_position.distance_to(_player.global_position)
	# Move toward player if out of range
	if dist > attack_range:
		position = position.move_toward(_player.position, delta * move_speed)
	else:
		# if in range check cooldown, deal damage when ready
		_attack_cd -= delta
		if _attack_cd <= 0.0:
			var dmg := attack_damage
			var game := get_tree().current_scene
			if game and "elapsed_time" in game and game.elapsed_time >= late_attack_time_sec:
				dmg = late_attack_damage
			_player.take_damage(dmg)

			if _player.stats and _player.stats.thorns > 0:
				apply_damage(_player.stats.thorns)

			_attack_cd = attack_interval
	
	# Tilt based on movement direction
	var tilt_target := 0.0
	if dist > attack_range:
		var dx := _player.global_position.x - global_position.x
		if dx > 0:
			tilt_target = 20
		elif dx < 0:
			tilt_target = -20
	tilt_angle = lerp(tilt_angle, tilt_target, 0.1)
	rotation_degrees = tilt_angle
	

## Reduces the enemy's health and checks for death.[br]
## When health reaches zero, the enemy triggers its death logic.
func apply_damage(amount: int = 1) -> void:
	health = max(0, health - amount)
	$HealthBar.queue_redraw()
	if health <= 0:
		die()


## Handles enemy death and optional XP drop.[br]
## Spawns an XP pickup with the configured probability, then
## removes this enemy from the scene tree.
func die() -> void:
	if xp_pickup_scene and randf() < xp_drop_chance:
		var xp := xp_pickup_scene.instantiate()
		xp.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", xp)
		if "value" in xp:
			xp.value = 1
	call_deferred("queue_free")
