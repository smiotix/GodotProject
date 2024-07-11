extends CharacterBody3D

enum State {Patrol,Attack}
var state = State.Patrol
var walk_speed: float = 3.0
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

func _ready():
	gravity = Vector3.DOWN * ProjectSettings.get_setting("physics/3d/default_gravity")
	rayscript = get_node("mob_tengu/Armature/GeneralSkeleton/BoneAttachment3D3/RayCast3D")
	animation_tree = get_node("mob_tengu/Armature/AnimationTree")
	state_machine = animation_tree.get("parameters/playback")
	var node_group = get_tree().get_nodes_in_group("Player")
	for node in node_group:
		if node is CharacterBody3D:
			Player = node
	#print(Player.name)
	WalkTimer = WalkTime
	#print(rayscript.name)
func _physics_process(delta: float) -> void:
	if state == State.Patrol:
		WalkTimer -= delta
		animstate = state_machine.get_current_node()
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
			velocity = -transform.basis.z * walk_speed + gravity * delta
	#print(WalkTimer)
	move_and_slide()
