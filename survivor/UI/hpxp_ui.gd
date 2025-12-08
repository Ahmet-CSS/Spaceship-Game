#hpxp_ui.gd
## Heads-up display that shows the player's HP, XP, level and elapsed time.[br]
## Binds to a PlayerStatus instance and updates UI controls whenever stats change.
extends CanvasLayer

## ProgressBar that shows the current health.
@onready var health_bar = $Health
## ProgressBar that shows XP progress toward the next level.
@onready var xp_bar     = $XP
## Label displaying the current player level.
@onready var level_label: Label = $Frame/LvlText
## Label displaying the run time as MM:SS.
@onready var time_label: Label  = $Frame/TimeText

## Player stats object that drives the HUD values.
var stats: PlayerStatus
## Current time in seconds, mirrored from the main game.
var current_time_sec: float = 0.0


## Binds this HUD to a PlayerStatus instance and connects its change signal.
func bind_stats(s: PlayerStatus) -> void:
	if stats and stats.stats_changed.is_connected(_on_stats_changed):
		stats.stats_changed.disconnect(_on_stats_changed)
	stats = s
	stats.stats_changed.connect(_on_stats_changed)
	_on_stats_changed()


## Updates all HUD widgets to reflect the latest player stats.
func _on_stats_changed() -> void:
	if stats == null: return
	health_bar.max_value = stats.max_hp
	health_bar.value     = stats.hp
	
	level_label.text     = str(stats.level())
	
	xp_bar.max_value     = stats.xp_to_next
	xp_bar.value         = stats.xp_in_level()


## Sets the displayed run time using the given number of seconds.
func set_time(t: float) -> void:
	current_time_sec = t
	var total := int(current_time_sec)
	@warning_ignore("integer_division")
	var minutes := total / 60
	var seconds := total % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
