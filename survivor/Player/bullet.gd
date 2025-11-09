extends Area2D

# Bullet travel speed
@export var speed: float = 700.0
@export var lifetime: float = 4.0
@export var homing: bool = true
@export var turn_rate_deg: float = 720.0
# Destroy range when close to target
@export var stop_distance: float = 12.0
@export var damage: int = 1

# Movement direction
var direction: Vector2 = Vector2.RIGHT
# Current target
var target: Node2D = null
# Time lived so far
var exist_time := 0.0

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
		
		
func _ready() -> void:
	# Listen for collision with other Area2D nodes
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("apply_damage"):
		area.apply_damage(damage)
	get_tree().current_scene.sfx("hit")
	queue_free()
		
