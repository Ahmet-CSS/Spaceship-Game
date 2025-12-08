#enemy.gd
class_name Enemy

extends Area2D

@export var move_speed: float = 50
var tilt_angle := 0.0

# Base enemy health and health growth interval
@export var base_health: int = 1
@export var health_interval_sec: int = 30
var max_health: int = 1
var health: int = 1

# XP drop settings
@export var xp_pickup_scene: PackedScene
@export var xp_drop_chance: float = 0.6
#@export var xp_min: int = 1
#@export var xp_max: int = 2

# attack settings
@export var attack_range: float = 60.0       
@export var attack_interval: float = 0.5     
@export var attack_damage: int = 5           
var _attack_cd: float = 0.0
var _player: Player

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
			_player.take_damage(attack_damage)
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
	

func apply_damage(amount: int = 1) -> void:
	health = max(0, health - amount)
	$HealthBar.queue_redraw()                         
	if health <= 0:
		die()

# Drop XP on death
func die() -> void:
	if xp_pickup_scene and randf() < xp_drop_chance:
		var xp := xp_pickup_scene.instantiate()
		xp.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", xp)
		if "value" in xp:
			xp.value = 1
	call_deferred("queue_free")
