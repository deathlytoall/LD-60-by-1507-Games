extends Area2D

@onready var color_rect = $ColorRect
var health = 10
var single = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var type = randf_range(0, 10)
	color_rect.color = Color(1,type/10.0,0,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func take_damage(damage):
	health -= damage
	if health <= 0 and not single:
		single = true
		queue_free()
		get_parent().generate_doors(0)
		get_parent().generate_item()
