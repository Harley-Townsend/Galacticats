extends StaticBody3D

@onready var landing_marker = $LandingMarker.global_position
@onready var prompt = $Area3D/Label

func _on_area_3d_body_entered(body):
	print("something entered!")
	if body.is_in_group("PlayerShips"):
		prompt.visible = true
		body.near_pad()
		body.landing_target = landing_marker
		
func _on_area_3d_body_exited(body):
	print("Goodbye!")
	if body.is_in_group("PlayerShips"):
		prompt.visible = false
		body.not_near_pad()
		body.landing_target = null
