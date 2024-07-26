extends Node3D

func _ready():
	var enemy_scene = preload("res://mob_tengu02.tscn")
	#if enemy_scene is PackedScene:
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	if enemy != null:
		print("#")
	enemy.transform.origin = transform.origin
	enemy.transform.basis = transform.basis
