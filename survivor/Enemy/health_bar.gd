#health_baar.gd
## Simple health bar node drawn above an enemy.[br]
## Reads the parent Enemy's current and maximum health and
## renders a colored bar representing the remaining health.
extends Node2D

## Draws the health bar each frame using the parent's health values.
func _draw() -> void:
	var enemy := get_parent() as Enemy
	if enemy == null or enemy.max_health <= 0:
		return
	var w := 52.0
	var h := 6.0
	var y_off := -24.0
	var bg := Color(0,0,0,0.6)
	var fg := Color(0.2,0.9,0.2,0.9)
	var pct := float(enemy.health) / float(enemy.max_health)
	draw_rect(Rect2(Vector2(-w*0.5, y_off), Vector2(w, h)), bg, true)
	draw_rect(Rect2(Vector2(-w*0.5, y_off), Vector2(w * pct, h)), fg, true)
