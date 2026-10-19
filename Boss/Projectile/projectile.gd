class_name BossProjectile
extends CharacterBody2D

func _physics_process(_delta: float) -> void:
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(10)
		call_deferred("queue_free")
	elif body.name == "Layer2":
		call_deferred("queue_free")
