#hpxp_ui.gd
extends CanvasLayer

@onready var health_bar = $Health
@onready var xp_bar     = $XP
@onready var level_label: Label = $Frame/LvlText
@onready var time_label: Label  = $Frame/TimeText

var stats: PlayerStatus
var current_time_sec: float = 0.0

func bind_stats(s: PlayerStatus) -> void:
	if stats and stats.stats_changed.is_connected(_on_stats_changed):
		stats.stats_changed.disconnect(_on_stats_changed)
	stats = s
	stats.stats_changed.connect(_on_stats_changed)
	_on_stats_changed()

func _on_stats_changed() -> void:
	if stats == null: return
	health_bar.max_value = stats.max_hp
	health_bar.value     = stats.hp
	
	level_label.text     = str(stats.level())
	
	xp_bar.max_value     = stats.xp_to_next
	xp_bar.value         = stats.xp_in_level()

func set_time(t: float) -> void:
	current_time_sec = t
	var total := int(current_time_sec)
	@warning_ignore("integer_division")
	var minutes := total / 60
	var seconds := total % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
