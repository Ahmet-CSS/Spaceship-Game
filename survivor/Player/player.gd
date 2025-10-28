class_name Player # allows this script to be treated as type Player

extends CharacterBody2D	# indicates the type of Node this script is attached to

@export var speed = 220	# A speed variable that determines how many pixels the object should move per second
# @export allows this variable to be configured in the inspector, instead of needing to hardcode value in script

# this method is called each time a step in the physics simulation is calculated
# the code is being written here because the velocity and move_and_slide are part of the CharacterBody2D node
## which is a physics node
var tilt_angle := 0.0



# Fire settings
@export var fire_interval: float = 1.0       
@export var detection_radius: float = 400.0  
@export var bullet_scene: PackedScene        
@export var bullet_speed: float = 400.0
var _fire_cooldown: float = 0.0

signal died
var stats: PlayerStatus

@onready var ui = get_tree().get_first_node_in_group("ui")
var xp := 0


func _ready() -> void:
	add_to_group("Player")
	ui.update_health(80)
	ui.update_xp(25)

# Find nearest Enemy within detection radius
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

# Returns a random unit vector, used when no target
func _random_dir() -> Vector2:
	var a := randf() * TAU
	return Vector2(cos(a), sin(a))


func _shoot(dir: Vector2, target: Node2D = null) -> void:
	# create a new bullet instance
	if bullet_scene == null:
		return
	var b := bullet_scene.instantiate() as Node2D
	
	# spawn at player position
	b.global_position = global_position
	
	# set bullet movement data
	if "direction" in b:
		b.direction = dir
	if "velocity" in b:
		b.velocity = dir * bullet_speed
	if "speed" in b:
		b.speed = bullet_speed
	if "target" in b:
		b.target = target
		
	# add bullet to scene
	get_tree().current_scene.add_child(b)


func _physics_process(_delta:float) -> void:
	# Movement
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
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
		_fire_cooldown = fire_interval
		
	# Tilting
	var tilt_target := 0.0
	if input_direction.x > 0:
		tilt_target = 20
	elif input_direction.x < 0:
		tilt_target = -20
	tilt_angle = lerp(tilt_angle, tilt_target, 0.1) # smooth tilt
	rotation_degrees = tilt_angle # apply rotation
	
# forward damage to stats, die when no HP
func take_damage(amount: int) -> void:
	if stats == null:
		return
	stats.take_damage(amount)
	ui.update_health(stats.hp)
	if stats.hp <= 0:
		emit_signal("died")
		


func gain_xp(amount: int) -> void:
	xp += amount
	ui.update_xp(xp)
