extends CharacterBody3D

var speed = 10
var gravity = 20
var vel = Vector3.DOWN
var jump_strength = 10

@onready var pivot = $Pivot
@onready var model = $Model

func _physics_process(delta):
	var MoveDir = Vector3.ZERO
	MoveDir.x = Input.get_action_strength("move_r") - Input.get_action_strength("move_l")
	MoveDir.z = Input.get_action_strength("move_b") - Input.get_action_strength("move_f")
	MoveDir = MoveDir.rotated(Vector3.UP, pivot.rotation.y).normalized()
	
	vel.x = MoveDir.x * speed
	vel.z = MoveDir.z * speed
	
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			vel.y = jump_strength
		else:
			vel.y = 0
	else:
		vel.y -= gravity * delta
		
	set_velocity(vel)
	move_and_slide()
	vel = get_real_velocity()
	
	if vel.x != 0 or vel.z != 0:
		var look_direction = Vector2(vel.z, vel.x)
		model.rotation.y = lerp_angle(model.rotation.y, look_direction.angle(), delta*5)
		
func _process(delta):
	pivot.position = position
	
