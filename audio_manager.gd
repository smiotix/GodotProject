extends Node

@export var music_player: AudioStreamPlayer

func _ready():
	if not music_player:
		music_player = AudioStreamPlayer.new()
		add_child(music_player)

func play_music(file_path: String):
	var music = load(file_path)
	if music:
		music_player.stream = music
		music_player.play()
