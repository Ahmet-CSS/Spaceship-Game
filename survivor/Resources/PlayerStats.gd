class_name PlayerStatus
extends Node

signal stats_changed
var xp: int = 0
var max_hp: int = 100
var hp: int = max_hp

func level() -> int:
	return 1 + int(xp / 5.0)
	
func xp_in_level() -> int:
	return xp % 5

func add_xp(amount: int) -> void:
	xp += amount
	#print("[XP] now =", xp)
	emit_signal("stats_changed")

func take_damage(amount: int) -> void:
	hp = max(0, hp - amount)
	#print("[HP] now =", hp)
	emit_signal("stats_changed")
