extends CanvasLayer

@onready var health_bar = $Health
@onready var xp_bar     = $XP
@onready var level_label: Label = $Frame/LvlText


@onready var hp_label: Label = $HPLabel      # new label for hp
@onready var xp_label: Label = $XPLabel      # new label for xp

var stats: PlayerStatus

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
	
	## numbers in top left
	hp_label.text = "HP: %d / %d" % [stats.hp, stats.max_hp]
	xp_label.text = "XP: %d / %d" % [stats.xp_in_level(), stats.xp_to_next]
