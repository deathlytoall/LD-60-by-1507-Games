@tool
class_name BaseRoom
extends TileMapLayer

## Must be a unique name to avoid collisions
@export var room_name: StringName = ""

@export var door_top: bool = true
@export var door_bottom: bool = true
@export var door_left: bool = true
@export var door_right: bool = true

@export var floor_id: int = 0 :
	set(v):
		floor_id = v
		clear()
		_generate_room()

## max number of rooms of this type that can exist at a time. (-1 means infinite)
@export var max_existance_num: int = -1 :
	set(v):
		if room_name.is_empty():
			room_name = str(randi())
		max_existance_num = v

@export var room_size := Vector2i(16, 16) :
	set(v):
		clear()
		room_size = v.max(Vector2(1, 1))
		_generate_room()

func _ready() -> void:
	_generate_room()

func _generate_room() -> void:
	# Generate Floor
	for x in range(1, room_size.x):
		for y in range(1, room_size.y):
			set_cell(Vector2i(x, y), floor_id, Vector2i.ZERO)
	
	# Generate Vertical Walls
	for y in range(0, room_size.y):
		set_cell(Vector2i(0, y), 1, Vector2i.ZERO)
		set_cell(Vector2i(room_size.x, y), 1, Vector2i.ZERO)
	
	# Generate Horizontal Walls
	for x in range(0, room_size.x + 1):
		set_cell(Vector2i(x, 0), 1, Vector2i.ZERO)
		set_cell(Vector2i(x, room_size.y), 1, Vector2i.ZERO)
	
	if door_top:
		set_cell(Vector2i(int(room_size.x / 2), 0), floor_id, Vector2i.ZERO)
	
	if door_bottom:
		set_cell(Vector2i(int(room_size.x / 2), room_size.y), floor_id, Vector2i.ZERO)
	
	if door_left:
		set_cell(Vector2i(0, int(room_size.y / 2)), floor_id, Vector2i.ZERO)
	
	if door_right:
		set_cell(Vector2i(room_size.x, int(room_size.y / 2)), floor_id, Vector2i.ZERO)
