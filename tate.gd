extends MeshInstance3D

@export var materials: Array[Material] = []

func _ready():
	var i = randi_range(0, 6)
	self.material_override = materials[i]
