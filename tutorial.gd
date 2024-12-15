extends Node2D
@export var labels: Array[Label] = []

var text01 = null
var text02 = null
var text03 = null

func _ready() -> void:
	if Globals.lang_setting == 0:
		text01 = load_text_from_file("res://01.txt")
		labels[0].text = text01
		text02 = load_text_from_file("res://02.txt")
		labels[1].text = text02
		text03 = load_text_from_file("res://03.txt")
		labels[2].text = text03
	elif Globals.lang_setting == 1:
		text01 = load_text_from_file("res://01e.txt")
		labels[0].text = text01
		text02 = load_text_from_file("res://02e.txt")
		labels[1].text = text02
		text03 = load_text_from_file("res://03e.txt")
		labels[2].text = text03
		
func load_text_from_file(file_path: String) -> String: 
	var file = FileAccess.open(file_path, FileAccess.READ) 
	if not file: 
		return "" 
	var text = file.get_as_text() 
	file.close()
	return text 
	
func _input(event): 
	if event.is_action_pressed("cancel"):
		get_tree().change_scene_to_file("res://title.tscn")
	elif event.is_action_pressed("jump"):
		get_tree().change_scene_to_file("res://title.tscn")
