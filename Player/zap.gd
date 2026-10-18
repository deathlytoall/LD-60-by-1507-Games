extends Area2D

var damage = 3
var speed = 10
var items = Global.items
var peirces = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var rad = rotation
	position += Vector2(cos(rad) * speed, sin(rad) * speed)



func _on_area_entered(area):
	if area.name == "EnemyBase":
		area.take_damage(3)
		if not items.has(3) or peirces == 0:
			queue_free()
		else:
			peirces -= 1


func _on_timer_timeout():
	queue_free()


func _on_body_entered(body):
	if body is BaseRoom:
		queue_free()
