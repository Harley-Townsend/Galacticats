extends CharacterBody3D

@export var speed = 10
@export var mouse_sensitivity = 0.002
@export var controller_look_speed = 1.5

#--------------------------- When Instanced ----------------------
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#---------------- Constantly checking for -------------------------------------------
func _physics_process(delta):
	
	var direction = Vector3.ZERO
	
	# Movement
	if Input.is_action_pressed("move_f"):
		direction.z -= 1
	if Input.is_action_pressed("move_b"):
		direction.z += 1
	if Input.is_action_pressed("move_l"):
		direction.x -= 1
	if Input.is_action_pressed("move_r"):
		direction.x += 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()
		
	
