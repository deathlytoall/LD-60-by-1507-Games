@tool
class_name RoomGenerator
extends Node2D

@export_category("Map Data")
@export var map_seed: int = randi() :
	set(v):
		map_seed = v
		if Engine.is_editor_hint():
			generate()

@export var number_of_upgrade_rooms: int = 1000:
	set(v):
		number_of_upgrade_rooms = v
		if Engine.is_editor_hint():
			generate()

@export var map_size := Vector2i(10, 10) :
	set(v):
		map_size = v
		if Engine.is_editor_hint():
			generate()

@export var start_rooms: Array[PackedScene] :
	set(v):
		start_rooms = v
		if Engine.is_editor_hint():
			generate()

@export var boss_rooms: Array[PackedScene] :
	set(v):
		boss_rooms = v
		if Engine.is_editor_hint():
			generate()

@export var upgrade_rooms: Array[PackedScene] :
	set(v):
		upgrade_rooms = v
		if Engine.is_editor_hint():
			generate()

const ROOM_PATH := &"res://TerrianGeneration/Rooms/"

var one_by_one_rooms: Array[PackedScene] = []
var two_by_one_rooms: Array[PackedScene] = []
var one_by_two_rooms: Array[PackedScene] = []
var two_by_two_rooms: Array[PackedScene] = []

# Used to get tile map sizes for aligning rooms to grid
var _base_room_preload := load("res://TerrianGeneration/RoomHelpers/BaseRoom/base_room.tscn")
@onready var _base_room: BaseRoom = _base_room_preload.instantiate()

var _starting_room_center := Vector2.ZERO

enum CellState{
	None,
	OneByOne,
	TwoByOne,
	OneByTwo,
	TwoByTwo,
	StartingRoom,
	BossRoom,
	UpgradeRoom,
}


func get_starting_room_center() -> Vector2:
	return _starting_room_center

func generate() -> void:
	seed(map_seed)
	_load_all_room_data()
	
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
	
	for child in get_children():
		if child is RoomContainer:
			child.queue_free()
	
	# Get grid
	var grid_map: Array[CellState] = []
	grid_map.resize(map_size.x * map_size.y)
	grid_map.fill(CellState.OneByOne)
	
	if not start_rooms.is_empty():
		var rand_i := randi_range(0, grid_map.size() - 1)
		grid_map[rand_i] = CellState.StartingRoom
	
	if not boss_rooms.is_empty():
		var rand_i := randi_range(0, grid_map.size() - 1)
		var i: int = rand_i
		while not _place_two_by_two(grid_map, i):
			i = (i + 1) % grid_map.size()
		grid_map[i] = CellState.BossRoom
	
	if not upgrade_rooms.is_empty():
		for i in range(0, min(number_of_upgrade_rooms, upgrade_rooms.size())):
			var rand_i := randi_range(0, grid_map.size() - 1)
			while grid_map[rand_i] != CellState.OneByOne:
				rand_i = randi_range(0, grid_map.size() - 1)
			grid_map[rand_i] = CellState.UpgradeRoom
	
	for i in range(grid_map.size()):
		match randi_range(0, 3):
			0: _place_two_by_two(grid_map, i)
			1: _place_two_by_one(grid_map, i)
			2: _place_one_by_two(grid_map, i)
			_: pass
	
	_render_map(grid_map)

