extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if not body.get("is_standing"):
			body.set("stealth",true)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.set("stealth",false)
