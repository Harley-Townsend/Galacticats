extends Node

var active = 1

func _ready():
	var ship = get_node("PlayerShip")
	ship.landing_complete.connect(switch_entity)
	$Player.visible = false
	$Player/Pivot/Camera3D.current = false
	$Player.set_process_input(false)
	$Player.set_physics_process(false)
	$PlayerShip/Pivot/Camera3D.current = true
	$PlayerShip.set_process_input(true)
	$PlayerShip.set_physics_process(true)

func _boarding_complete():
	print("u have boarded")
	switch_entity()
	
	
func switch_entity():
	if active == 1:
		print("youre now the cat")
		active = 2
		$PlayerShip/Pivot/Camera3D.current = false
		$PlayerShip.set_process_input(false)
		$PlayerShip.set_physics_process(false)
		$Player.global_transform.origin = $PlayerShip.global_position 
		$Player.visible = true
		$Player/Pivot/Camera3D.current = true
		$Player.set_process_input(true)
		$Player.set_physics_process(true)
	else:
		print("youre now the ship")
		active = 1
		$Player/Pivot/Camera3D.current = false
		$Player.set_process_input(false)
		$Player.set_physics_process(false)
		$Player.visible = false
		$PlayerShip/Pivot/Camera3D.current = true
		$PlayerShip.set_process_input(true)
		$PlayerShip.set_physics_process(true)
		
