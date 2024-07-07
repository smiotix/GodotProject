extends RayCast3D

# 視界の範囲を設定（例：視界距離10メートル）
var view_distance: float = 18.0
var view_angle_min: float = 20.0  # 前方20度
var view_angle_max: float = 160.0  # 前方110度

func _ready():
	#RenderingServer.VIEWPORT_DEBUG_DRAW_WIREFRAME
	# 初期設定などを行う場合はここに記述
	pass

func _process(delta: float):
	for angle_deg in range(view_angle_min, view_angle_max, 10):
		var ray_direction = Vector3(cos(deg_to_rad(angle_deg)),-0.08,sin(deg_to_rad(angle_deg))) * view_distance
		target_position = transform.origin + ray_direction
		
		var start_point = global_transform.origin
		var end_point = start_point + ray_direction
		# 視界を線で描画
		DebugDraw3D.draw_line(start_point,end_point,Color(1.0,0.0,0.0,1.0),view_distance)
		if is_colliding():
			var collision_point = get_collision_point()
			var collided_object = get_collider()
			if collided_object.is_in_group("Player"):
				print("Player Detected")
				#var group_name = collided_object.get_collision_layer()				
				#pass
			# 衝突したオブジェクトに対する処理を実装
#			if not (collided_object is StaticBody3D):
#				print("視界内に衝突したオブジェクト:", collided_object)
