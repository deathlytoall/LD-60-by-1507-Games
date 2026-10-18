@tool
class_name BaseRoom
extends TileMapLayer

## Must be a unique name to avoid collisions
@export var room_name: StringName = ""

@export var close_door_top: bool = false
@export var close_door_bottom: bool = false
@export var close_door_left: bool = false
@export var close_door_right: bool = false
@export var enemies_to_kill: int = 0
@onready var layer_2 = $Layer2

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

@export var dimensions := Vector2.ONE :
	set(v):
		dimensions = v
		if Engine.is_editor_hint():
			clear()
			generate_room()

## Size of a 1x1 room
const ROOM_SIZE = Vector2(16, 16)

func generate_room() -> void:
	print(1)
	var room_size := ROOM_SIZE * dimensions
	
	# Generate Floor
	for x in range(1, room_size.x):
		for y in range(1, room_size.y):
			set_cell(Vector2i(x, y), floor_id, Vector2i.ZERO)
	
	# Generate Vertical Walls
	for y in range(0, room_size.y + 1):
		set_cell(Vector2i(0, y), floor_id, Vector2i.ZERO)
		set_cell(Vector2i(room_size.x, y), floor_id, Vector2i.ZERO)
		layer_2.set_cell(Vector2i(0, y), 11, Vector2i.ZERO)
		layer_2.set_cell(Vector2i(room_size.x, y), 12, Vector2i.ZERO)
	
	# Generate Horizontal Walls
	for x in range(0, room_size.x):
		set_cell(Vector2i(x, 0), 5, Vector2i.ZERO)
		set_cell(Vector2i(x, room_size.y), floor_id, Vector2i.ZERO)
		layer_2.set_cell(Vector2i(x, 0), 5, Vector2i.ZERO)
		layer_2.set_cell(Vector2i(x, room_size.y), 16, Vector2i.ZERO)
	set_cell(Vector2i(0, 0), 9, Vector2i.ZERO)
	set_cell(Vector2i(room_size.x, 0), 19, Vector2i.ZERO)
	set_cell(Vector2i(0, room_size.y), floor_id, Vector2i.ZERO)
	set_cell(Vector2i(room_size.x, room_size.y), floor_id, Vector2i.ZERO)
	layer_2.set_cell(Vector2i(0, 0), 9, Vector2i.ZERO)
	layer_2.set_cell(Vector2i(room_size.x, 0), 19, Vector2i.ZERO)
	layer_2.set_cell(Vector2i(0, room_size.y), 17, Vector2i.ZERO)
	layer_2.set_cell(Vector2i(room_size.x, room_size.y), 18, Vector2i.ZERO)

	open_doors()

func generate_item() -> void:
	var item = preload("res://Items/item.tscn")
	var item_clone = item.instantiate()
	get_tree().root.add_child(item_clone)
	item_clone.global_position = Vector2(global_position.x + randi_range(30,200), global_position.y + randi_range(30,200))


func spawn_enemies(amount: int) -> void:
	enemies_to_kill = amount
	var enemy_clone
	for x in range(0, amount):
		var enemy = preload("res://Enemies/enemy_base.tscn")
		enemy_clone = enemy.instantiate()
		add_child(enemy_clone, true)
		enemy_clone.global_position = Vector2(global_position.x + randi_range(30,200), global_position.y + randi_range(30,200))
		

func open_doors() -> void:
	var room_size := ROOM_SIZE * dimensions
	
	if not close_door_top:
		for i in range(0, dimensions.x):
			@warning_ignore("integer_division")
			var x_offset: int = ROOM_SIZE.x / 2 + ROOM_SIZE.x * i + i
			set_cell(Vector2i(x_offset, 0), floor_id, Vector2i.ZERO)
			layer_2.set_cell(Vector2i(x_offset, 0), 10, Vector2i.ZERO)

	if not close_door_bottom:
		for i in range(0, round(dimensions.x)):
			@warning_ignore("integer_division")
			var x_offset: int = ROOM_SIZE.x / 2 + ROOM_SIZE.x * i + i
			set_cell(Vector2i(x_offset, room_size.y), floor_id, Vector2i.ZERO)
			layer_2.set_cell(Vector2i(x_offset, room_size.y), 26, Vector2i.ZERO)
	
	if not close_door_left:
		for i in range(0, dimensions.y):
			@warning_ignore("integer_division")
			var y_offset: int = ROOM_SIZE.y / 2 + ROOM_SIZE.y * i + i
			layer_2.set_cell(Vector2i(0, y_offset), floor_id, Vector2i.ZERO)
	
	if not close_door_right:
		for i in range(0, dimensions.y):
			@warning_ignore("integer_division")
			var y_offset: int = ROOM_SIZE.y / 2 + ROOM_SIZE.y * i + i
			layer_2.set_cell(Vector2i(room_size.x, y_offset), floor_id, Vector2i.ZERO)

func close_doors() -> void:
	var room_size := ROOM_SIZE * dimensions
	
	if not close_door_top:
		for i in range(0, dimensions.x):
			@warning_ignore("integer_division")
			var x_offset: int = ROOM_SIZE.x / 2 + ROOM_SIZE.x * i
			layer_2.set_cell(Vector2i(x_offset, 0), 6, Vector2i.ZERO)

	if not close_door_bottom:
		for i in range(0, dimensions.x):
			@warning_ignore("integer_division")
			var x_offset: int = ROOM_SIZE.x / 2 + ROOM_SIZE.x * i
			layer_2.set_cell(Vector2i(x_offset, room_size.y), 25, Vector2i.ZERO)
	
	if not close_door_left:
		for i in range(0, dimensions.y):
			@warning_ignore("integer_division")
			var y_offset: int = ROOM_SIZE.y / 2 + ROOM_SIZE.y * i
			layer_2.set_cell(Vector2i(0, y_offset), 8, Vector2i.ZERO)
	
	if not close_door_right:
		for i in range(0, dimensions.y):
			@warning_ignore("integer_division")
			var y_offset: int = ROOM_SIZE.y / 2 + ROOM_SIZE.y * i
			layer_2.set_cell(Vector2i(room_size.x, y_offset), 15, Vector2i.ZERO)
