extends Node2D

# load scene
var enemy_scene: PackedScene = load("res://scenes/enemy.tscn")
var laser_scene: PackedScene = load("res://scenes/laser.tscn")

func _on_timer_timeout() -> void:
	# create an instance
	var enemy = enemy_scene.instantiate()
	
	# attach the node to the scene tree
	$Enemies.add_child(enemy)
	

func _on_player_laser(pos: Vector2) -> void:
	var laser = laser_scene.instantiate()
	laser.position = pos
	
	#set direction to enemy
	if $Enemies.get_child_count() > 0:
		var enemy = $Enemies.get_child(0)
		laser.direction = (enemy.global_position - pos).normalized()
	else:
		laser.direction = Vector2.UP
	
	$Lasers.add_child(laser)
