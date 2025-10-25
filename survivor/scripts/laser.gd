extends Area2D

@export var speed := 600.0
var direction := Vector2.UP

func _ready() -> void:
	$Sprite2D.scale = Vector2(0, 0)
	var tween = create_tween()
	tween.tween_property($Sprite2D, 'scale', Vector2(1, 1), 0.2)

func _process(delta: float) -> void:
	position += direction * speed *delta
