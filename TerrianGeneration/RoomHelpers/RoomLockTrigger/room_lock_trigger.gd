class_name RoomLockTrigger
extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		call_deferred("queue_free")
