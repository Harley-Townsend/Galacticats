extends Node

var current_character = "ShipController"
var current_room: String = ""
var player_position: Vector3 = Vector3.ZERO

func change_room(scene_path: String, room_name: String, new_position: Vector3):
	current_room = room_name
	player_position = new_position
	get_tree().change_scene_to_file(scene_path)


	
