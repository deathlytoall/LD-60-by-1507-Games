class_name RoomLockTrigger
extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		get_parent()._base_room.close_doors()
		get_parent()._base_room.spawn_enemies(randi_range(1, 3))
		print(2)
		call_deferred("queue_free")
