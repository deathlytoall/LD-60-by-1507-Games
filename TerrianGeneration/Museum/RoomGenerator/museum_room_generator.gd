@tool
class_name MuseumRoomGenerator
extends Node2D

## The seed for room generation
@export var generator_seed: int = 1 :
	set(v):
		generator_seed = v
		seed(generator_seed)

@export var layout_size := Vector2i(10, 10) :
	set(v):
		layout_size = v
		if Engine.is_editor_hint():
			_clear_and_generate()

## The index of the starting room
@export var starting_room: int = 0 :
	set(v):
		starting_room = v
		if Engine.is_editor_hint():
			_clear_and_generate()

 ## Possible common rooms
@export var common_bag: Array[PackedScene] = [] :
	set(v):
		common_bag = v
		if Engine.is_editor_hint():
			_clear_and_generate()

# TODO: implement the rare bag (only checks common currently)
## Possible rare rooms
@export var rare_bag: Array[PackedScene] = [] :
	set(v):
		rare_bag = v
		if Engine.is_editor_hint():
			_clear_and_generate()

func _ready() -> void:
	print(common_bag)
	_generate()

func _clear_and_generate() -> void:
	for child in get_children():
		child.queue_free()
	_generate()

func _generate() -> void:
	for x in range(0, layout_size.x):
		for y in range(0, layout_size.y):
			var room: BaseRoom = common_bag.pick_random().instantiate()
			var room_size: Vector2 = room.to_global(room.map_to_local(room.room_size))
			room.global_position.x = x * room_size.x
			room.global_position.y = y * room_size.y
			add_child(room)
