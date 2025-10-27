class_name XPPickup
extends Area2D

@export var value: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(b: Node) -> void:
	# only player can collect and only if it has stats
	if b is Player and b.stats:
		b.stats.add_xp(value)
		# remove xp after collection
		queue_free()
