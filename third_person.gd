extends CharacterBody3D

#signal damage_enemy
const JUMP_VELOCITY = 9.2

var animation_tree = null

var state_machine = null

var animstate = null

# カメラノード
var camera_node: Node3D
var EffecPos: Node3D

# 移動とカメラ回転の速度
var move_speed: float = 10.0
var cronch_move_speed: float = 5.0
var camera_rotate_speed: float = 2
# 重力をノードのプロパティとして設定
var gravity = Vector3.ZERO


# ジョイスティックのデッドゾーン
var deadzone: float = 0.2
var move_direction: Vector3 = Vector3.ZERO
var attack_flag = false;
var DamageFlag: bool = true
#var DamageEffect:Skeleton3D = null
var damage_duration: float = 1.0
var damage_elapsed:float = 0.0
#var attack_area: Area3D = null
var enemy_enter: bool = false
var target_direction = Vector3.ZERO
var lerp_speed = 5.0
var parry_miss: bool = false
var parry_miss_timer: float = 0.0
var Flag00: bool = true
#var bar:ProgressBar = null
var Flag01: bool = true
var Flag02: bool = true
var Flag03: bool = true
var is_standing: bool = true
var col_01: CollisionShape3D = null
var col_02: CollisionShape3D = null
var attack_area: Area3D = null
var body_enter: bool = false
var DamageEffect: Skeleton3D = null
var take_down_flag: bool = true
var HitPoint: int = 100
var stealth: bool = false
var td_Flag: bool = false
var death: bool = false
var No_Damage_Timer: float = 0.0
#var WinText: Label = null
var audioplayer: AudioStreamPlayer3D = null
var DieTimer:float = 6
#var PauseText: Label = null



# ジャンプ力と空中でのジャンプ可能回数
#var jump_force: float = 20.0
#var max_jumps: int = 2 # 2回ジャンプ可能
#var jumps_left: int = max_jumps

func _ready():
	gravity = Vector3.DOWN * ProjectSettings.get_setting("physics/3d/default_gravity")
	camera_node = get_node("../Camera_Shaft")
	animation_tree = get_node("reimu/Armature/AnimationTree")
	state_machine = animation_tree.get("parameters/playback")
	EffecPos = get_node("reimu/Armature/EffecPos")
	col_01 = get_node("CollisionShape3D_01")
	col_02 = get_node("CollisionShape3D_02")
	col_02.disabled = true
	#print(col_01.name)
	DamageEffect = get_node("reimu/Armature/GeneralSkeleton")
	attack_area = get_node("reimu/Armature/Area3D")
#	bar = get_node("../Koishi_Life")
#	WinText = get_node("../WinText")
	audioplayer = get_node("reimu/AudioStreamPlayer3D")
#	PauseText = get_node("../PauseText")
#	damage_duration = DamageEffect.get("blink_duration")
	attack_area.connect("body_entered", Callable(self, "_on_body_entered"))
	attack_area.connect("body_exited", Callable(self, "_on_Area_body_exited"))
	floor_snap_length = 0.3
#	bar.value = 100
#	WinText.text = ""
	#for enemy in get_tree().get_nodes_in_group("Enemy"):
	#	enemy.connect("damage_enemy", Callable(enemy, "flash_damage"))
	#print(damage_duration)
