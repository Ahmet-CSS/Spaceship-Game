#pause_menu.gd
## Pause menu overlay for the main game.[br]
## Provides Resume and Exit to Title buttons and plays a click sound on actions.
extends Control
class_name PauseMenu

## Emitted when the player presses the Resume button.
signal resume

## Packed scene for the title screen used when exiting the run.
var main_menu: PackedScene = load("res://Scenes/title_screen.tscn")


## Plays a UI click sound using a temporary AudioStreamPlayer on the SFX bus.
func _play_click() -> void:
	var p := AudioStreamPlayer.new()
	p.bus = "SFX"
	p.stream = preload("res://Assets/audio/mixkit-clicking-on-UI-button-2037.mp3")
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)


## Handles the Resume button press.[br]
## Plays a click sound, emits the resume signal and closes the menu.
func _on_resume_button_up() -> void:
	_play_click()
	resume.emit()
	queue_free()


## Handles the Exit button press.[br]
## Plays a click sound, resumes time and switches back to the title scene.
func _on_exit_button_up() -> void:
	_play_click()
	resume.emit()
	Engine.time_scale = 1.0
	get_tree().change_scene_to_packed(main_menu)
