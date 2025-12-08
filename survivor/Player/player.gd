#player.gd
## Main player character controller.[br]
## Handles movement, auto-targeting, shooting, and forwarding damage/xp to PlayerStatus.
class_name Player # allows this script to be treated as type Player
extends CharacterBody2D	# indicates the type of Node this script is attached to

## Base movement speed in pixels per second.
@export var base_speed: float = 100.0	# A speed variable that determines how many pixels the object should move per second
# @export allows this variable to be configured in the inspector, instead of needing to hardcode value in script

# this method is called each time a step in the physics simulation is calculated
# the code is being written here because the velocity and move_and_slide are part of the CharacterBody2D node
## which is a physics node
## Current tilt angle used to visually lean the ship left/right.
var tilt_angle := 0.0

## Whether the player is currently moving (used to control movement SFX).
var _moving := false

# Fire settings
## Base attack interval in seconds between shots (before modifiers).
@export var fire_interval: float = 1.0       
## Maximum distance at which enemies can be targeted automatically.
@export var detection_radius: float = 400.0  
## Packed bullet scene used to instantiate projectiles.
@export var bullet_scene: PackedScene        
## Base bullet speed before multipliers.
@export var bullet_speed: float = 400.0
## Base bullet damage before PlayerStatus bonuses.
@export var base_bullet_damage: int = 1
## Internal cooldown timer tracking when the next shot can be fired.
var _fire_cooldown: float = 0.0

## Emitted when the player HP reaches zero.
signal died
## Reference to the PlayerStatus object that holds stats and upgrades.
var stats: PlayerStatus

## Optional UI node reference (currently unused).
@onready var ui: Node = null
## Local XP cache (not used now because XP goes directly to stats).
var xp := 0



## Adds the player to the "Player" group so other systems can find it.
func _ready() -> void:
	add_to_group("Player")


## Finds the nearest Enemy within the detection radius, or null if none.[br]
## Used to decide which enemy to target when shooting.
func _pick_target() -> Node2D:
	var best: Node2D = null
	var best_d2 := INF
	var r2 := detection_radius * detection_radius
	
	for e in get_tree().get_nodes_in_group("Enemy"):
		if not (e is Node2D):
			continue # ignore anything not a 2D node
			
		# Only consider enemies within the circle and closer than what found before
		var d2 := global_position.distance_squared_to(e.global_position)
		if d2 <= r2 and d2 < best_d2:
			best = e
			best_d2 = d2
	return best


## Returns a random unit vector.[br]
## Used as a fallback shooting direction when no target is found.
func _random_dir() -> Vector2:
	var a := randf() * TAU
	return Vector2(cos(a), sin(a))


## Spawns a bullet and configures its direction, speed, target and damage.[br]
## Plays the shoot sound through the current game scene.
func _shoot(dir: Vector2, target: Node2D=null) -> void:
	if bullet_scene == null: return
	var b := bullet_scene.instantiate() as Node2D
	b.global_position = global_position
	if "direction" in b: b.direction = dir
	if "speed" in b:
		var spd := bullet_speed
		if stats != null: spd *= stats.bullet_speed_mul
		b.speed = spd
	if "target" in b: b.target = target
	var dmg := base_bullet_damage
	if stats != null:
		dmg = stats.base_bullet_damage + stats.damage_plus
	if "damage" in b:
		b.damage = dmg
	get_tree().current_scene.add_child(b)
	get_tree().current_scene.sfx("shoot")


## Handles movement, firing logic and visual tilting each physics frame.
func _physics_process(_delta:float) -> void:
	# Movement
	var input_dir = Input.get_vector("left","right","up","down")
	var spd := base_speed
	if stats != null:
		spd = stats.base_speed
	velocity = input_dir * spd
	if input_dir.length() > 0.01:
		if !_moving:
			_moving = true
			get_tree().current_scene.sfx("move_on")
	else:
		if _moving:
			_moving = false
			get_tree().current_scene.sfx("move_off")
	move_and_slide()
	
	# Fire settings
	_fire_cooldown -= _delta
	if _fire_cooldown <= 0.0:
		var target := _pick_target()
		var dir: Vector2
		if target:
			dir = (target.global_position - global_position).normalized()
		else:
			dir = _random_dir()
		_shoot(dir, target)
		
		var interval := fire_interval
		if stats != null:
			interval = fire_interval / stats.fire_rate_mul
		_fire_cooldown = interval

		
	# Tilting
	var tilt_target := 0.0
	if input_dir.x > 0:
		tilt_target = 20
	elif input_dir.x < 0:
		tilt_target = -20
	tilt_angle = lerp(tilt_angle, tilt_target, 0.1) # smooth tilt
	rotation_degrees = tilt_angle # apply rotation
	

## Forwards damage to PlayerStatus and emits died when HP reaches zero.[br]
## Also plays the take-damage sound effect.
func take_damage(amount: int) -> void:
	if stats == null: return
	stats.take_damage(amount)
	get_tree().current_scene.sfx("takedmg")
	if stats.hp <= 0:
		emit_signal("died")


## Grants experience through PlayerStatus so it can trigger level-ups.
func gain_xp(amount: int) -> void:
	if stats == null: return
	stats.add_xp(amount)
