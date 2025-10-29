extends Node2D

@export var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
@export var spawn_position := Vector2(400, 300)

func _ready() -> void:
	spawn_enemy()
	
func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.position = spawn_position
	add_child(enemy)
	
	enemy.connect("enemy_killed", Callable(self, "_on_enemy_killed"))
	
func _on_enemy_killed():
	spawn_enemy()