func _render_map(grid: Array[CellState]) -> void:
	var _upgrade_rooms := upgrade_rooms.duplicate_deep()
	
	for i in range(0, grid.size()):
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
			CellState.StartingRoom:
				node = start_rooms.pick_random().instantiate()
				dim = Vector2i.ONE
			CellState.BossRoom:
				node = boss_rooms.pick_random().instantiate()
				dim = Vector2i(2, 2)
			CellState.UpgradeRoom:
				var index := randi_range(0, _upgrade_rooms.size() - 1)
				var upgrade: PackedScene = _upgrade_rooms.pop_at(index)
				node = upgrade.instantiate()
				dim = Vector2i.ONE
		
		if grid[i] != CellState.None:
			var map_pos := _index_to_pos(i)
			print(map_pos)
			node.global_position = map_pos
			node.global_position.x *= BaseRoom.ROOM_SIZE.x
			node.global_position.y *= BaseRoom.ROOM_SIZE.y
			node.global_position += Vector2(map_pos)
			
			if grid[i] == CellState.StartingRoom:
				_starting_room_center = node.global_position
				_starting_room_center.x += BaseRoom.ROOM_SIZE.x * 0.5
				_starting_room_center.y += BaseRoom.ROOM_SIZE.y * 0.5
				_starting_room_center = _corrrect_scale(_starting_room_center)
			node.global_position = _corrrect_scale(node.global_position)
			
			node.close_door_left = node.close_door_left or (map_pos.x <= 0)
			node.close_door_right = node.close_door_right or (map_pos.x + dim.x >= map_size.x)
			node.close_door_top = node.close_door_top or (map_pos.y <= 0)
			node.close_door_bottom = node.close_door_bottom or (map_pos.y + dim.y >= map_size.y)
			
			
			add_child(node)

func _load_all_room_data() -> void:
	_load_room_data(one_by_one_rooms, "1x1Rooms")
	_load_room_data(one_by_two_rooms, "1x2Rooms")
	_load_room_data(two_by_one_rooms, "2x1Rooms")
	_load_room_data(two_by_two_rooms, "2x2Rooms")

func _load_room_data(dest: Array[PackedScene], root: String):
	dest.clear()
	var p := DirAccess.open(ROOM_PATH + "/" + root)
	for room_dir_name in p.get_directories():
		var room_dir := DirAccess.open(ROOM_PATH + "/" + root + "/" + room_dir_name)
		for f in room_dir.get_files():
			if f.begins_with("@r") and f.ends_with(".tscn"):
				dest.append(
					load(ROOM_PATH + "/" + root + "/" + room_dir_name + "/" + f)
				)

func _place_one_by_two(grid: Array[CellState], i: int) -> bool:
	# O
	# B
	var origin := _index_to_pos(i)
	var bottom_i := _pos_to_index(origin + Vector2i.DOWN)
	
	if not _is_vector_in_bounds_multiple(origin, origin + Vector2i.DOWN):
		return false
	
	if not _is_in_bounds_multiple(grid, i, bottom_i):
		return false
	
	if not _is_writable_multiple(grid, i, bottom_i):
		return false
	
	grid[i] = CellState.OneByTwo
	grid[bottom_i] = CellState.None
	
	return true

func _place_two_by_one(grid: Array[CellState], i: int) -> bool:
	# O R
	var origin := _index_to_pos(i)
	var right_i := _pos_to_index(origin + Vector2i.RIGHT)
	
	if not _is_vector_in_bounds_multiple(origin, origin + Vector2i.RIGHT):
		return false
	
	if not _is_in_bounds_multiple(grid, i, right_i):
		return false
	
	if not _is_writable_multiple(grid, i, right_i):
		return false
	
	grid[i] = CellState.TwoByOne
	grid[right_i] = CellState.None
	
	return true

func _place_two_by_two(grid: Array[CellState], i: int) -> bool:
	# O R
	# B D
	var origin := _index_to_pos(i)
	var right_i := _pos_to_index(origin + Vector2i.RIGHT)
	var bottom_i := _pos_to_index(origin + Vector2i.DOWN)
	var diagonal_i := _pos_to_index(origin + Vector2i(1, 1))
	
	if not _is_vector_in_bounds_multiple(origin, origin + Vector2i.RIGHT, origin + Vector2i.DOWN, origin + Vector2i(1, 1)):
		return false
	
	if not _is_in_bounds_multiple(grid, i, bottom_i, right_i, diagonal_i):
		return false
	
	if not _is_writable_multiple(grid, i, bottom_i, right_i, diagonal_i):
		return false
	
	grid[i] = CellState.TwoByTwo
	grid[bottom_i] = CellState.None
	grid[right_i] = CellState.None
	grid[diagonal_i] = CellState.None
	
	return true

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
	if not _base_room:
		_base_room = _base_room_preload.instantiate()
	return _base_room.to_global(_base_room.map_to_local(v))
