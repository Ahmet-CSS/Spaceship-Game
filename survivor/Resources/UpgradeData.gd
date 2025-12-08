#UpgradeData.gd
extends RefCounted
class_name UpgradeData

const UPGRADE_KEYS := ["bullet_speed", "damage", "move_speed", "max_hp"]

func roll_options() -> Array:
	var bag := UPGRADE_KEYS.duplicate()
	bag.shuffle()
	return [
		build_opt(bag[0]),
		build_opt(bag[1])
	]

func build_opt(key: String) -> Dictionary:
	match key:
		"bullet_speed":
			return {"key": key, "title": "Bullet Speed", "desc": "Increase bullet speed"}
		"damage":
			return {"key": key, "title": "Damage", "desc": "Increase bullet damage"}
		"move_speed":
			return {"key": key, "title": "Move Speed", "desc": "Increase movement speed"}
		"max_hp":
			return {"key": key, "title": "Max Health", "desc": "Increase maximum health"}
	return {"key": key, "title": key, "desc": ""}
