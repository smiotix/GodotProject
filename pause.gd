extends Node3D

var paused: bool = true

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = paused
		paused = not paused
