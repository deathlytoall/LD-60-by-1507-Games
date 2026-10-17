extends Camera2D

@onready var player = $"../Player"


var speed = 10


func _physics_process(delta):
	position = lerp(position, player.position, speed * delta)
