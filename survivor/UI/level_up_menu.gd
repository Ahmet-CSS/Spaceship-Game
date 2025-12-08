#level_up_menu.gd
extends CanvasLayer
signal chosen(key: String)

@onready var title_label: Label = $Panel/Label
@onready var btn_a: Button = $Panel/OptionA
@onready var btn_b: Button = $Panel/OptionB

@export var card_normal: StyleBoxTexture
@export var card_hover:  StyleBoxTexture

var opt_a := {}
var opt_b := {}

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

func _set_button_text(btn: Button, opt: Dictionary) -> void:
	var title := str(opt.get("title", ""))
	var desc  := str(opt.get("desc", ""))
	var t: Label = btn.get_node("title")
	var d: Label = btn.get_node("description")
	t.text = title
	d.text = desc
	btn.text = ""
	


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
