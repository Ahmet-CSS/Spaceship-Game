extends Area2D

@export var speed := 600.0
var direction := Vector2.UP


func _process(delta: float) -> void:
	position += direction * speed *delta
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#body_entered.connect(_on_body_entered)
	#await get_tree().create_timer(2.0).timeout
	#queue_free()  
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta: float) -> void:
	#position += direction*speed*delta
	#
#func _on_body_entered(body):
	#if body.is_in_group("Enemy"):
		#if body.has_method("take_damage"):
			#body.take_damage(10)
	#queue_free()
