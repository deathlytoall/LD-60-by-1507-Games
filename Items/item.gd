extends Area2D

var item_type = randi_range(0, 4)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if not Global.items.has(item_type):
		Global.items.append(item_type)
	queue_free()
