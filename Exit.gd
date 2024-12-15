extends Area3D

var exit_timer: float = 6
var Flag01: bool = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float) -> void:
	if Flag01:
		exit_timer -= delta
		if exit_timer <= 0.0:
			get_tree().change_scene_to_file("res://ending.tscn")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if not Flag01:
			Flag01 = true
