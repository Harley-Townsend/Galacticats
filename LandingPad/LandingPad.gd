extends StaticBody3D

func _on_area_3d_body_entered(body):
	print("something entered!")
	if body.is_in_group("PlayerShips"):
		body.near_pad()
		
func _on_area_3d_body_exited(body):
	print("Goodbye!")
	if body.is_in_group("PlayerShips"):
		body.not_near_pad()
