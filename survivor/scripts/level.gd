#level.gd
## Simple test level used for the original enemy and laser prototype.[br]
## Spawns enemies on a timer and fires a laser from the player toward an enemy.
extends Node2D

## Packed scene used to instantiate new enemies.
var enemy_scene: PackedScene = load("res://scenes/enemy.tscn")
## Packed scene used to instantiate new lasers.
var laser_scene: PackedScene = load("res://scenes/laser.tscn")


## Timer callback that spawns a new enemy under the Enemies node.
func _on_timer_timeout() -> void:
	# create an instance
	var enemy = enemy_scene.instantiate()
	
	# attach the node to the scene tree
	$Enemies.add_child(enemy)
	

## Spawns a laser at the given position and aims it at the first enemy if present.
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
