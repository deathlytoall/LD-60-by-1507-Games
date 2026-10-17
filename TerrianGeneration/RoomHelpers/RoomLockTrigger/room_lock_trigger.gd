class_name RoomLockTrigger
extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		get_parent()._base_room.generate_doors(1)
		call_deferred("queue_free")
