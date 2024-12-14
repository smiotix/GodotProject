extends Node3D

var Reimu : CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var node_group = get_tree().get_nodes_in_group("Player")
	for node in node_group:
		if node is CharacterBody3D:
			Reimu = node
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_transform.origin = Reimu.global_transform.origin + Vector3(0,1.3,0)
