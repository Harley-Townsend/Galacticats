extends Node

var active = ("ShipController")
var switching_in_progress = false

func _ready():
	var ship = get_node("PlayerShip")
	var player = get_node("Player")
	player.boarding_complete.connect(switch_entity)
	ship.landing_complete.connect(switch_entity)
	$Player.visible = false
	$Player/Pivot/Camera3D.current = false
	$Player.set_process_input(false)
	$Player.set_physics_process(false)
	$PlayerShip/Pivot/Camera3D.current = true
	$PlayerShip.set_process_input(true)
	$PlayerShip.set_physics_process(true)
	
	
func switch_entity():
	if switching_in_progress:
		return
	switching_in_progress = true 
	
	if active == ("ShipController"):
		active = ("CatController")
		$PlayerShip/Pivot/Camera3D/ShipUserInterface/CanvasLayer.visible = false
		$PlayerShip/Pivot/Camera3D.current = false
		$PlayerShip.set_process_input(false)
		$PlayerShip.set_physics_process(false)
		$Player.global_transform.origin = $PlayerShip.global_position 
		$Player.visible = true
		$Player/Pivot/Camera3D.current = true
		$Player/AnimationPlayer.play("climbdown")
		$Player.set_process_input(true)
		$Player.set_physics_process(true)
		$Player/PlayerUserInterface/CanvasLayer.visible = true
	else:
		active = ("ShipController")
		$Player/PlayerUserInterface/CanvasLayer.visible = false
		$Player/Pivot/Camera3D.current = false
		$Player.set_process_input(false)
		$Player.set_physics_process(false)
		$Player.visible = false
		$PlayerShip/Pivot/Camera3D.current = true
		$PlayerShip.set_process_input(true)
		$PlayerShip.set_physics_process(true)
		$PlayerShip/Pivot/Camera3D/ShipUserInterface/CanvasLayer.visible = true
		
	await get_tree().create_timer(0.5).timeout
	switching_in_progress = false
