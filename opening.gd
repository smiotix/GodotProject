extends Node2D 
@export var label: Label
@export var label2: Label
func _ready(): 
	var text_to_display = null
	if Globals.lang_setting == 0:
		text_to_display = load_text_from_file("res://dialogue.txt")
		label2.text = "Aボタンを押してゲームをはじめる"
	elif Globals.lang_setting == 1:
		text_to_display = load_text_from_file("res://dialogue02.txt")
		label2.text = "Press A to start game."
	label.text = "" 
	await display_text_one_by_one(text_to_display)

func load_text_from_file(file_path: String) -> String: 
	var file = FileAccess.open(file_path, FileAccess.READ) 
	if not file: 
		return "テキストファイルがみつかりません" 
	var text = file.get_as_text() 
	file.close()
	return text 
	
func display_text_one_by_one(text_to_display: String):
	var text = "" 
	for char in text_to_display:
		text += char 
		label.text = text 
		await get_tree().create_timer(0.1).timeout # 0.1秒ごとに次の文字を表示

func _input(event): 
	if event.is_action_pressed("jump"):
		get_tree().change_scene_to_file("res://title.tscn")
	if event.is_action_pressed("cancel"):
		get_tree().change_scene_to_file("res://lang.tscn")
