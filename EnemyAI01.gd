extends CharacterBody3D

enum State {Patrol,Attack,Die,Stop,Stand}
var state = State.Stand 
var walk_speed: float = 2.0
var run_speed:float = 13.0
var rayscript: RayCast3D = null
var gravity: Vector3 = Vector3.ZERO
var state_machine = null
var animation_tree = null
var animstate = null
var WalkTimer: float = 0.0
var currentTime = 0
var transitionTime = 1  # 遷移にかかる時間を1とする
var WalkTime: float = 10.0
var Flag01: bool = true
var target_rotation = null
var current_rotation = null
var t = null
var lerp_speed = 5.0
var body_enter: bool = false
var Player: CharacterBody3D = null
var Flag02: bool = true
var attack_area: Area3D = null
var attack_flag: bool = true
var EffecPos: Node3D = null
var DamageEffect: Skeleton3D =  null
var DamageFlag: bool = false
var damage_duration: float = 1.0
var damage_elapsed:float = 0.0
var before_take_down_flag: bool = false
var HitPoint: int = 100
var p_state_machine = null
var guard_flag: bool = false
var animplayer = null
@export_enum("Patrol","Stand") var type:int
@export var Gate_off: bool = false
var waken: bool = false
var can_parry_flag: bool = true
var death: bool = false 
var audioplayer: AudioStreamPlayer3D = null

func _ready():
	gravity = Vector3.DOWN * ProjectSettings.get_setting("physics/3d/default_gravity")
	rayscript = get_node("mob_tengu/Armature/GeneralSkeleton/BoneAttachment3D3/RayCast3D")
	animation_tree = get_node("mob_tengu/Armature/AnimationTree")
	state_machine = animation_tree.get("parameters/playback")
	attack_area = get_node("mob_tengu/Armature/Area3D")
	EffecPos = get_node("mob_tengu/Armature/EffecPos")
	DamageEffect = get_node("mob_tengu/Armature/GeneralSkeleton")
	animplayer = get_node("mob_tengu/Armature/AnimationPlayer")
	audioplayer = get_node("mob_tengu/AudioStreamPlayer3D")
	var node_group = get_tree().get_nodes_in_group("Player")
	for node in node_group:
		if node is CharacterBody3D:
			Player = node
	var player_anim_tree = Player.get_node("reimu/Armature/AnimationTree")
	p_state_machine = player_anim_tree.get("parameters/playback")
	#print(player_anim_tree.name)
	#print(Player.name)
	WalkTimer = WalkTime
	#print(rayscript.name)
	#print(attack_area.name) 
	attack_area.connect("body_entered", Callable(self, "_on_body_entered"))
	attack_area.connect("body_exited", Callable(self, "_on_Area_body_exited"))
	floor_snap_length = 0.3
	if type == 0:
		state = State.Patrol
	elif type == 1:
		state = State.Stand
	else:
		state = State.Stand
	#print(EffecPos.name)
	#print(animplayer.name)
