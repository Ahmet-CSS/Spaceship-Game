extends CanvasLayer
## Overlay UI that displays detailed player statistics.[br]
## Binds to a PlayerStatus and refreshes the text whenever the
## stats change.

## Label used to show the multi-line status text.
@onready var body: Label = $"NinePatchRect/StatusTitle/Status"

## Reference to the currently bound PlayerStatus object.
var stats: PlayerStatus


## Binds this UI to the given PlayerStatus instance.[br]
## Disconnects from any previous stats object, connects to the new
## stats_changed signal, and forces an immediate refresh.
func bind_stats(s: PlayerStatus) -> void:
	if stats and stats.stats_changed.is_connected(_refresh):
		stats.stats_changed.disconnect(_refresh)
	stats = s
	stats.stats_changed.connect(_refresh)
	_refresh()


## Rebuilds the status text from the current PlayerStatus values.[br]
## If no stats object is bound, the function returns without changes.
func _refresh() -> void:
	if stats == null:
		return
	var lines := []
	lines.append("Health: %d / %d" % [stats.hp, stats.max_hp])
	lines.append("XP: %d / %d" % [stats.xp_in_level(), stats.xp_to_next])
	lines.append("")
	lines.append("Max Health: %d" % stats.max_hp)
	lines.append("Bullet Speed Multiplier: %.1f" % stats.bullet_speed_mul)
	lines.append("Damage: %d" % (stats.base_bullet_damage + stats.damage_plus))

	var move_speed: float = stats.base_speed
	lines.append("Movement Speed: %.1f" % move_speed)
	
	lines.append("Fire Rate Multiplier: %.2f" % stats.fire_rate_mul)
	lines.append("HP Regen: %.1f / s" % stats.hp_regen_per_sec)
	lines.append("Thorns: %d" % stats.thorns)
	
	body.text = "\n".join(lines)