func _physics_process(delta: float) -> void:

	#print(DamageFlag)
	#print(damage_elapsed)
	#print(damage_duration)
	#print(damage_elapsed >= damage_duration)
	# ジョイスティックの入力を取得
	var joystick_left_input = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	var joystick_right_input = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	var near_enemy: CharacterBody3D = null
	var nearest_distance: float = INF  # INFは無限大を表す定数です。
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		var distance = global_transform.origin.distance_to(enemy.global_transform.origin)
		if distance < nearest_distance:
			near_enemy = enemy
			nearest_distance = distance
	# デッドゾーンを適用
	joystick_left_input = Vector2.ZERO if joystick_left_input.length() < deadzone else joystick_left_input
	joystick_right_input = Vector2.ZERO if joystick_right_input.length() < deadzone else joystick_right_input
	var current_position = state_machine.get_current_play_position ()
	animstate = state_machine.get_current_node() 
	# キャラクターの移動処理
	if joystick_left_input != Vector2.ZERO and is_on_floor() and DamageFlag and Flag02 and is_standing and not td_Flag and not death:
		move_direction = camera_node.global_transform.basis * Vector3(joystick_left_input.x, 0, joystick_left_input.y).normalized()
		move_direction.y = 0 # Y軸の移動は無視（重力による落下のみ）
		# ジャンプ処理
		#jumps_left = max_jumps # 地面にいる場合はジャンプ回数をリセット
		#velocity += gravity * delta
		if move_direction != Vector3.ZERO:
			#var corrected_direction = move_direction.rotated(Vector3.UP, PI)
			#animstate = state_machine.get_current_node()
			if animstate != "run" and animstate != "kick" and animstate != "take_down":
				state_machine.travel("run")
			#look_at(global_transform.origin + corrected_direction, Vector3.UP)
			look_at(global_transform.origin + move_direction,Vector3.UP)
			if animstate != "kick":
				velocity = move_direction * move_speed + gravity * delta
	elif  joystick_left_input != Vector2.ZERO and is_on_floor() and DamageFlag and Flag02 and not is_standing and not td_Flag and not death:
		move_direction = camera_node.global_transform.basis * Vector3(joystick_left_input.x, 0, joystick_left_input.y).normalized()
		move_direction.y = 0
		if move_direction != Vector3.ZERO:
			look_at(global_transform.origin + move_direction,Vector3.UP)
			if animstate == "cIdle":
				state_machine.travel("cWalk")
			velocity = move_direction * cronch_move_speed + gravity * delta
	elif joystick_left_input == Vector2.ZERO and is_on_floor() and DamageFlag and Flag02 and not is_standing and animstate != "take_down" and animstate != "kick" and animstate != "death":
		if animstate != "cIdle":
			state_machine.travel("cIdle")
		velocity = Vector3(0, velocity.y, 0)  + gravity * delta
	elif animstate != "jump" and is_on_floor() and animstate != "kick" and DamageFlag and animstate != "parry" and animstate != "c2s" and  animstate != "take_down" and animstate != "death" and Flag02 and is_standing:
		#animstate = state_machine.get_current_node()
		if animstate != "idle":
			state_machine.travel("idle")
		velocity = Vector3(0, velocity.y, 0)  + gravity * delta
	elif animstate == "jump" and current_position > 0.85 and Flag02:
		#animstate = state_machine.get_current_node()
		if animstate != "falling":
			state_machine.travel("falling")
	elif Flag02 and is_standing:
		velocity.y = velocity.y + gravity.y * delta
	elif is_standing:
		velocity = Vector3(0, velocity.y, 0)  + gravity * delta
	elif animstate == "falling":
		velocity += gravity * delta
	#print(is_on_floor())
	#print(gravity)
	if Input.is_action_just_pressed("jump") and is_on_floor() and DamageFlag and Flag02 and is_standing and not td_Flag and not death:
		#animstate = state_machine.get_current_node()
		if animstate != "jump":
			state_machine.travel("jump")
		var horizontal_jump = Vector3(move_direction.x, 0, move_direction.z).normalized()
		velocity += horizontal_jump + Vector3.UP * JUMP_VELOCITY
		#velocity += (move_direction.normalized() + Vector3.UP).normalized() * JUMP_VELOCITY 
	#print(move_direction)
	#print(Vector3.UP)
	#print(is_on_floor())
	#print(current_position)
	if !is_on_floor() and Flag02:
		#animstate = state_machine.get_current_node()
		if animstate != "jump":
			state_machine.travel("falling")
	animstate = state_machine.get_current_node()
	if Input.is_action_just_pressed("attack") and is_on_floor()  and animstate != "jump" and animstate != "falling" and animstate != "kick" and DamageFlag and Flag02 and not death:
		state_machine.travel("kick")
		attack_flag = true
	#print(current_position)
	if animstate == "kick" and Flag02:
		if near_enemy != null:
			var current_direction = -global_transform.basis.z.normalized()
			target_direction = (near_enemy.global_transform.origin - global_transform.origin).normalized()
			var interpolated_direction = current_direction.lerp(target_direction, lerp_speed * delta)
			interpolated_direction.y = 0
			look_at(global_transform.origin + interpolated_direction, Vector3.UP)
		# ここで、near_enemyには最も近い敵の参照が格納されます。
		velocity =  Vector3(0, velocity.y, 0)  + gravity * delta
		if current_position > 0.6 and attack_flag:
			#if enemy_enter:
			if near_enemy.get("body_enter"):
				if not near_enemy.get("guard_flag") and not near_enemy.get("death"):
					if near_enemy.has_method("flash_damage"):
						attack_flag = false
						var effect_resource = preload("res://effect/Hit03.efkefc")
						var emitter = EffekseerEmitter3D.new()
						emitter.set_effect(effect_resource)
						emitter.transform.origin = EffecPos.transform.origin
						emitter.transform.basis = EffecPos.transform.basis
						emitter.play()
						add_child(emitter)
						var sound = preload("res://soundFX_Gard.wav")	
						audioplayer.stream = sound
						audioplayer.play()
						near_enemy.flash_damage()
		if current_position > 1.89:
			if is_standing:
				state_machine.travel("idle")
			else:
				state_machine.travel("cIdle")
	if not DamageFlag and Flag02:
		#print("damaged")
		velocity = Vector3(0, velocity.y, 0)  + gravity * delta
		if Flag01:
