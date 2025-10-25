extends CharacterBody2D

@export var speed := 500
var can_shoot: bool = true

signal laser 

func _ready() -> void:
	position = Vector2(100, 500)
	
	
func _process(delta: float) -> void:
	var directon = Input.get_vector("move_left", "move_righ", "move_up", "move_down")
	velocity = directon*speed
	move_and_slide()
	
	if Input.is_action_just_pressed("shoot") and can_shoot:
		laser.emit($LaserStartPos.global_position)
		can_shoot = false
		$LaserTimer.start()
	



func _on_timer_timeout() -> void:
	can_shoot = true
