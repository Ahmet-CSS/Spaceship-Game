#level_up_menu.gd
## Level-up choice menu overlay.[br]
## Shows two upgrade cards, pauses the game, and emits the chosen upgrade key.
extends CanvasLayer

## Emitted when the player selects an upgrade option.[br]
## Carries the upgrade key used by PlayerStatus.apply_upgrade().
signal chosen(key: String)

## Title label displayed at the top of the panel.
@onready var title_label: Label = $Panel/Label
## Button representing the first upgrade option.
@onready var btn_a: Button = $Panel/OptionA
## Button representing the second upgrade option.
@onready var btn_b: Button = $Panel/OptionB

## Style for normal (idle) card state.
@export var card_normal: StyleBoxTexture
## Style for hover/selected card state.
@export var card_hover:  StyleBoxTexture

## Data dictionary for option A (title, desc, key).
var opt_a := {}
## Data dictionary for option B (title, desc, key).
var opt_b := {}


## Displays two upgrade options and pauses the game time.[br]
## Expects an array of two dictionaries with "title", "desc" and "key".
func show_options(options: Array) -> void:
	if options.size() < 2:
		push_warning("LevelUpMenu: expected 2 options, got %d" % options.size())
		return

	opt_a = options[0]
	opt_b = options[1]

	_set_button_text(btn_a, opt_a)
	_set_button_text(btn_b, opt_b)

	title_label.text = "Level Up!"
	visible = true
	Engine.time_scale = 0.0


## Sets the display text for a single option button from a dictionary.
func _set_button_text(btn: Button, opt: Dictionary) -> void:
	var title := str(opt.get("title", ""))
	var desc  := str(opt.get("desc", ""))
	var t: Label = btn.get_node("title")
	var d: Label = btn.get_node("description")
	t.text = title
	d.text = desc
	btn.text = ""
	


## Connects button signals and hides the menu by default.
func _ready() -> void:
	visible = false
	btn_a.pressed.connect(func():
		Engine.time_scale = 1.0
		get_tree().current_scene.sfx("click")
		emit_signal("chosen", opt_a.get("key"))
		queue_free()
	)
	btn_b.pressed.connect(func():
		Engine.time_scale = 1.0
		get_tree().current_scene.sfx("click")
		emit_signal("chosen", opt_b.get("key"))
		queue_free()
	)
