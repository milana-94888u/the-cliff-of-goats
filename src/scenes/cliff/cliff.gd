class_name Cliff
extends Node2D


var grass_to_stone_mapping := {
	Vector2i(0, 0): Vector2i(6, 0),
	Vector2i(1, 0): Vector2i(7, 0),
	Vector2i(2, 0): Vector2i(8, 0),
	Vector2i(0, 1): Vector2i(6, 1),
	Vector2i(1, 1): Vector2i(7, 1),
	Vector2i(2, 1): Vector2i(8, 1),
	Vector2i(3, 0): Vector2i(9, 0),
	Vector2i(4, 0): Vector2i(10, 0),
	Vector2i(5, 0): Vector2i(11, 0),
}

var stone_to_grass_mapping := {
	Vector2i(6, 0): Vector2i(0, 0),
	Vector2i(7, 0): Vector2i(1, 0),
	Vector2i(8, 0): Vector2i(2, 0),
	Vector2i(6, 1): Vector2i(0, 1),
	Vector2i(7, 1): Vector2i(1, 1),
	Vector2i(8, 1): Vector2i(2, 1),
	Vector2i(9, 0): Vector2i(3, 0),
	Vector2i(10, 0): Vector2i(4, 0),
	Vector2i(11, 0): Vector2i(5, 0),
}

var cliff_tiles := [
	Vector2i(3, 1), Vector2i(4, 1), Vector2i(4, 1),
	Vector2i(3, 2), Vector2i(4, 2), Vector2i(4, 2),
]


@onready var tilemap := $TileMap as TileMap

@export var goat_scene: PackedScene

var goats: Array[Goat]


func _enter_tree() -> void:
	GrassFindManager.register_world(self)


func _exit_tree() -> void:
	GrassFindManager.unregister_world(self)


func generate_layer(x_start: int, x_end: int, y_start: int, y_end: int) -> Array[Vector2i]:
	randomize()
	var cells: Array[Vector2i] = []
	for x in range(x_start, x_end):
		for y in range(y_start, y_end):
			cells.append(Vector2i(x, y))
	return cells


func place_goats(plateau_cells: Array[Vector2i]) -> void:
	plateau_cells.shuffle()
	for goat_index in range(10):
		var goat: Goat = goat_scene.instantiate()
		goat.position = tilemap.map_to_local(plateau_cells[goat_index])
		add_child(goat)
		goats.append(goat)


func _ready() -> void:
	randomize()
	var x_start := 0
	var x_end := 100
	var y_offset := 0
	for layer in 10:
		tilemap.add_layer(-1)
		
		var cliff_height := randi_range(3, 10)
		var cliff_cells := generate_layer(x_start, x_end, y_offset - cliff_height, y_offset)
		y_offset -= cliff_height - 1
		
		var plateau_height := randi_range(10, 20)
		var plateau_cells := generate_layer(x_start, x_end, y_offset - plateau_height, y_offset)
		y_offset -= plateau_height - 1
		
		tilemap.set_cells_terrain_connect(layer, cliff_cells, 0, 1)
		tilemap.set_cells_terrain_connect(layer, plateau_cells, 0, 2)
		if layer == 0:
			place_goats(plateau_cells)
		
		x_start += randi_range(3, 8)
		x_end -= randi_range(3, 8)


func get_first_layer_with_tile(tile_coords: Vector2i) -> int:
	for layer in range(tilemap.get_layers_count()):
		if tilemap.get_cell_tile_data(layer, tile_coords):
			return layer
	return -1


func is_cliff_tile(tile_coords: Vector2i) -> bool:
	var layer := get_first_layer_with_tile(tile_coords)
	if layer == -1:
		return false
	return (
		tilemap.get_cell_atlas_coords(layer, tile_coords) in cliff_tiles
		and tilemap.get_cell_source_id(layer, tile_coords) == 0
	)


func is_stone_tile(tile_coords: Vector2i) -> bool:
	var layer := get_first_layer_with_tile(tile_coords)
	if layer == -1:
		return false
	return (
		tilemap.get_cell_atlas_coords(layer, tile_coords) in stone_to_grass_mapping 
		and tilemap.get_cell_source_id(layer, tile_coords) == 0
	)


func is_grass_tile(tile_coords: Vector2i) -> bool:
	var layer := get_first_layer_with_tile(tile_coords)
	if layer == -1:
		return false
	return (
		tilemap.get_cell_atlas_coords(layer, tile_coords) in grass_to_stone_mapping 
		and tilemap.get_cell_source_id(layer, tile_coords) == 0
	)


func find_closest_grass(goat: Goat) -> Vector2i:
	var current_tile := tilemap.local_to_map(goat.position)
	for radius in range(15):
		for x in range(current_tile.x - radius, current_tile.x + radius + 1):
			if is_grass_tile(Vector2i(x, current_tile.y - radius)):
				return Vector2i(x, current_tile.y - radius)
			if is_grass_tile(Vector2i(x, current_tile.y + radius)):
				return Vector2i(x, current_tile.y + radius)
		for y in range(current_tile.y - radius, current_tile.y + radius + 1):
			if is_grass_tile(Vector2i(current_tile.x - radius, y)):
				return Vector2i(current_tile.x - radius, y)
			if is_grass_tile(Vector2i(current_tile.x + radius, y)):
				return Vector2i(current_tile.x + radius, y)
	return current_tile


