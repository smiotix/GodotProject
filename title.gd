extends Node2D

@export var labels: Array[Label] = []
var selected_index = 0
var dead_zone = 0.9
var fullscreen: bool = false
# デッドゾーンの値（0.0〜1.0の範囲）
func _ready():
	labels[0].modulate = Color(1, 1, 0)
	if Globals.lang_setting == 0:
		labels[0].text = "ゲームスタート"
		labels[1].text = "チュートリアル"
		labels[2].text = "ゲームを終わる"
#		labels[3].text = "ゲームを終わる"
	elif Globals.lang_setting == 1:
		labels[0].text = "Game start"
		labels[1].text = "Tutorial"
		labels[2].text = "Exit the game"
	update_selection()
func _process(_delta):
	pass
#if Input.is_action_just_pressed("jump"):
#	get_tree().change_scene_to_file("res://youkaimountain.tscn")

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
			get_tree().change_scene_to_file("res://youkaimountain.tscn")
		elif selected_index == 1:
			get_tree().change_scene_to_file("res://tutorial.tscn")
		elif selected_index == 2:
			get_tree().quit()
	elif event.is_action_pressed("cancel"):
		get_tree().change_scene_to_file("res://opening.tscn")
	
func toggle_fullscreen(): 
	if fullscreen: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
	else: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) 
	fullscreen = not fullscreen	
		
func update_selection(): 
	for i in range(labels.size()):
		if i == selected_index: 
			labels[i].modulate = Color(1, 0, 0)
			 # 選択状態を示す色（黄色） 
		else:
			labels[i].modulate = Color(0, 0, 0) 
			# 通常の色（白）
