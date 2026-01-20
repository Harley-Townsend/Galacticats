extends CharacterBody3D

@export var speed = 10
@export var mouse_sensitivity = 0.002
@export var controller_look_speed = 1.5

#--------------------------- When Instanced ----------------------
func _ready():
	pass

func _input(event):
	if event is InputEventMouseMotion:
		# Tilt the ship itself not just camera
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotate_object_local(Vector3.RIGHT, -event.relative.y * mouse_sensitivity)  # Tilt SHIP
	
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

#---------------- Constantly checking for -------------------------------------------
func _physics_process(delta):
		
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
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
