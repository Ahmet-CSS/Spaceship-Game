extends CanvasLayer

@onready var health_bar = $Health
@onready var xp_bar = $XP

func update_health(value: float):
	health_bar.value = clamp(value, 0, health_bar.max)

func update_xp(value: float):
	xp_bar.value = clamp(value, 0, xp_bar.max)
