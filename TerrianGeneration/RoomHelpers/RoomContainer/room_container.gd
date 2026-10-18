@tool
class_name RoomContainer
extends Node2D

@export var close_door_top: bool = false
@export var close_door_bottom: bool = false
@export var close_door_left: bool = false
@export var close_door_right: bool = false

var _base_room: BaseRoom

func _ready() -> void:
	_init_base_room()

func _init_base_room() -> void:
	for child in get_children():
		if child is BaseRoom:
			_base_room = child
	
	if not _base_room:
		push_warning("No base room found!")
		return
	
	_base_room.close_door_top = close_door_top
	_base_room.close_door_bottom = close_door_bottom
	_base_room.close_door_left = close_door_left
	_base_room.close_door_right = close_door_right
	_base_room.generate_room()
