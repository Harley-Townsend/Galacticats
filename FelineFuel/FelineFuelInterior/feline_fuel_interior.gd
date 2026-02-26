extends Node3D

@export var target_scene: String
@export var target_room_name: String
@export var spawn_position: Vector3

var can_enter = false

func _on_area_3d_body_entered(body):
	if body.is_in_group("Player"):
		var prompt = body.get_node("PlayerUserInterface/CanvasLayer/Label")
		if prompt:
			prompt.text = "Exit [ E ]"
			prompt.visible = true
		can_enter = true
		
func _on_area_3d_body_exited(body):
	if body.is_in_group("Player"):
		var prompt = body.get_node("PlayerUserInterface/CanvasLayer/Label")
		if prompt:
			prompt.visible = false
		can_enter = false
		
func _process(delta):
	if can_enter == true:
		if Input.is_action_just_pressed("interact"):
			GameState.player_position = spawn_position
			get_tree().change_scene_to_file(target_scene)
