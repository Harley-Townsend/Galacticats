extends Node3D


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
			get_tree().change_scene_to_file("res://Levels/TestLevel.tscn")
