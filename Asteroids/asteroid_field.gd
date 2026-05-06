class_name AsteroidField extends Node3D

var asteroids = [
	preload("res://Asteroids/asteroid_1.tscn"),
	preload("res://Asteroids/asteroid_2.tscn"),
	preload("res://Asteroids/asteroid_3.tscn")]

const RADIUS:int = 25
var WIDTH := 2 * RADIUS + 1
const GRID_SIZE:int = 100
const DENSITY:float = 0.08
const MIN_SCALE:float = 5
const MAX_SCALE:float = 10
const FIELD_OFFSET := Vector3(500, 500, 500)

var asteroid_array:Array = []
var center := Vector3i.ZERO
var player_center := Vector3i.ZERO

func _ready():
	generate_field()

func generate_field() -> void:
	WIDTH = 2 * RADIUS + 1
	
	var player = get_tree().get_first_node_in_group("PlayerShips")
	if not player:
		push_error("No player found in group 'PlayerShips'")
		return
	
	# Place player at origin, AWAY from asteroids
	player.global_position = Vector3.ZERO
	
	# Grid center for internal calculations
	var grid_center = Vector3(RADIUS+0.5, RADIUS+0.5, RADIUS+0.5) * GRID_SIZE
	player_center = Vector3i(floor(grid_center/GRID_SIZE))
	center = Vector3i(player_center)
	
	seed(83833)
	
	# Reset array
	asteroid_array = []
	
	# Build the 3D array with offset
	for i in range(WIDTH):
		asteroid_array.append([])
		for j in range(WIDTH):
			asteroid_array[i].append([])
			for k in range(WIDTH):
				var pos = Vector3(i+0.5, j+0.5, k+0.5) * GRID_SIZE + FIELD_OFFSET
				asteroid_array[i][j].append(create_asteroid(pos, false))
	
	print("Asteroid field generated at offset: ", FIELD_OFFSET)
	print("Player position: ", player.global_position)

func create_asteroid(pos:Vector3, grow_in:=true) -> Asteroid:
	if randf() > DENSITY:
		return null
	var a = asteroids.pick_random().instantiate()
	add_child(a)
	a.global_position = pos
	var temp_scale:float = randf_range(MIN_SCALE, MAX_SCALE)
	var rot_x = randf_range(0, TAU)
	var rot_y = randf_range(0, TAU)
	var rot_z = randf_range(0, TAU)
	a.rotation = Vector3(rot_x, rot_y, rot_z)
	var amount := GRID_SIZE/2.0 - temp_scale + 1
	var pos_x = randf_range(-amount, amount)
	var pos_y = randf_range(-amount, amount)
	var pos_z = randf_range(-amount, amount)
	a.global_position += Vector3(pos_x, pos_y, pos_z)
	if grow_in and a.has_method("swell_in"):
		a.swell_in(temp_scale)
	else:
		a.scale = Vector3(temp_scale, temp_scale, temp_scale)
	return a

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("PlayerShips")
	if not player:
		return
	
	if asteroid_array.size() == 0:
		return
	
	player_center = Vector3i(floor(player.global_position/GRID_SIZE))
	if center == player_center:
		return
	
	var diff:Vector3i = player_center - center
	if diff.x != 0:
		update_x(diff.x)
		center.x = player_center.x
	elif diff.y != 0:
		update_y(diff.y)
		center.y = player_center.y
	elif diff.z != 0:
		update_z(diff.z)
		center.z = player_center.z

func wrap_index(index:int) -> int:
	var actual_width = asteroid_array.size()
	if actual_width == 0:
		return 0
	var wrapped = index % actual_width
	if wrapped < 0:
		wrapped += actual_width
	return wrapped

func update_x(x_diff:int) -> void:
	var actual_width = asteroid_array.size()
	if actual_width == 0:
		return
	
	var slice_to_update:int = wrap_index(center.x - x_diff * RADIUS)
	
	if slice_to_update < 0 or slice_to_update >= actual_width:
		push_error("update_x: slice_to_update ", slice_to_update, " out of bounds 0-", actual_width-1)
		return
	
	for y in range(asteroid_array[slice_to_update].size()):
		for z in range(asteroid_array[slice_to_update][y].size()):
			if asteroid_array[slice_to_update][y][z] != null:
				asteroid_array[slice_to_update][y][z].queue_free()
				asteroid_array[slice_to_update][y][z] = null
			
			var new_pos = Vector3(
				(slice_to_update + 0.5) * GRID_SIZE,
				(y + 0.5) * GRID_SIZE,
				(z + 0.5) * GRID_SIZE
			) + FIELD_OFFSET
			asteroid_array[slice_to_update][y][z] = create_asteroid(new_pos, true)

func update_y(y_diff:int) -> void:
	var actual_width = asteroid_array.size()
	if actual_width == 0:
		return
	
	var slice_to_update:int = wrap_index(center.y - y_diff * RADIUS)
	
	if slice_to_update < 0 or slice_to_update >= actual_width:
		push_error("update_y: slice_to_update ", slice_to_update, " out of bounds 0-", actual_width-1)
		return
	
	for x in range(asteroid_array.size()):
		if slice_to_update >= asteroid_array[x].size():
			continue
		
		for z in range(asteroid_array[x][slice_to_update].size()):
			if asteroid_array[x][slice_to_update][z] != null:
				asteroid_array[x][slice_to_update][z].queue_free()
				asteroid_array[x][slice_to_update][z] = null
			
			var new_pos = Vector3(
				(x + 0.5) * GRID_SIZE,
				(slice_to_update + 0.5) * GRID_SIZE,
				(z + 0.5) * GRID_SIZE
			) + FIELD_OFFSET
			asteroid_array[x][slice_to_update][z] = create_asteroid(new_pos, true)

func update_z(z_diff:int) -> void:
	var actual_width = asteroid_array.size()
	if actual_width == 0:
		return
	
	var slice_to_update:int = wrap_index(center.z - z_diff * RADIUS)
	
	if slice_to_update < 0 or slice_to_update >= actual_width:
		push_error("update_z: slice_to_update ", slice_to_update, " out of bounds 0-", actual_width-1)
		return
	
	for x in range(asteroid_array.size()):
		for y in range(asteroid_array[x].size()):
			if slice_to_update >= asteroid_array[x][y].size():
				continue
			
			if asteroid_array[x][y][slice_to_update] != null:
				asteroid_array[x][y][slice_to_update].queue_free()
				asteroid_array[x][y][slice_to_update] = null
			
			var new_pos = Vector3(
				(x + 0.5) * GRID_SIZE,
				(y + 0.5) * GRID_SIZE,
				(slice_to_update + 0.5) * GRID_SIZE
			) + FIELD_OFFSET
			asteroid_array[x][y][slice_to_update] = create_asteroid(new_pos, true)