#			bar.value -= 30
			No_Damage_Timer = 0.8
			Flag03 = false
			Flag01 = false
		if damage_elapsed >= damage_duration:
			damage_elapsed = 0.0
			DamageFlag = true
			Flag01 = true
		else:
			animstate = state_machine.get_current_node()
			if animstate != "damage" and animstate != "jump" and animstate != "falling" and animstate != "death":
				state_machine.travel("damage")
			damage_elapsed += delta
			#print(animstate)
	if not Flag03:
		if No_Damage_Timer <= 0.0:
			Flag03 = true
		else:
			No_Damage_Timer -= delta
		#print(No_Damage_Timer)
	#print(EffecPos.name)	
	#print(animstate)	
	#print(near_enemy.get("waken"))
	if Input.is_action_just_pressed("take_down") and is_on_floor() and DamageFlag and Flag02 and near_enemy.get("waken") and is_standing and not death:
		for enemy in get_tree().get_nodes_in_group("Enemy"):
			if enemy.get("can_parry_flag") and not parry_miss:
				#print(enemy.get("can_parry_flag"))
				if enemy.has_method("parry"):
					if enemy.get("body_enter"):
						var effect_resource = preload("res://effect/Hit02.efkefc")
						var emitter = EffekseerEmitter3D.new()
						emitter.set_effect(effect_resource)
						emitter.transform.origin = EffecPos.transform.origin
						emitter.transform.basis = EffecPos.transform.basis
						emitter.play()
						add_child(emitter)
						#print(emitter.transform.origin)
						enemy.parry()
						var sound = preload("res://soundFX_HAMMER_Hit_Metal_Armor_stereo.wav")	
						audioplayer.stream = sound
						audioplayer.play()
						state_machine.travel("parry")
			else:
				var sound = preload("res://parry_miss.wav")
				audioplayer.stream = sound
				audioplayer.play()
				parry_miss = true
	if joystick_right_input != Vector2.ZERO:
		camera_node.rotate_x(deg_to_rad(-joystick_right_input.y * camera_rotate_speed))
		camera_node.rotate_y(deg_to_rad(joystick_right_input.x * camera_rotate_speed))
	var camerarot = camera_node.transform.basis.get_euler()
	camera_node.transform.basis = Basis.from_euler(Vector3(camerarot.x,camerarot.y,0))
	if animstate == "parry" and current_position > 0.1 and Flag02 and is_standing:
		#print(current_position)
		state_machine.travel("idle")
	if parry_miss:
		if Flag00:
			parry_miss_timer = 0.25
			Flag00 = false
		else:
			parry_miss_timer -=  1 * delta
			#print(parry_miss_timer)
		if parry_miss_timer <= 0.0:
			parry_miss = false
			Flag00 = true
	#else:
	#	print("parry ok")
	#print(parry_miss_timer)
	if Input.is_action_just_pressed("take_down") and not near_enemy.get("waken") and not death:
		take_down_flag = true
		if animstate != "take_down":
			state_machine.travel("take_down")
		if near_enemy != null:
			if near_enemy.get("body_enter"):
				if near_enemy.has_method("before_take_down"):
					near_enemy.before_take_down()
					td_Flag = true
	if Input.is_action_just_pressed("cronch") and is_standing and DamageFlag:
		state_machine.travel("s2c")
		is_standing = false
		col_02.disabled = false
		col_01.disabled = true
	elif Input.is_action_just_pressed("cronch") and not is_standing and DamageFlag:
		if animstate == "cIdle" or animstate == "cWalk":
			state_machine.travel("c2s")
		is_standing = true
		col_01.disabled = false
		col_02.disabled = true
	#print(current_position)
	if animstate == "s2c" and current_position > 0.16:
		state_machine.travel("cIdle")
	if animstate == "c2s" and current_position > 3.36:
		state_machine.travel("idle")
	#print("col01",not col_01.disabled)
	#print("col02",not col_02.disabled)
	if animstate == "take_down" and current_position > 0.61:
		if is_standing:
			state_machine.travel("idle")
		else:
			state_machine.travel("cIdle")
	if animstate == "take_down":
		velocity = Vector3(0, velocity.y, 0)  + gravity * delta
		#print(near_enemy.get("body_enter"))
		#print(near_enemy.has_method("take_down"))
		#print(current_position)
		if current_position >0.29 and take_down_flag and near_enemy != null:
			if near_enemy.get("before_take_down_flag"):
				#print(near_enemy.has_method("take_down"))
				if near_enemy.has_method("take_down"):
					var sound = preload("res://take_down.wav")	
					audioplayer.stream = sound
					audioplayer.play()
					near_enemy.take_down()
			take_down_flag = false		
		elif not near_enemy.get("waken") and take_down_flag:
			if near_enemy != null:
				var current_direction = -global_transform.basis.z.normalized()
				target_direction = (near_enemy.global_transform.origin - global_transform.origin).normalized()
				var interpolated_direction = current_direction.lerp(target_direction, lerp_speed * delta)
				interpolated_direction.y = 0
				look_at(global_transform.origin + interpolated_direction, Vector3.UP)
				if not td_Flag:
					if near_enemy.get("body_enter"):
						if near_enemy.has_method("before_take_down"):
							near_enemy.before_take_down()
							td_Flag = true	
	if HitPoint <= 0:
		if animstate != "death":
			state_machine.travel("death")
			death = true
		velocity = Vector3(0, velocity.y, 0)  + gravity * delta
	if death:
		DieTimer -= delta
		#print(DieTimer)
		if DieTimer <= 0.0:
			AudioManager.play_music("res://kahvi039a_badloop-your_blue_eyes.mp3")
			get_tree().change_scene_to_file("res://title.tscn")	
	#print(current_position)
	#if near_enemy != null:
	#	print("G")
	#print(stealth)
	#print(is_standing)
	move_and_slide()

	# カメラの回転処理
func flash_damage():
	if Flag03:
		DamageEffect.take_damage()
		DamageFlag = false
func HitDamage(damage):
	if Flag03:
		HitPoint -= damage	
	
func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.set("body_enter",true)
		#print("敵がエリアに入りました",body.get("body_enter"))
func _on_Area_body_exited(body):
	if body.is_in_group("Enemy"):
		body.set("body_enter",false)
		#print("敵がエリアを離れました",body.get("body_enter"))
		# ここでプレイヤーがエリアを離れたときの処理を行う
