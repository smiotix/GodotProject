extends CharacterBody3D

enum State {Patrol,Attack}
var state = State.Patrol
var walk_speed: float = 3.0
var rayscript: RayCast3D = null
var gravity: Vector3 = Vector3.ZERO
var state_machine = null
var animation_tree = null
var animstate = null

func _ready():
	gravity = Vector3.DOWN * ProjectSettings.get_setting("physics/3d/default_gravity")
	rayscript = get_node("mob_tengu/Armature/GeneralSkeleton/BoneAttachment3D3/RayCast3D")
	animation_tree = get_node("mob_tengu/Armature/AnimationTree")
	state_machine = animation_tree.get("parameters/playback")
	#print(rayscript.name)
func _physics_process(delta: float) -> void:
	if state == State.Patrol:
		animstate = state_machine.get_current_node()
		if animstate != "walk":
			state_machine.travel("walk")
		#print(animstate)
		velocity = -transform.basis.z * walk_speed + gravity * delta
	move_and_slide()
