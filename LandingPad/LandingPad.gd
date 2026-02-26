extends StaticBody3D

@onready var landing_marker = $LandingMarker.global_position

func _on_area_3d_body_entered(body):
	if body.is_in_group("PlayerShips"):
		print("something entered!")
		body.near_pad()
		body.landing_target = landing_marker
	
		
func _on_area_3d_body_exited(body):
	if body.is_in_group("PlayerShips"):
		print("Goodbye!")
		body.not_near_pad()
		body.landing_target = null
