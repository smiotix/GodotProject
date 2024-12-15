extends Node3D

var paused: bool = true
@export var label: Label

func _ready():
	label.text = ""
func _process(delta: float) -> void:
	if not paused:
		if Globals.lang_setting == 0:
			label.text = "Bボタンでタイトルに戻る"
		elif Globals.lang_setting == 1:
			label.text = "Press B to return to the title."
	else:
		label.text = ""
func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = paused
		paused = not paused
	if not paused:
		if event.is_action_pressed("cancel"):
			get_tree().paused = false
			AudioManager.play_music("res://kahvi039a_badloop-your_blue_eyes.mp3")
			get_tree().change_scene_to_file("res://title.tscn")
