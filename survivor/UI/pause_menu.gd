extends Control
class_name PauseMenu

signal resume

var main_menu: PackedScene = load("res://Scenes/title_screen.tscn")

func _play_click_global() -> void:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = preload("res://Assets/audio/mixkit-clicking-on-UI-button-2037.mp3")
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _click():
	var sfx := get_tree().current_scene.get_node("Audio/sfx_clickUI") as AudioStreamPlayer
	if sfx: sfx.play()

func _on_resume_button_up() -> void: #Signals the game to continue and removes itself from the scene tree
	_click()
	resume.emit()
	self.queue_free()


func _on_exit_button_up() -> void: #Tells the game to unfreeze time and then switches to the main_menu
	_play_click_global()
	resume.emit()
	Engine.time_scale = 1.0
	get_tree().change_scene_to_packed(main_menu)
