extends CharacterBody3D

@export var speed = 10.0
@export var mouse_sensitivity = 0.002
@export var controller_look_speed = 1.5
@export var roll_speed = 3.0
@export var fuel_amount = 100

var can_land = false
var landing_target = null


#----------------------- Upon Launching --------------------------------------------

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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


#---------------------------- Constantly Checking For ------------------------------------

func _physics_process(delta):

	# Controller look - tilt the ship
	var right_stick_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var right_stick_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	rotate_y(-right_stick_x * controller_look_speed * delta)
	rotate_object_local(Vector3.RIGHT, -right_stick_y * controller_look_speed * delta)  # Tilt SHIP
		
	# Roll controls
	var roll_input = 0.0
	if Input.is_action_pressed("roll_l"):
		roll_input += 1.0
	if Input.is_action_pressed("roll_r"):
		roll_input -= 1.0
	rotate_object_local(Vector3.FORWARD, roll_input * roll_speed * delta)
		
	# Keep cam upright. This makes camera look forward but ship can tilt
	$Pivot.rotation.x = 0  # Reset camera tilt
	$Pivot.rotation.z = 0  # Reset camera roll
		
	var direction = Vector3.ZERO
		
	# Movement - ALWAYS go "forward" relative to SHIP
	if Input.is_action_pressed("move_f"):
		direction.z -= 1
		$BoostParticles.emitting = true
		lose_fuel()
	# Move relative to SHIP'S orientation (not camera)
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Get SHIP'S orientation (not Pivot/camera)
		var ship_basis = global_transform.basis
		velocity = (ship_basis.x * direction.x + ship_basis.y * direction.y + ship_basis.z * direction.z) * speed
	else:
		velocity.z = move_toward(velocity.z, 0, 0.1) 
		velocity.y = move_toward(velocity.y, 0, 0.1)
		velocity.x = move_toward(velocity.x, 0, 0.1)
		$BoostParticles.emitting = false
		
			
	move_and_slide()
			
	if can_land == true and Input.is_action_just_pressed("interact"):
		print("Landed!")
		land()
	
	if fuel_amount == 100:
		$Pivot/Camera3D/ShipUserInterface/CanvasLayer/Label.text = str(fuel_amount, "%")
	else:
		$Pivot/Camera3D/ShipUserInterface/CanvasLayer/Label.text = str("%.1f" % fuel_amount, "%")
	
	

#--------------------------------------- Functions --------------------------
signal landing_complete

func near_pad():
	can_land = true
func not_near_pad():
	can_land = false

func land():
	global_transform.origin = landing_target
	can_land = false
	emit_signal("landing_complete")
	
func lose_fuel():
	fuel_amount = fuel_amount - 0.005
	
		
	
	
	
	
	
	
