#bullet.gd
extends Area2D
## Bullet node used for the player's attacks.[br]
## Handles forward movement, optional homing toward a target,
## a fixed lifetime, and damage on impact with enemies.

## Bullet travel speed in pixels per second.
@export var speed: float = 700.0
## Lifetime of the bullet in seconds before it despawns.
@export var lifetime: float = 4.0
## If true, the bullet will steer toward its target each frame.
@export var homing: bool = true
## Maximum turn rate while homing, in degrees per second.
@export var turn_rate_deg: float = 720.0
## Distance under which the bullet is removed when close to the target.
@export var stop_distance: float = 12.0
## Damage dealt to a target that supports apply_damage().
@export var damage: int = 1

## Current movement direction of the bullet.
var direction: Vector2 = Vector2.RIGHT
## Current target the bullet is homing toward, if any.
var target: Node2D = null
## Accumulated lifetime in seconds.
var exist_time := 0.0


## Moves the bullet, applies homing behaviour, and tracks lifetime.[br]
## Destroys the bullet when it gets close to its target or when its
## lifetime expires.
func _physics_process(delta: float) -> void:
	# Turn gradually toward target if valid
	if homing and target and is_instance_valid(target):
		var desired := (target.global_position - global_position).normalized()
		var max_turn := deg_to_rad(turn_rate_deg) * delta
		var ang := direction.angle_to(desired)
		ang = clamp(ang, -max_turn, max_turn)
		direction = direction.rotated(ang).normalized()
		
		# If close enough to target, destroy bullet
		if global_position.distance_squared_to(target.global_position) <= stop_distance * stop_distance:
			queue_free()
	
	# Move the bullet forward
	global_position += direction * speed * delta
	
	# Self destruct after lifetime expires
	exist_time += delta
	if exist_time >= lifetime:
		queue_free()


## Connects the collision signal so the bullet can react to hits.
func _ready() -> void:
	# Listen for collision with other Area2D nodes
	area_entered.connect(_on_area_entered)


## Handles collision with another Area2D.[br]
## If the other area has apply_damage(), the bullet deals damage,
## plays a hit sound, and then destroys itself.
func _on_area_entered(area: Area2D) -> void:
	if area.has_method("apply_damage"):
		area.apply_damage(damage)
	get_tree().current_scene.sfx("hit")
	queue_free()
