#XPPickup.gd
## XP pickup orb that grants experience when collected by the player.[br]
## Plays a sound effect and then destroys itself on collection.
class_name XPPickup
extends Area2D

## Amount of XP granted when this pickup is collected.
@export var value: int = 1


## Connects the body_entered signal so we can detect the player.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


## Handles collision with a body and awards XP if it is the player with stats.[br]
## Also plays the XP sound effect and removes the pickup.
func _on_body_entered(b: Node) -> void:
	# only player can collect and only if it has stats
	if b is Player and b.stats:
		print("[XP] pickup hit player, +", value)
		b.stats.add_xp(value)
		# remove xp after collection
		get_tree().current_scene.sfx("xp")
		queue_free()
