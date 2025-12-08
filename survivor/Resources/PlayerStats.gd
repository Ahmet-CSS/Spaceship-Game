#PlayerStatus.gd
extends Node
class_name PlayerStatus

signal stats_changed
signal level_up_ready(options: Array)

var xp: int = 0
var max_hp: int = 80
var hp: int = max_hp

var base_speed: float = 100.0
var base_bullet_damage: int = 1

var upgrade_count: int = 0
var archetype: String = ""
var shooter_picks: int = 0
var thorns_picks: int = 0
var move_speed_upgrades: int = 0
var regen_upgrades: int = 0
var thorns_upgrades: int = 0

var bullet_speed_mul: float = 1.0
#var move_speed_mul: float = 1.0
var damage_plus: int = 0
var fire_rate_mul: float = 1.0
var hp_regen_per_sec: float = 0.0
var _regen_accum: float = 0.0
var thorns: int = 0

const MAX_MOVE_SPEED: float = 130.0
const MAX_REGEN_PER_SEC: float = 4.0
const MAX_THORNS: int = 4

@export var xp_base: int = 5
@export var xp_growth: float = 1.20
var xp_to_next: int = xp_base

const UpgradeDataScript = preload("res://Resources/UpgradeData.gd")
var upgrade_data = UpgradeDataScript.new()

func _xp_required_for(lvl: int) -> int:
	return int(round(xp_base * pow(xp_growth, float(lvl - 1))))

func level() -> int:
	var remain := xp
	var lvl := 1
	var need := _xp_required_for(lvl)
	while remain >= need:
		remain -= need
		lvl += 1
		need = _xp_required_for(lvl)
	return lvl

func xp_in_level() -> int:
	var remain := xp
	var lvl := 1
	var need := _xp_required_for(lvl)
	while remain >= need:
		remain -= need
		lvl += 1
		need = _xp_required_for(lvl)
	return remain

func cal_xp_needed() -> void:
	xp_to_next = _xp_required_for(level())

func _ready() -> void:
	cal_xp_needed()

func _roll_options() -> Array:
	return upgrade_data.roll_options(self)

func init_from_player(p: Player) -> void:
	base_speed = p.base_speed
	base_bullet_damage = p.base_bullet_damage
	cal_xp_needed()
	emit_signal("stats_changed")

func add_xp(amount: int) -> void:
	var before := level()
	xp += amount
	var after := level()
	for i in range(after - before):
		emit_signal("level_up_ready", _roll_options())
	xp_to_next = _xp_required_for(after)
	emit_signal("stats_changed")

func take_damage(amount: int) -> void:
	hp = max(0, hp - amount)
	emit_signal("stats_changed")

func update(delta: float) -> void:
	if hp_regen_per_sec <= 0.0:
		return
	if hp >= max_hp:
		return

	_regen_accum += hp_regen_per_sec * delta
	if _regen_accum >= 1.0:
		var gain: int = int(_regen_accum)
		_regen_accum -= gain
		var new_hp: int = min(max_hp, hp + gain)
		if new_hp != hp:
			hp = new_hp
			emit_signal("stats_changed")

func get_archetype() -> String:
	return archetype

func get_upgrade_count() -> int:
	return upgrade_count

func is_ahead_of_curve() -> bool:
	var offense: float = (base_bullet_damage + damage_plus) * fire_rate_mul
	var defense: float = float(max_hp) / 50.0 + hp_regen_per_sec + float(thorns)
	var score: float = offense + defense
	var expected: float = float(level()) * 3.0
	return score > expected

func apply_upgrade(key: String) -> void:
	match key:
		"bullet_speed":
			bullet_speed_mul *= 1.2
			fire_rate_mul *= 1.3
			shooter_picks += 1

		"damage":
			damage_plus += 1
			shooter_picks += 1

		"max_hp":
			max_hp += 20
			hp = min(hp + 20, max_hp)
			thorns_picks += 1

		"regen":
			hp_regen_per_sec = min(MAX_REGEN_PER_SEC, hp_regen_per_sec + 1.0)
			thorns_picks += 1
			regen_upgrades += 1

		"thorns":
			if thorns < MAX_THORNS:
				if thorns_upgrades == 0:
					thorns += 2
				else:
					thorns = min(MAX_THORNS, thorns + 1)
			thorns_picks += 1
			thorns_upgrades += 1


		"move_speed":
			base_speed = min(MAX_MOVE_SPEED, base_speed + 10.0)
			move_speed_upgrades += 1

	if archetype == "":
		if shooter_picks >= 2:
			archetype = "shooter"
		elif thorns_picks >= 2:
			archetype = "thorns"

	upgrade_count += 1
	emit_signal("stats_changed")
