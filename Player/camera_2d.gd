class_name CustomCamera2D
extends Camera2D

@export var player: Player

var speed: int = 5

func _process(delta: float) -> void:
	if is_current() and player:
		position = lerp(position, player.position, speed * delta)
