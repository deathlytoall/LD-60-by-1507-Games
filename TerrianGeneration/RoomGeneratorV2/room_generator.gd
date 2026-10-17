class_name RoomGenerator
extends Node2D

@export_category("Map Data")
@export var map_seed: int = 1
@export var map_size := Vector2i(10, 10)

const ROOM_PATH := &"res://TerrianGeneration/Rooms/"

var one_by_one_rooms: Array[PackedScene] = []
var two_by_one_rooms: Array[PackedScene] = []
var one_by_two_rooms: Array[PackedScene] = []
var two_by_two_rooms: Array[PackedScene] = []

# Used to get tile map sizes for aligning rooms to grid
var _base_room_preload := preload("res://TerrianGeneration/Rooms/BaseRoom/base_room.tscn")
@onready var _base_room: BaseRoom = _base_room_preload.instantiate()

enum CellState{
	NONE,
	OneByOne,
	TwoByOne,
	OneByTwo,
	TwoByTwo,
}

func _ready() -> void:
	seed(map_seed)
	_load_all_room_data()
	generate()

func generate() -> void:
	if one_by_one_rooms.is_empty():
		push_warning("1x1 room array not filled!")
		return
	elif two_by_one_rooms.is_empty():
		push_warning("2x1 room array not filled!")
		return
	elif one_by_two_rooms.is_empty():
		push_warning("1x2 room array not filled!")
		return
	elif two_by_two_rooms.is_empty():
		push_warning("2x2 room array not filled")
		return
	
	
	# Get grid
	var grid_map: Array[CellState] = []
	grid_map.resize(map_size.x * map_size.y)
	grid_map.fill(CellState.OneByOne)
	
	for i in range(grid_map.size()):
		match randi_range(0, 3):
			0: _place_two_by_two(grid_map, i)
			1: _place_two_by_one(grid_map, i)
			2: _place_one_by_two(grid_map, i)
			_: pass
	
	_render_map(grid_map)

func _render_map(grid: Array[CellState]) -> void:
	var i: int = 0
	
	while i < grid.size():
		var node: RoomContainer
		var dim: Vector2i
		
		match grid[i]:
			CellState.OneByOne:
				node = one_by_one_rooms.pick_random().instantiate()
				dim = Vector2i.ONE
			CellState.TwoByTwo:
				node = two_by_two_rooms.pick_random().instantiate()
				dim = Vector2i(2, 2)
			CellState.TwoByOne:
				node = two_by_one_rooms.pick_random().instantiate()
				dim = Vector2i(2, 1)
			CellState.OneByTwo:
				node = one_by_two_rooms.pick_random().instantiate()
				dim = Vector2i(1, 2)
		
		if grid[i] != CellState.NONE:
			var map_pos := _index_to_pos(i)
			
			node.global_position = map_pos
			node.global_position.x *= BaseRoom.ROOM_SIZE.x
			node.global_position.y *= BaseRoom.ROOM_SIZE.y	
			node.global_position = _corrrect_scale(node.global_position)
			
			node.close_door_left = node.close_door_left or (map_pos.x <= 0)
			node.close_door_right = node.close_door_right or (map_pos.x + dim.x >= map_size.x - 1)
			node.close_door_top = node.close_door_top or (map_pos.y <= 0)
			node.close_door_bottom = node.close_door_bottom or (map_pos.y + dim.y >= map_size.y - 1)
			
			add_child(node)
			
		i += 1

func _load_all_room_data() -> void:
	_load_room_data(one_by_one_rooms, "1x1Rooms")
	_load_room_data(one_by_two_rooms, "1x2Rooms")
	_load_room_data(two_by_one_rooms, "2x1Rooms")
	_load_room_data(two_by_two_rooms, "2x2Rooms")

func _load_room_data(dest: Array[PackedScene], root: String):
	var p := DirAccess.open(ROOM_PATH + "/" + root)
	for room_dir_name in p.get_directories():
		var room_dir := DirAccess.open(ROOM_PATH + "/" + root + "/" + room_dir_name)
		for f in room_dir.get_files():
			if f.begins_with("@r") and f.ends_with(".tscn"):
				dest.append(
					load(ROOM_PATH + "/" + root + "/" + room_dir_name + "/" + f)
				)

func _place_one_by_two(grid: Array[CellState], i: int) -> void:
	# O
	# B
	var origin := _index_to_pos(i)
	var bottom_i := _pos_to_index(origin + Vector2i.DOWN)
	
	if not _is_vector_in_bounds_multiple(origin, origin + Vector2i.DOWN):
		return
	
	if not _is_in_bounds_multiple(grid, i, bottom_i):
		return
	
	if not _is_writable_multiple(grid, i, bottom_i):
		return
	
	grid[i] = CellState.OneByTwo
	grid[bottom_i] = CellState.NONE

func _place_two_by_one(grid: Array[CellState], i: int) -> void:
	# O R
	var origin := _index_to_pos(i)
	var right_i := _pos_to_index(origin + Vector2i.RIGHT)
	
	if not _is_vector_in_bounds_multiple(origin, origin + Vector2i.RIGHT):
		return
	
	if not _is_in_bounds_multiple(grid, i, right_i):
		return
	
	if not _is_writable_multiple(grid, i, right_i):
		return
	
	grid[i] = CellState.TwoByOne
	grid[right_i] = CellState.NONE

func _place_two_by_two(grid: Array[CellState], i: int) -> void:
	# O R
	# B D
	var origin := _index_to_pos(i)
	var right_i := _pos_to_index(origin + Vector2i.RIGHT)
	var bottom_i := _pos_to_index(origin + Vector2i.DOWN)
	var diagonal_i := _pos_to_index(origin + Vector2i(1, 1))
	
	if not _is_vector_in_bounds_multiple(origin, origin + Vector2i.RIGHT, origin + Vector2i.DOWN, origin + Vector2i(1, 1)):
		return
	
	if not _is_in_bounds_multiple(grid, i, bottom_i, right_i, diagonal_i):
		return
	
	if not _is_writable_multiple(grid, i, bottom_i, right_i, diagonal_i):
		return
	
	grid[i] = CellState.TwoByTwo
	grid[bottom_i] = CellState.NONE
	grid[right_i] = CellState.NONE
	grid[diagonal_i] = CellState.NONE

func _is_writable_multiple(arr: Array[CellState], ...i: Array) -> bool:
	for index in i:
		if not _is_writable(arr, index):
			return false
	return true

func _is_writable(arr: Array[CellState], i: int) -> bool:
	return arr[i] == CellState.OneByOne

func _is_in_bounds_multiple(arr: Array[CellState], ...i: Array) -> bool:
	for index in i:
		if not _is_in_bounds(arr, index):
			return false
	return true

func _is_in_bounds(arr: Array[CellState], i: int) -> bool:
	return i > 0 and i < arr.size()

func _is_vector_in_bounds_multiple(...pos: Array) -> bool:
	for p in pos:
		if not _is_vector_in_bounds(p):
			return false
	return true

func _is_vector_in_bounds(pos: Vector2) -> bool:
	return pos.x < map_size.x and pos.x > 0 and pos.y < map_size.y and pos.y > 0

func _pos_to_index(pos: Vector2i) -> int:
	return pos.x + pos.y * map_size.x

func _index_to_pos(i: int) -> Vector2i:
	@warning_ignore("integer_division")
	var y: int = i / map_size.x
	var x: int = i % map_size.y
	return Vector2i(x, y)

func _corrrect_scale(v: Vector2i) -> Vector2:
	return _base_room.to_global(_base_room.map_to_local(v))
