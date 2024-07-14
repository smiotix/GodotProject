extends Skeleton3D

# ダメージを受けたときに使用するマテリアル
@export var damage_material: Material

# 各メッシュインスタンスの元のマテリアルを保持するリスト
var original_materials: Array = []

# 点滅処理中かどうかを追跡する変数
var is_blinking: bool = false

func _ready():
	# 元のマテリアルをリストに保存
	for child in get_children():
		if child is MeshInstance3D:
			original_materials.append(child.material_override)

func _process(delta):
	if is_blinking:
		update_blinking_effect()

# 点滅処理を更新する関数
func update_blinking_effect():
	# 点滅処理を終了し、元のマテリアルに戻す
	for i in range(len(get_children())):
		var child = get_child(i)
		if child is MeshInstance3D:
			child.material_override = original_materials[i]
	is_blinking = false

# ゲーム中にダメージを受けたときに呼び出される関数
func take_damage():
	is_blinking = true
	# マテリアルをダメージ用のものに切り替える
	for child in get_children():
		if child is MeshInstance3D:
			child.material_override = damage_material
