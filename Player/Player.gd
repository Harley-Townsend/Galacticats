extends CharacterBody3D

@export var speed = 14 #How fast the player moves in meters per second
@export var fall_acceleration = 1

var health = 100
var damage = 20
var target_velocity = Vector3.ZERO

func _physics_process(delta):
	var direction = Vector3.ZERO #Store zero as a placeholder variable
	
	if Input.is_action_pressed("move_r"): #Then check for additional input to change direction accordingly
		direction.x += 1
	if Input.is_action_pressed("move_l"):
		direction.x -= 1
	if Input.is_action_pressed("move_f"):
		direction.z -= 1
	if Input.is_action_pressed("move_u"):
		direction.y += 1
	if Input.is_action_pressed("move_d"):
		direction.y -= 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized() #Makes it so you dont travel faster going diagonally like in old MC
		$Pivot.basis = Basis.looking_at(direction)
	
	target_velocity.x = direction.x * speed #Ground velocity
	target_velocity.z = direction.z * speed
	
	velocity = target_velocity
	move_and_slide()
