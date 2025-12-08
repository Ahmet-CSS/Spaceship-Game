#PlayerStatus.gd
## Stores and manages the player's core stats and upgrades.[br]
## Handles XP, level progression, regeneration, archetype detection and upgrade effects.
extends Node
class_name PlayerStatus

## Emitted whenever any stat that the UI cares about changes.
signal stats_changed
## Emitted when a level-up occurs and upgrade options should be shown.
signal level_up_ready(options: Array)

## Total accumulated XP.
var xp: int = 0
## Maximum health points.
var max_hp: int = 80
## Current health points.
var hp: int = max_hp

## Base movement speed used before upgrades.
var base_speed: float = 100.0
## Base bullet damage before upgrade bonuses.
var base_bullet_damage: int = 1

## Total number of upgrades taken so far.
var upgrade_count: int = 0
## Current archetype string: "" until defined, then "shooter" or "thorns".
var archetype: String = ""
## Number of shooter-type upgrades picked.
var shooter_picks: int = 0
## Number of thorns-type upgrades picked.
var thorns_picks: int = 0
## Number of move-speed upgrades taken.
var move_speed_upgrades: int = 0
## Number of regeneration upgrades taken.
var regen_upgrades: int = 0
## Number of thorns upgrades taken.
var thorns_upgrades: int = 0

## Multiplier applied to bullet speed.
var bullet_speed_mul: float = 1.0
#var move_speed_mul: float = 1.0
## Flat bonus added on top of base bullet damage.
var damage_plus: int = 0
## Multiplier applied to fire rate (higher is faster).
var fire_rate_mul: float = 1.0
## Health regenerated per second.
var hp_regen_per_sec: float = 0.0
## Internal accumulator used to convert fractional regen into integer HP.
var _regen_accum: float = 0.0
## Thorns damage returned to enemies when the player is hit.
var thorns: int = 0

## Maximum allowed movement speed.
const MAX_MOVE_SPEED: float = 130.0
## Maximum allowed HP regeneration per second.
const MAX_REGEN_PER_SEC: float = 4.0
## Maximum allowed thorns value.
const MAX_THORNS: int = 4

## Base XP required for level 1.
@export var xp_base: int = 5
## Growth factor applied to XP requirements per level.
@export var xp_growth: float = 1.20
## XP required to reach the next level from the current state.
var xp_to_next: int = xp_base

## Script that contains upgrade roll logic.
const UpgradeDataScript = preload("res://Resources/UpgradeData.gd")
## Runtime instance used to generate upgrade options.
var upgrade_data = UpgradeDataScript.new()


## Returns the XP required to reach a given level.
func _xp_required_for(lvl: int) -> int:
	return int(round(xp_base * pow(xp_growth, float(lvl - 1))))


## Computes the current level from the total accumulated XP.
func level() -> int:
	var remain := xp
	var lvl := 1
	var need := _xp_required_for(lvl)
	while remain >= need:
		remain -= need
		lvl += 1
		need = _xp_required_for(lvl)
	return lvl


## Returns how much XP has been earned toward the current level.
func xp_in_level() -> int:
	var remain := xp
	var lvl := 1
	var need := _xp_required_for(lvl)
	while remain >= need:
		remain -= need
		lvl += 1
		need = _xp_required_for(lvl)
	return remain


## Recalculates and stores the XP needed for the next level based on current XP.
func cal_xp_needed() -> void:
	xp_to_next = _xp_required_for(level())


## Initializes XP requirement when the node is ready.
func _ready() -> void:
	cal_xp_needed()


## Rolls upgrade options using the UpgradeData helper and the current stats.
func _roll_options() -> Array:
	return upgrade_data.roll_options(self)


## Initializes stats using values from the Player node (speed, base damage). 
func init_from_player(p: Player) -> void:
	base_speed = p.base_speed
	base_bullet_damage = p.base_bullet_damage
	cal_xp_needed()
	emit_signal("stats_changed")


## Adds XP, checks for level-ups and emits level_up_ready with rolled options.
func add_xp(amount: int) -> void:
	var before := level()
	xp += amount
	var after := level()
	for i in range(after - before):
		emit_signal("level_up_ready", _roll_options())
	xp_to_next = _xp_required_for(after)
	emit_signal("stats_changed")


## Applies incoming damage, reducing HP and notifying listeners.
func take_damage(amount: int) -> void:
	hp = max(0, hp - amount)
	emit_signal("stats_changed")


## Applies health regeneration over time using an accumulator.[br]
## Emits stats_changed when HP actually increases.
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


## Returns the current archetype string.
func get_archetype() -> String:
	return archetype


## Returns the total number of upgrades taken so far.
func get_upgrade_count() -> int:
	return upgrade_count


## Compares current offense/defense score against an expected value for the level.[br]
## Used by the upgrade system to decide whether to offer opposite-tree upgrades.
func is_ahead_of_curve() -> bool:
	var offense: float = (base_bullet_damage + damage_plus) * fire_rate_mul
	var defense: float = float(max_hp) / 50.0 + hp_regen_per_sec + float(thorns)
	var score: float = offense + defense
	var expected: float = float(level()) * 3.0
	return score > expected


## Applies a chosen upgrade key to the player's stats and updates archetype.[br]
## Handles shooter, thorns and movement related upgrades with internal caps.
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
