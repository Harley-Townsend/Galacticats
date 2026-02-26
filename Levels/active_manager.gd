# ActiveManager.gd
extends Node

var active = "ShipController"
var switching_in_progress = false

# Cache references for convenience
@onready var ship = $PlayerShip
@onready var player = $Player
@onready var ship_camera = ship.get_node("Pivot/Camera3D")
@onready var ship_ui = ship_camera.get_node("ShipUserInterface/CanvasLayer")
@onready var player_camera = player.get_node("Pivot/Camera3D")
@onready var player_ui = player.get_node("PlayerUserInterface/CanvasLayer")
@onready var player_anim = player.get_node("AnimationPlayer")

func _ready():
	# Connect signals
	restore_ship_position()
	ship.fuel_amount = ShipManager.fuel_amount
	
	player.boarding_complete.connect(switch_entity)
	ship.landing_complete.connect(switch_entity)

	# Restore state from GameState
	if GameState.current_character == "ShipController":
		active = "ShipController"
		_activate_ship()
	else:
		active = "CatController"
		_activate_player()


# Called when switching between ship and player
func switch_entity():
	if switching_in_progress:
		return
	switching_in_progress = true

	if active == "ShipController":
		active = "CatController"
		_activate_player_from_ship()
	else:
		active = "ShipController"
		_activate_ship_from_player()

	# Update GameState with current active entity and position
	if active == "ShipController":
		GameState.current_character = "ShipController"
		GameState.player_position = ship.global_position
	else:
		GameState.current_character = "CatController"
		GameState.player_position = player.global_position

	# Small delay to prevent multiple switches at once
	await get_tree().create_timer(0.5).timeout
	switching_in_progress = false

# Helper functions
func _activate_ship():
	player.visible = false
	player.set_process_input(false)
	player.set_physics_process(false)
	player_camera.current = false
	player_ui.visible = false

	ship.visible = true
	ship.set_process_input(true)
	ship.set_physics_process(true)
	ship_camera.current = true
	ship_ui.visible = true

func _activate_player():
	player.visible = true
	player.set_process_input(true)
	player.set_physics_process(true)
	player_camera.current = true
	player_ui.visible = true
	
	ship.deactivate()
	ship.set_process_input(false)
	ship.set_physics_process(false)
	ship_camera.current = false
	ship_ui.visible = false

# Smooth transitions triggered by signals
func _activate_player_from_ship():
	ship.deactivate()
	ship_ui.visible = false
	ship_camera.current = false
	ship.set_process_input(false)
	ship.set_physics_process(false)

	player.global_transform.origin = ship.global_position
	player.visible = true
	player_camera.current = true
	player_anim.play("climbdown")
	player.set_process_input(true)
	player.set_physics_process(true)
	player_ui.visible = true

func _activate_ship_from_player():
	player_ui.visible = false
	player_camera.current = false
	player.set_process_input(false)
	player.set_physics_process(false)
	player.visible = false

	ship_camera.current = true
	ship.set_process_input(true)
	ship.set_physics_process(true)
	ship_ui.visible = true
	ship.visible = true

func save_ship_position():
	ShipManager.ship_position = ship.global_position
	ShipManager.fuel_amount = ship.fuel_amount
func restore_ship_position():
	if ShipManager.ship_position != Vector3.ZERO:
		ship.global_transform.origin = ShipManager.ship_position
	
	
