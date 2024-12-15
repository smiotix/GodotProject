extends Node2D
@export var labels: Array[Label] = []
var selected_index = 0
var dead_zone = 0.9

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	update_selection()
	AudioManager.play_music("res://kahvi039a_badloop-your_blue_eyes.mp3")

func _input(event): 
	var axis_value_up_down = Input.get_axis("joy_axis_up", "joy_axis_down") 
	#rint("Axis Value Up/Down: ", axis_value_up_down)
	# デッドゾーンのチェック 
	if abs(axis_value_up_down) > dead_zone: 
		if axis_value_up_down > 0: 
			selected_index = (selected_index + 1) % labels.size() 
		elif axis_value_up_down < 0: 
			selected_index = (selected_index - 1 + labels.size()) % labels.size() 
		update_selection()
	if event.is_action_pressed("cross_down"):
		selected_index = (selected_index + 1) % labels.size() 
		update_selection() 
	elif event.is_action_pressed("cross_up"):
		selected_index = (selected_index - 1 + labels.size()) % labels.size() 
		update_selection() 
	elif event.is_action_pressed("jump"):
		if selected_index == 0:
			Globals.lang_setting = 0
			get_tree().change_scene_to_file("res://opening.tscn")
		elif selected_index == 1:
			Globals.lang_setting = 1
			get_tree().change_scene_to_file("res://opening.tscn")

func update_selection(): 
	for i in range(labels.size()):
		if i == selected_index: 
			labels[i].modulate = Color(1, 0, 0)
			 # 選択状態を示す色（黄色） 
		else:
			labels[i].modulate = Color(0, 0, 0) 
			# 通常の色（白）
