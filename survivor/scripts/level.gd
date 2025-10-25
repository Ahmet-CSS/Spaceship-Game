extends Node2D

# load scene
var enemy_scene: PackedScene = load("res://scenes/enemy.tscn")
func _on_timer_timeout() -> void:
	# create an instance
	var enemy = enemy_scene.instantiate()
	
	# attach the node to the scene tree
	$Enemies.add_child(enemy)
	
	


func _on_player_laser() -> void:
	pass # Replace with function body.
