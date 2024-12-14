extends BoneAttachment3D

func _ready(): 
	var random_number = randi_range(0, 3)
	# 使用例: 特定の型のノードを取得
	var mesh_nodes = get_nodes_of_type(self)
	#print(mesh_nodes.size())
	for i in range(4):
		if random_number == i:
			mesh_nodes[i].visible = true
		else:
			mesh_nodes[i].visible = false
	#print("Found mesh nodes: ", mesh_nodes)

# 特定の型に一致するノードをリストに追加する関数
func get_nodes_of_type(root_node: Node) -> Array:
	var result = []
	for child in root_node.get_children():
		if child is MeshInstance3D:
			result.append(child)
# 子ノードの子ノードも再帰的に探索
		result += get_nodes_of_type(child)
	return result

# 使用例: 特定の型のノードを取得
