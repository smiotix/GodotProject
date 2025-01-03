extends Skeleton3D

# ダメージを受けたときに使用するマテリアル
@export var damage_material: Material

# 各メッシュインスタンスの元のマテリアルを保持するリスト
var original_materials: Array = []

# 点滅処理中かどうかを追跡する変数
var is_blinking: bool = false
var Flag01: bool = true
var clock : float = 0.0
var FlashTime: float = 0.1
var ChildList = []

func _ready():
	# 元のマテリアルをリストに保存
	ChildList = get_nodes_child(self)	
	for child in ChildList:
		if child is MeshInstance3D:
			#print(child.name)
			original_materials.append(child.material_override)

func _process(delta):
	if is_blinking:
		if clock <= 0.0:
			update_blinking_effect()
		clock -= delta

# 点滅処理を更新する関数
func update_blinking_effect():
	# 点滅処理を終了し、元のマテリアルに戻す
	var i = 0
	for child in ChildList:
		if child is MeshInstance3D:
			child.material_override = original_materials[i]
			i += 1
	is_blinking = false

# ゲーム中にダメージを受けたときに呼び出される関数
func take_damage():
	clock = FlashTime
	is_blinking = true
	# マテリアルをダメージ用のものに切り替える
	for child in ChildList:
		if child is MeshInstance3D:
			child.material_override = damage_material

func get_nodes_child(root_node: Node) -> Array: 
	var result = [] 
	for child in root_node.get_children():  
		result.append(child) 
		# 子ノードの子ノードも再帰的に探索 
		result += get_nodes_child(child) 
	return result
