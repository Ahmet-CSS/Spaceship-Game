extends CanvasLayer

@onready var body: Label = $"NinePatchRect/StatusTitle/Status"

var stats: PlayerStatus

func bind_stats(s: PlayerStatus) -> void:
	if stats and stats.stats_changed.is_connected(_refresh):
		stats.stats_changed.disconnect(_refresh)
	stats = s
	stats.stats_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	if stats == null:
		return
	var lines := []
	lines.append("Health: %d / %d" % [stats.hp, stats.max_hp])
	lines.append("XP: %d / %d" % [stats.xp_in_level(), stats.xp_to_next])
	lines.append("")
	lines.append("Max Health: %d" % stats.max_hp)
	lines.append("Bullet Speed Multiplier: %.1f" % stats.bullet_speed_mul)
	var game := get_tree().current_scene
	var base_dmg := 1
	if game and game.has_node("Player"):
		var p := game.get_node("Player")
		if "base_bullet_damage" in p:
			base_dmg = int(p.base_bullet_damage)
	lines.append("Damage: %d" % (base_dmg + stats.damage_plus))

	if game and game.has_node("Player"):
		var p := game.get_node("Player")
		if "base_speed" in p:
			var move_speed := float(p.base_speed) * stats.move_speed_mul
			lines.append("Movement Speed: %.1f" % move_speed)

	body.text = "\n".join(lines)