func find_random_idle_path(goat: Goat) -> Goat.GoatPathToGrass:
	var goat_position := tilemap.local_to_map(goat.position)
	var result := Goat.GoatPathToGrass.new()
	if is_cliff_tile(goat_position):
		var end_position := goat_position + Vector2i.UP
		while is_cliff_tile(end_position):
			result.movements.append(Goat.GoatJump.new(
				tilemap.map_to_local(goat_position),
				tilemap.map_to_local(end_position)
			))
			end_position += Vector2i.UP
		result.movements.append(Goat.GoatJump.new(
			tilemap.map_to_local(goat_position),
			tilemap.map_to_local(end_position)
		))
		return result
	var possible_directions: Array[Vector2i]
	for direction in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		if is_grass_tile(goat_position + direction) or is_stone_tile(goat_position + direction):
			possible_directions.append(goat_position + direction)
	randomize()
	if len(possible_directions) == 0:
		possible_directions = [goat_position]
	result.movements.append(Goat.GoatRun.new(
		tilemap.map_to_local(goat_position),
		tilemap.map_to_local(possible_directions.pick_random())
	))
	return result


func find_path_to_grass(goat: Goat) -> Goat.GoatPathToGrass:
	var closest_grass := find_closest_grass(goat)
	if not is_grass_tile(closest_grass):
		return null
	
	var result := Goat.GoatPathToGrass.new()
	
	var start_position := tilemap.local_to_map(goat.position)
	
	randomize()
	var possible_axis := [Vector2i.AXIS_X, Vector2i.AXIS_Y]
	while start_position != closest_grass:
		var axis = possible_axis.pick_random()
		if start_position.x == closest_grass.x:
			axis = Vector2i.AXIS_Y
		elif start_position.y == closest_grass.y:
			axis = Vector2i.AXIS_X
		
		var step_length := randi_range(1, 4)
		var end_position := start_position
		
		if axis == Vector2i.AXIS_X:
			step_length = mini(step_length, absi(start_position.x - closest_grass.x))
			var x_sign := signi(closest_grass.x - start_position.x)
			var x_delta := x_sign
			if is_cliff_tile((start_position + Vector2i(x_sign, 0))):
				while absi(x_delta) < step_length and is_cliff_tile((start_position + Vector2i(x_delta, 0))):
					x_delta += x_sign
				end_position.x += x_delta
				result.movements.append(Goat.GoatJump.new(
					tilemap.map_to_local(start_position),
					tilemap.map_to_local(end_position),
				))
			else:
				while absi(x_delta) < step_length and (
					is_grass_tile((start_position + Vector2i(x_delta, 0))) or is_stone_tile((start_position + Vector2i(x_delta, 0)))
				):
					x_delta += x_sign
				end_position.x += x_delta
				result.movements.append(Goat.GoatRun.new(
					tilemap.map_to_local(start_position),
					tilemap.map_to_local(end_position),
				))
					
		elif axis == Vector2i.AXIS_Y:
			step_length = mini(step_length, absi(start_position.y - closest_grass.y))
			var y_sign := signi(closest_grass.y - start_position.y)
			var y_delta := y_sign
			if is_cliff_tile((start_position + Vector2i(0, y_sign))):
				while absi(y_delta) < step_length and is_cliff_tile((start_position + Vector2i(0, y_delta))):
					y_delta += y_sign
				end_position.y += y_delta
				result.movements.append(Goat.GoatJump.new(
					tilemap.map_to_local(start_position),
					tilemap.map_to_local(end_position),
				))
			else:
				while absi(y_delta) < step_length and (
					is_grass_tile((start_position + Vector2i(0, y_delta))) or is_stone_tile((start_position + Vector2i(0, y_delta)))
				):
					y_delta += y_sign
				end_position.y += y_delta
				result.movements.append(Goat.GoatRun.new(
					tilemap.map_to_local(start_position),
					tilemap.map_to_local(end_position),
				))
		start_position = end_position
	return result


func eat_grass(goat: Goat) -> void:
	var grass_position := tilemap.local_to_map(goat.position)
	var layer := get_first_layer_with_tile(grass_position)
	var grass_tile := tilemap.get_cell_atlas_coords(layer, grass_position)
	if grass_tile in grass_to_stone_mapping:
		tilemap.set_cell(layer, grass_position, 0, grass_to_stone_mapping[grass_tile])


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			var clicked_tile := tilemap.local_to_map(get_local_mouse_position())
			if is_stone_tile(clicked_tile):
				var layer := get_first_layer_with_tile(clicked_tile)
				var stone_tile := tilemap.get_cell_atlas_coords(layer, clicked_tile)
				tilemap.set_cell(layer, clicked_tile, 0, stone_to_grass_mapping[stone_tile])
