#UpgradeData.gd
extends RefCounted
class_name UpgradeData

const SHOOTER_KEYS = ["bullet_speed", "damage"]
const THORNS_KEYS  = ["max_hp", "regen", "thorns"]
const NEUTRAL_KEYS = ["move_speed"]

const UPGRADE_KEYS: Array[String] = SHOOTER_KEYS + THORNS_KEYS + NEUTRAL_KEYS

# 这里的数字要和 PlayerStatus 里的常量保持一致
const MAX_REGEN_PER_SEC: float = 4.0
const MAX_MOVE_SPEED: float = 130.0
const MAX_THORNS: int = 4


func _is_key_effective(stats: PlayerStatus, key: String) -> bool:
	match key:
		"regen":
			return stats.hp_regen_per_sec < MAX_REGEN_PER_SEC
		"thorns":
			return stats.thorns < MAX_THORNS
		"move_speed":
			return stats.base_speed < MAX_MOVE_SPEED
		_:
			# 子弹速度、伤害、血量这些目前都没有上限，永远有效
			return true


func _effective_keys(stats: PlayerStatus, pool: Array) -> Array:
	var result: Array = []
	for k in pool:
		if _is_key_effective(stats, k):
			result.append(k)
	return result


func _random_effective_from_pool(stats: PlayerStatus, pool: Array, exclude: Array) -> String:
	var candidates: Array = []
	for k in pool:
		if not exclude.has(k) and _is_key_effective(stats, k):
			candidates.append(k)
	if candidates.is_empty():
		# 实在没货，只能退回“随便给一个”
		return _random_key_from_pool(pool, exclude)
	return candidates[randi() % candidates.size()]


func roll_options(stats: PlayerStatus) -> Array:
	var arch: String = stats.get_archetype()
	var count: int = stats.get_upgrade_count()

	# ---------- 第 1、2 次升级：强制一射击一反伤 ----------
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

	# ---------- 射击流：第 3 次一定给一次移速（但必须还有效） ----------
	if arch == "shooter" and count == 2 and stats.move_speed_upgrades == 0 and _is_key_effective(stats, "move_speed"):
		var other_key: String = _random_effective_from_pool(stats, UPGRADE_KEYS, ["move_speed"])
		return [build_opt("move_speed"), build_opt(other_key)]

	# ---------- 反伤流：第 3 次保证回血 / 反伤核心技能（前提是还没点过而且有效） ----------
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

	# ---------- 后期：根据强弱给当前流派 / 另一流派，并混入移速 + 过滤无效 ----------
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

	# 无论是什么流派，都把中立技能（比如移速）混进去
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


func _random_key_from_pool(pool: Array, exclude: Array) -> String:
	var candidates: Array = []
	for k in pool:
		if not exclude.has(k):
			candidates.append(k)
	if candidates.is_empty():
		return pool[randi() % pool.size()]
	return candidates[randi() % candidates.size()]


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
