extends CharacterBody3D

var speed = 10
var gravity = 20
var vel = Vector3.DOWN
var jump_strength = 10
var can_board = false
var state = "normal"

@onready var pivot = $Pivot
@onready var model = $Armature
@onready var parent = get_parent()

func _input(event):
	if can_board == true and Input.is_action_just_pressed("interact"):
		board()
		


func _physics_process(delta):
	if state != "normal":
		return
		
	var MoveDir = Vector3.ZERO
	MoveDir.x = Input.get_action_strength("move_r") - Input.get_action_strength("move_l")
	MoveDir.z = Input.get_action_strength("move_b") - Input.get_action_strength("move_f")
	MoveDir = MoveDir.rotated(Vector3.UP, pivot.rotation.y).normalized()
	
	vel.x = MoveDir.x * speed
	vel.z = MoveDir.z * speed
	
	if is_on_floor():
		if Input.is_action_pressed("jump"):
			$AnimationPlayer.play("jump")
			$Particles.emitting = false
			vel.y = jump_strength
		elif Input.is_action_pressed("move_f"):
			$AnimationPlayer.play("run")
			$Particles.emitting = true
		elif Input.is_action_pressed("move_b"):
			$AnimationPlayer.play("run")
			$Particles.emitting = true
		elif Input.is_action_pressed("move_l"):
			$AnimationPlayer.play("run")
			$Particles.emitting = true
		elif Input.is_action_pressed("move_r"):
			$AnimationPlayer.play("run")
			$Particles.emitting = true
		else:
			vel.y = 0
			$AnimationPlayer.play("idle")
			$Particles.emitting = false
	else:
		vel.y -= gravity * delta
		
	set_velocity(vel)
	move_and_slide()
	vel = get_real_velocity()
	
	if vel.x != 0 or vel.z != 0:
		var look_direction = Vector2(vel.z, vel.x)
		model.rotation.y = lerp_angle(model.rotation.y, look_direction.angle(), delta*5)
		

signal boarding_complete

func _process(delta):
	pivot.position = position

func board():
	can_board = false
	state = "boarding"
	$AnimationPlayer.play("climbup")
	await $AnimationPlayer.animation_finished
	state = "normal"
	emit_signal("boarding_complete")

func near_ship():
	can_board = true
	$PlayerUserInterface/CanvasLayer/BoardLabel.visible = true
func not_near_ship():
	can_board = false
	$PlayerUserInterface/CanvasLayer/BoardLabel.visible = false
