extends RayCast3D

# 視界の範囲を設定（例：視界距離10メートル）
var view_distance: float = 25.0
var view_angle_min: float = 20.0  # 前方20度
var view_angle_max: float = 160.0  # 前方110度
var PlayerDetection: bool = false

func _ready():
	#RenderingServer.VIEWPORT_DEBUG_DRAW_WIREFRAME
	# 初期設定などを行う場合はここに記述
	pass

func _process(delta: float):
	for angle_deg in range(view_angle_min, view_angle_max, 5):
		var ray_direction = Vector3(cos(deg_to_rad(angle_deg)),-0.05,sin(deg_to_rad(angle_deg))) * view_distance
		var start_point = global_transform.origin
		var end_point = start_point + ray_direction
		var raycast = RayCast3D.new()  # 新しいレイキャストを作成
		raycast.target_position = ray_direction
		raycast.enabled = true
		self.add_child(raycast)  # レイキャストをシーンに追加
		#raycast.global_transform.origin = start_point
		#DebugDraw3D.draw_line(start_point,end_point,Color(1.0,0.0,0.0,1.0),-view_distance)
		await get_tree().create_timer(0).timeout  # フレームの終わりまで待つ
		if raycast.is_colliding():  # レイキャストオブジェクトに対して衝突検出を行う
			var collided_object = raycast.get_collider()
			if collided_object.is_in_group("Player"):
				if not collided_object.get("stealth"):
					pass
#					PlayerDetection = true
			if raycast.is_colliding():
				var distance = raycast.get_collision_point().distance_to(raycast.global_transform.origin)
				# 距離に応じて異なる処理を実行
				if distance < 10.0:
					#_handle_medium_collision()
					if collided_object.is_in_group("Player"):
						if not collided_object.get("stealth"):
							PlayerDetection = true
				else:
					#_handle_far_collision()
					if collided_object.is_in_group("Player"):
						if not collided_object.get("stealth"):
							if not collided_object.get("is_standing"):
								PlayerDetection = true
				#print("Player Detected")
		self.remove_child(raycast)  # レイキャストをシーンから削除
		raycast.queue_free()  # レイキャストをメモリから解放
		
func _handle_close_collision():
	print("近距離で衝突しました！")

func _handle_medium_collision():
	print("中距離で衝突しました！")

func _handle_far_collision():
	print("遠距離で衝突しました！")
