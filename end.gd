extends Node2D

func _input(event): 
	if event.is_action_pressed("jump"):
		get_tree().change_scene_to_file("res://title.tscn")
	if event.is_action_pressed("cancel"):
		get_tree().change_scene_to_file("res://title.tscn")
