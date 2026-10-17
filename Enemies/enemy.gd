extends Area2D

@onready var color_rect = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	var type = randf_range(0, 10)
	color_rect.color = Color(1,type/10.0,0,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
