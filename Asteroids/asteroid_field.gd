class_name AsteroidField extends Node3D

var asteroids = [
	preload("res://Asteroids/asteroid_1.tscn"),
	preload("res://Asteroids/asteroid_2.tscn"),
	preload("res://Asteroids/asteroid_3.tscn")]

const RADIUS:int = 20
var WIDTH := 2 * RADIUS + 1
const GRID_SIZE:int = 150
const DENSITY:float = 0.08
const MIN_SCALE:float = 0.5
const MAX_SCALE:float = 2
const MIN_SPAWN_DISTANCE: float = 200.0  # Distance from player
const MIN_BUILDING_DISTANCE: float = 250.0  # Distance from buildings

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
	
	# Get player's current position
	var player_pos = player.global_position
	
	# Calculate which grid cell the player is in
	player_center = Vector3i(floor(player_pos / GRID_SIZE))
	center = Vector3i(player_center)
	
	seed(83833)
	
	# Reset array
	asteroid_array = []
	
	# Build the 3D array centered on player
	for i in range(WIDTH):
		asteroid_array.append([])
		for j in range(WIDTH):
			asteroid_array[i].append([])
			for k in range(WIDTH):
				# Calculate world position for this grid cell
				var grid_x = (i - RADIUS) + player_center.x
				var grid_y = (j - RADIUS) + player_center.y
				var grid_z = (k - RADIUS) + player_center.z
				var pos = Vector3(grid_x + 0.5, grid_y + 0.5, grid_z + 0.5) * GRID_SIZE
				asteroid_array[i][j].append(create_asteroid(pos, false))
	
	print("Asteroid field generated centered on player at grid: ", player_center)

func is_position_safe(pos: Vector3) -> bool:
	# Check distance to player
	var player = get_tree().get_first_node_in_group("PlayerShips")
	if player and pos.distance_to(player.global_position) < MIN_SPAWN_DISTANCE:
		return false
	
	# Check distance to buildings
	var buildings = get_tree().get_nodes_in_group("Buildings")
	for building in buildings:
		if building and pos.distance_to(building.global_position) < MIN_BUILDING_DISTANCE:
			return false
	
	return true

func create_asteroid(pos:Vector3, grow_in:=true) -> Asteroid:
	if randf() > DENSITY:
		return null
	
	# Check if position is safe (away from player and buildings)
	if not is_position_safe(pos):
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
	if amount > 0:
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
	
	player_center = Vector3i(floor(player.global_position / GRID_SIZE))
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
		return
	
	for y in range(asteroid_array[slice_to_update].size()):
		for z in range(asteroid_array[slice_to_update][y].size()):
			if asteroid_array[slice_to_update][y][z] != null:
				asteroid_array[slice_to_update][y][z].queue_free()
				asteroid_array[slice_to_update][y][z] = null
			
			# Calculate world position for the new slice
			var grid_x = (slice_to_update - RADIUS) + center.x + x_diff
			var grid_y = (y - RADIUS) + center.y
			var grid_z = (z - RADIUS) + center.z
			var new_pos = Vector3(grid_x + 0.5, grid_y + 0.5, grid_z + 0.5) * GRID_SIZE
			asteroid_array[slice_to_update][y][z] = create_asteroid(new_pos, true)

func update_y(y_diff:int) -> void:
	var actual_width = asteroid_array.size()
	if actual_width == 0:
		return
	
	var slice_to_update:int = wrap_index(center.y - y_diff * RADIUS)
	
	if slice_to_update < 0 or slice_to_update >= actual_width:
		return
	
	for x in range(asteroid_array.size()):
		if slice_to_update >= asteroid_array[x].size():
			continue
		
		for z in range(asteroid_array[x][slice_to_update].size()):
			if asteroid_array[x][slice_to_update][z] != null:
				asteroid_array[x][slice_to_update][z].queue_free()
				asteroid_array[x][slice_to_update][z] = null
			
			var grid_x = (x - RADIUS) + center.x
			var grid_y = (slice_to_update - RADIUS) + center.y + y_diff
			var grid_z = (z - RADIUS) + center.z
			var new_pos = Vector3(grid_x + 0.5, grid_y + 0.5, grid_z + 0.5) * GRID_SIZE
			asteroid_array[x][slice_to_update][z] = create_asteroid(new_pos, true)

func update_z(z_diff:int) -> void:
	var actual_width = asteroid_array.size()
	if actual_width == 0:
		return
	
	var slice_to_update:int = wrap_index(center.z - z_diff * RADIUS)
	
	if slice_to_update < 0 or slice_to_update >= actual_width:
		return
	
	for x in range(asteroid_array.size()):
		for y in range(asteroid_array[x].size()):
			if slice_to_update >= asteroid_array[x][y].size():
				continue
			
			if asteroid_array[x][y][slice_to_update] != null:
				asteroid_array[x][y][slice_to_update].queue_free()
				asteroid_array[x][y][slice_to_update] = null
			
			var grid_x = (x - RADIUS) + center.x
			var grid_y = (y - RADIUS) + center.y
			var grid_z = (slice_to_update - RADIUS) + center.z + z_diff
			var new_pos = Vector3(grid_x + 0.5, grid_y + 0.5, grid_z + 0.5) * GRID_SIZE
			asteroid_array[x][y][slice_to_update] = create_asteroid(new_pos, true)
