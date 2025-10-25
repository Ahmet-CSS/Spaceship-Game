extends CharacterBody2D

@export var speed := 500

func _ready() -> void:
	position = Vector2(100, 500)
	
	
func _process(delta: float) -> void:
	var directon = Input.get_vector("move_left", "move_righ", "move_up", "move_down")
	velocity = directon*speed
	move_and_slide()
	
