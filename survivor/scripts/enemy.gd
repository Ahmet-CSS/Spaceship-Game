extends CharacterBody2D

signal enemy_killed

@onready var player = get_tree().get_first_node_in_group("player")
@export var speed := 150.0

var health := 3

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		emit_signal("enemy_killed")
		queue_free()

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	var width = get_viewport().get_visible_rect().size[0]
	var random_x = rng.randi_range(0, width)
	var random_y = rng.randi_range(-150, -50)
	position = Vector2(random_x, random_y)
	
	
func _process(delta: float) -> void:
	position += Vector2(0, 1.0) * 400 *delta
	
func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	#calculate direction to player
	var direction = (player.global_position - global_position).normalized()
	
	#rotate to face player
	$enemyImg.rotation = direction.x * deg_to_rad(10)
	
	#move toward player
	velocity = direction*speed
	move_and_slide()
	
func _on_body_entered(body: Node2D) -> void:
	print("body enterned") # Replace with function body.


func _on_enemy_killed() -> void:
	pass # Replace with function body.