func _physics_process(delta: float) -> void:
	if Player.get("death"):
		state = State.Stop
		waken = false
	var current_position = state_machine.get_current_play_position ()
	animstate = state_machine.get_current_node()
	if animstate != "guard":
		guard_flag = false
	if state == State.Patrol and not DamageFlag:
		WalkTimer -= delta		
		#print(animstate)
		if WalkTimer < 0.0:
			if WalkTimer > -1.0:
				if Flag01:
					if animstate != "idle":
						state_machine.travel("idle")
				#t = 0.0
				#current_rotation = Quaternion(transform.basis)
				#target_rotation = Quaternion(transform.basis.inverse())
					velocity = Vector3.ZERO + gravity * delta
					current_rotation = global_transform.basis.z.normalized()
					target_rotation = -global_transform.basis.z.normalized()
					Flag01 = false
				var interpolated_direction = current_rotation.lerp(target_rotation, lerp_speed * delta)
				interpolated_direction.y = 0
				look_at(global_transform.origin + interpolated_direction, Vector3.UP)
			else:
				WalkTimer = WalkTime
				Flag01 = true
		else:
			if animstate != "walk":
				state_machine.travel("walk")
			velocity = -global_transform.basis.z * walk_speed + Vector3(0, velocity.y, 0) + gravity * delta
			#velocity = Vector3(0, velocity.y, 0)  + gravity * delta
	#print(WalkTimer)
	elif state == State.Attack and not DamageFlag:
		var target_position = Player.global_transform.origin
		look_at(Vector3(target_position.x,global_transform.origin.y,target_position.z),Vector3.UP)
		var distance = global_transform.origin.distance_to(target_position)
		#print(distance)
		if animstate == "guard":
			if current_position > 0.6:
				await get_tree().create_timer(1.0).timeout
				state_machine.travel("attack")
		elif distance < 1.8 and animstate != "attack":
			var p_state = p_state_machine.get_current_node()
			var p_position = p_state_machine.get_current_play_position ()
			#print(p_state)
			if p_state == "kick" and p_position > 0.6:
				state_machine.travel("guard")
				guard_flag = true
			else:
				state_machine.travel("attack")
				attack_flag = true
			velocity = gravity * delta 
		elif animstate == "attack":
			#animplayer.speed_scale = 3
			#print(animplayer.speed_scale)
			velocity = gravity * delta 
			#print(current_position)
			if current_position > 0.4 and current_position < 1:
				if can_parry_flag:
					can_parry_flag = true
			if current_position > 0.63:
				if not guard_flag:
					guard_flag = true
			if current_position > 1 and attack_flag:
				can_parry_flag = false
				if Player.get("body_enter"):
					if Player.has_method("flash_damage"):
						Player.flash_damage()
						if Player.has_method("HitDamage"):
							Player.HitDamage(30)
						var effect_resource = preload("res://effect/sword02.efkefc")
						var emitter = EffekseerEmitter3D.new()
						emitter.set_effect(effect_resource)
						emitter.transform.origin = EffecPos.transform.origin
						emitter.transform.basis = EffecPos.transform.basis
						emitter.play()
						add_child(emitter)
						var sound = preload("res://soundFX_blade.wav")
						audioplayer.stream = sound
						audioplayer.play()	
						attack_flag = false
			if current_position > 1.53:
				#animplayer.speed_scale = 1
				if guard_flag:
					guard_flag = false
				state_machine.travel("idle")
		else:
			if animstate != "run":
				state_machine.travel("run")
			velocity = -global_transform.basis.z * run_speed + Vector3(0, velocity.y, 0) + gravity * delta 
	elif state == State.Die:
		if Gate_off:
			Gate_off = false
		if animstate != "death":
			state_machine.travel("death")
		velocity = Vector3(0, velocity.y, 0)  + gravity * delta
		await get_tree().create_timer(12.0).timeout
		DamageFlag = false
		self.free()
	elif state == State.Stand:
		if animstate != "Stand":
			state_machine.travel("Stand")
		velocity = Vector3(0, velocity.y, 0)  + gravity * delta		
	else:
		velocity = Vector3(0, velocity.y, 0)  + gravity * delta
	if Flag02 and (state == State.Patrol or state == State.Stand):
		if rayscript.get("PlayerDetection"):
			state = State.Attack
			Flag02 = false
			waken = true
	if DamageFlag:
		#print("damage")
		if damage_elapsed >= damage_duration:
			damage_elapsed = 0.0
			if animstate != "idle":
				state_machine.travel("idle")
			DamageFlag = false
		else:
			if animstate != "damage":
				state_machine.travel("damage")
			damage_elapsed += delta
	if HitPoint <= 0:
		state = State.Die
		death = true
	#print(body_enter)
	#print(animstate)
	if is_instance_valid(self):
		move_and_slide()
	
func flash_damage():
	if state != State.Attack:
		state = State.Attack
		waken = true
	DamageEffect.take_damage()
	HitPoint -= 30
	DamageFlag = true

func take_down():
	var obj = null
	var node_group = get_tree().get_nodes_in_group("Player")
	for node in node_group:
		if node is CharacterBody3D:
			obj = node
	#print(state)
	if state == State.Stop:
		DamageEffect.take_damage()
		if state != State.Die:
			if obj.get("td_Flag"):
				obj.set("td_Flag",false)
			state = State.Die
			death = true


func before_take_down():
	if state != State.Attack:
		state = State.Stop
		before_take_down_flag = true
func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.set("body_enter",true)
		#print("プレイヤーがエリアに入りました",body.get("body_enter"))
func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		body.set("body_enter",false)
		#print("プレイヤーがエリアを離れました",body.get("body_enter"))
func parry():
	can_parry_flag = false
	HitPoint -= 40
	DamageEffect.take_damage()
	DamageFlag = true
	
