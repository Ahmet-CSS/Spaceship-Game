#PlayerStatus.gd
extends Node
class_name PlayerStatus

signal stats_changed
signal level_up_ready(options: Array)

var xp: int = 0
var max_hp: int = 100
var hp: int = max_hp

var base_speed: float = 220.0
var base_bullet_damage: int = 1

var bullet_speed_mul: float = 1.0
var move_speed_mul: float = 1.0
var damage_plus: int = 0

@export var xp_base: int = 5
@export var xp_growth: float = 1.25
var xp_to_next: int = xp_base

const UpgradeDataScript := preload("res://Resources/UpgradeData.gd")
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
	return upgrade_data.roll_options()

func init_from_player(p: Player) -> void:
	base_speed = p.base_speed
	base_bullet_damage = p.base_bullet_damage
	cal_xp_needed()
	emit_signal("stats_changed")

func add_xp(amount: int) -> void:
	print("[XP] add_xp called, amount=", amount, "  curr_xp=", xp)
	var before := level()
	xp += amount
	var after := level()
	for i in range(after - before):
		print("[LVL-UP] emit level_up_ready")
		emit_signal("level_up_ready", _roll_options())
	xp_to_next = _xp_required_for(after)
	emit_signal("stats_changed")

func take_damage(amount: int) -> void:
	hp = max(0, hp - amount)
	#print("[HP] now =", hp)
	emit_signal("stats_changed")
	
func apply_upgrade(key: String) -> void:
	match key:
		"bullet_speed":
			bullet_speed_mul *= 1.15
		"damage":
			damage_plus += 1
		"move_speed":
			move_speed_mul *= 1.10
		"max_hp":
			max_hp += 10
			hp = min(hp + 10, max_hp)
	emit_signal("stats_changed")
