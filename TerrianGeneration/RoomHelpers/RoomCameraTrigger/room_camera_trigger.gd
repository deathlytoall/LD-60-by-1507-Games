class_name RoomCameraTrigger
extends Area2D

@export var immidiate_trigger: bool = false
var _camera: Camera2D

func _ready() -> void:
	for child in get_children():
		if child is Camera2D:
			_camera = child

	if _camera:
		_camera.limit_left += int(global_position.x)
		_camera.limit_right += int(global_position.x)
		_camera.limit_top += int(global_position.y)
		_camera.limit_bottom += int(global_position.y)

func _on_body_entered(body: Node2D) -> void:
	if body is Player and _camera.is_current() == false:
		_camera.player = body
		_camera.global_position = body.global_position
		_camera.make_current()

func _on_body_exited(body):
	if body is Player and _camera.is_current() == true and immidiate_trigger:
		print(1)
		immidiate_trigger = true
		if body.get_children().has(Camera2D):
			body.Camera2D.make_current()
		
