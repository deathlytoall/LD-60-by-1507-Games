@tool
class_name BaseRoomOld
extends TileMapLayer

## Must be a unique name to avoid collisions
@export var room_name: StringName = ""

@export var close_door_top: bool = false
@export var close_door_bottom: bool = false
@export var close_door_left: bool = false
@export var close_door_right: bool = false

@export var floor_id: int = 0 :
	set(v):
		floor_id = v
		if Engine.is_editor_hint():
			clear()
			generate_room()

## max number of rooms of this type that can exist at a time. (-1 means infinite)
@export var max_existance_num: int = -1 :
	set(v):
		if room_name.is_empty():
			room_name = str(randi())
		max_existance_num = v

@export var dimensions := Vector2i.ONE :
	set(v):
		dimensions = v
		if Engine.is_editor_hint():
			clear()
			generate_room()

## Size of a 1x1 room
const ROOM_SIZE = Vector2i(16, 16)

func generate_room() -> void:
	var room_size := ROOM_SIZE * dimensions
	
	# Generate Floor
	for x in range(1, room_size.x):
		for y in range(1, room_size.y):
			set_cell(Vector2i(x, y), floor_id, Vector2i.ZERO)
	
	# Generate Vertical Walls
	for y in range(0, room_size.y):
		set_cell(Vector2i(0, y), 0, Vector2i.ZERO)
		set_cell(Vector2i(room_size.x, y), 0, Vector2i.ZERO)
	
	# Generate Horizontal Walls
	for x in range(0, room_size.x + 1):
		set_cell(Vector2i(x, 0), 1, Vector2i.ZERO)
		set_cell(Vector2i(x, room_size.y), 1, Vector2i.ZERO)
	
	if not close_door_top:
		for i in range(0, dimensions.x):
			@warning_ignore("integer_division")
			var x_offset: int = ROOM_SIZE.x / 2 + ROOM_SIZE.x * i
			set_cell(Vector2i(x_offset, 0), floor_id, Vector2i.ZERO)

	if not close_door_bottom:
		for i in range(0, dimensions.x):
			@warning_ignore("integer_division")
			var x_offset: int = ROOM_SIZE.x / 2 + ROOM_SIZE.x * i
			set_cell(Vector2i(x_offset, room_size.y), floor_id, Vector2i.ZERO)
	
	if not close_door_left:
		for i in range(0, dimensions.y):
			@warning_ignore("integer_division")
			var y_offset: int = ROOM_SIZE.y / 2 + ROOM_SIZE.y * i
			set_cell(Vector2i(0, y_offset), floor_id, Vector2i.ZERO)
	
	if not close_door_right:
		for i in range(0, dimensions.y):
			@warning_ignore("integer_division")
			var y_offset: int = ROOM_SIZE.y / 2 + ROOM_SIZE.y * i
			set_cell(Vector2i(room_size.x, y_offset), floor_id, Vector2i.ZERO)
