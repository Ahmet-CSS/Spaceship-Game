#UpgradeData.gd
## Helper for building and rolling upgrade options.[br]
## Encapsulates archetype rules, effectiveness checks and late-game bias.
extends RefCounted
class_name UpgradeData

## Keys for shooter-style offensive upgrades.
const SHOOTER_KEYS = ["bullet_speed", "damage"]
## Keys for thorns-style defensive / reflection upgrades.
const THORNS_KEYS  = ["max_hp", "regen", "thorns"]
## Keys for neutral upgrades usable by all archetypes.
const NEUTRAL_KEYS = ["move_speed"]

## Full list of all possible upgrade keys.
const UPGRADE_KEYS: Array[String] = SHOOTER_KEYS + THORNS_KEYS + NEUTRAL_KEYS

## Regeneration cap, must match PlayerStatus.MAX_REGEN_PER_SEC.
const MAX_REGEN_PER_SEC: float = 4.0
## Movement speed cap, must match PlayerStatus.MAX_MOVE_SPEED.
const MAX_MOVE_SPEED: float = 130.0
## Thorns cap, must match PlayerStatus.MAX_THORNS.
const MAX_THORNS: int = 4


## Returns true if the given upgrade key would still have an effect for these stats.
func _is_key_effective(stats: PlayerStatus, key: String) -> bool:
	match key:
		"regen":
			return stats.hp_regen_per_sec < MAX_REGEN_PER_SEC
		"thorns":
			return stats.thorns < MAX_THORNS
		"move_speed":
			return stats.base_speed < MAX_MOVE_SPEED
		_:
			# Bullet speed, damage and max HP currently have no cap.
			return true


## Filters a pool of keys to only include upgrades that still have an effect.
func _effective_keys(stats: PlayerStatus, pool: Array) -> Array:
	var result: Array = []
	for k in pool:
		if _is_key_effective(stats, k):
			result.append(k)
	return result


## Picks a random effective key from a pool, ignoring excluded keys.[br]
## Falls back to a generic random pick if nothing effective is available.
func _random_effective_from_pool(stats: PlayerStatus, pool: Array, exclude: Array) -> String:
	var candidates: Array = []
	for k in pool:
		if not exclude.has(k) and _is_key_effective(stats, k):
			candidates.append(k)
	if candidates.is_empty():
		return _random_key_from_pool(pool, exclude)
	return candidates[randi() % candidates.size()]


## Rolls two upgrade options based on the current archetype and progression.[br]
## Enforces early-game guarantees and late-game bias between branches.
func roll_options(stats: PlayerStatus) -> Array:
	var arch: String = stats.get_archetype()
	var count: int = stats.get_upgrade_count()

	# First two upgrades: guarantee one shooter and one thorns option.
	if arch == "" and count < 2:
		var shooter_pool = _effective_keys(stats, SHOOTER_KEYS)
		if shooter_pool.is_empty():
			shooter_pool = SHOOTER_KEYS

		var thorns_pool = _effective_keys(stats, THORNS_KEYS)
		if thorns_pool.is_empty():
			thorns_pool = THORNS_KEYS

		var k1: String = shooter_pool[randi() % shooter_pool.size()]
		var k2: String = thorns_pool[randi() % thorns_pool.size()]
		var opts: Array = [build_opt(k1), build_opt(k2)]
		if randi() % 2 == 0:
			opts.reverse()
		return opts

	# Shooter archetype: third upgrade guarantees a movement speed option if still useful.
	if arch == "shooter" and count == 2 and stats.move_speed_upgrades == 0 and _is_key_effective(stats, "move_speed"):
		var other_key: String = _random_effective_from_pool(stats, UPGRADE_KEYS, ["move_speed"])
		return [build_opt("move_speed"), build_opt(other_key)]

	# Thorns archetype: enforce regen/thorns core picks in early upgrades if missing.
	if arch == "thorns":
		var need_regen: bool = stats.regen_upgrades == 0 and _is_key_effective(stats, "regen")
		var need_thorns: bool = stats.thorns_upgrades == 0 and _is_key_effective(stats, "thorns")

		if count == 2 and need_regen and need_thorns:
			var pair: Array = [build_opt("regen"), build_opt("thorns")]
			if randi() % 2 == 0:
				pair.reverse()
			return pair

		if (count == 2 or count == 3):
			if need_regen and not need_thorns:
				var other: String = _random_effective_from_pool(stats, UPGRADE_KEYS, ["regen"])
				return [build_opt("regen"), build_opt(other)]
			if need_thorns and not need_regen:
				var other2: String = _random_effective_from_pool(stats, UPGRADE_KEYS, ["thorns"])
				return [build_opt("thorns"), build_opt(other2)]

	# Late game: bias toward own tree or opposite tree depending on power curve.
	var prefer_other: bool = stats.is_ahead_of_curve()

	var pool: Array = []
	if arch == "shooter":
		if prefer_other:
			pool = THORNS_KEYS.duplicate()
		else:
			pool = SHOOTER_KEYS.duplicate()
	elif arch == "thorns":
		if prefer_other:
			pool = SHOOTER_KEYS.duplicate()
		else:
			pool = THORNS_KEYS.duplicate()
	else:
		pool = UPGRADE_KEYS.duplicate()

	# Always mix in neutral upgrades (e.g., move_speed).
	for k in NEUTRAL_KEYS:
		if not pool.has(k):
			pool.append(k)

	var eff_pool: Array = _effective_keys(stats, pool)
	if eff_pool.is_empty():
		eff_pool = pool

	eff_pool.shuffle()
	if eff_pool.size() == 1:
		return [build_opt(eff_pool[0]), build_opt(eff_pool[0])]
	return [build_opt(eff_pool[0]), build_opt(eff_pool[1])]


## Picks a random key from the pool while ignoring the excluded ones.[br]
## Used as a low-level helper when no effectiveness filter is applied.
func _random_key_from_pool(pool: Array, exclude: Array) -> String:
	var candidates: Array = []
	for k in pool:
		if not exclude.has(k):
			candidates.append(k)
	if candidates.is_empty():
		return pool[randi() % pool.size()]
	return candidates[randi() % candidates.size()]


## Builds a display dictionary for a given upgrade key.[br]
## Each dictionary includes the internal key, a title and a description.
func build_opt(key: String) -> Dictionary:
	match key:
		"bullet_speed":
			return {"key": key, "title": "Bullet Speed", "desc": "Increase bullet speed and fire rate"}
		"damage":
			return {"key": key, "title": "Damage", "desc": "Increase bullet damage"}
		"move_speed":
			return {"key": key, "title": "Move Speed", "desc": "Increase movement speed"}
		"max_hp":
			return {"key": key, "title": "Max Health", "desc": "Increase maximum health"}
		"regen":
			return {"key": key, "title": "HP Regeneration", "desc": "Regenerate health over time"}
		"thorns":
			return {"key": key, "title": "Thorns", "desc": "Deal damage back when hit"}
	return {"key": key, "title": key, "desc": ""}
