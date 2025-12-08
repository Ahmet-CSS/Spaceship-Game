#pause_menu.gd
extends Control
class_name PauseMenu

signal resume

var main_menu: PackedScene = load("res://Scenes/title_screen.tscn")

func _play_click() -> void:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = preload("res://Assets/audio/mixkit-clicking-on-UI-button-2037.mp3")
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _on_resume_button_up() -> void:
	_play_click()
	resume.emit()
	queue_free()

func _on_exit_button_up() -> void:
	_play_click()
	resume.emit()
	Engine.time_scale = 1.0
	get_tree().change_scene_to_packed(main_menu)
