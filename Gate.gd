extends Node3D

var Enemys = []
var gateblocks = []

func _ready():
	var node_group = get_tree().get_nodes_in_group("Enemy")
	for node in node_group:
		if node is CharacterBody3D:
			Enemys.append(node)
	for block in self.get_children():
		if block is MeshInstance3D:
			gateblocks.append(block)
	#for block in gateblocks:
	#	pass
		#print(block.name)
			
func _process(_delta):
	if all_enemies_gate_off_false():
		gateblocks[1].visible = false
		gateblocks[2].visible = false
		# 子ノードのStaticBody3Dを取得
		for child in get_children():
			if child is StaticBody3D:
				# 当たり判定を無効にする
				child.collision_layer = 0
				child.collision_mask = 0

# 全てのエネミーオブジェクトのGate_offがfalseか確認する関数
func all_enemies_gate_off_false() -> bool:
	for e in Enemys:
		if e != null:
			if e.get("Gate_off"):
				return false
	return true
