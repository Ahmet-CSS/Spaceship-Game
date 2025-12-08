#laser.gd
## Simple homing laser projectile.[br]
## Scales in with a short tween when spawned, then moves in a fixed direction.
extends Area2D

## Travel speed of the laser in pixels per second.
@export var speed := 600.0
## Direction the laser moves in each frame.
var direction := Vector2.UP


## Initializes the spawn animation by tweening the sprite scale from 0 to 1.
func _ready() -> void:
	$Sprite2D.scale = Vector2(0, 0)
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(1, 1), 0.2)


## Moves the laser forward every frame according to its direction and speed.
func _process(delta: float) -> void:
	position += direction * speed * delta
