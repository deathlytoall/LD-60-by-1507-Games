class_name RoomCameraTrigger
extends Area2D

@export var immidiate_trigger: bool = false
var _camera: CustomCamera2D

func _ready() -> void:
	for child in get_children():
		if child is CustomCamera2D:
			_camera = child
	
	if _camera and false:
		_camera.limit_left += int(global_position.x)
		_camera.limit_right += int(global_position.x)
		_camera.limit_top += int(global_position.y)
		_camera.limit_bottom += int(global_position.y)

func _on_body_entered(body: Node2D) -> void:
	if body is Player and _camera and false:
		_camera.player = body
		_camera.make_current()
