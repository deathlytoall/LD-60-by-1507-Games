extends Area2D

var item_type = randi_range(0, 15)
var collected = false
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$AnimatedSprite2D.frame = item_type + 1
	if collected:
		if player.animated_sprite_2d.frame < 3 or player.animated_sprite_2d.frame > 13:
			visible = true
		else:
			visible = false
		global_position = player.global_position - Vector2(1, 1)
		scale = Vector2(.2, .2)


func _on_body_entered(_body):
	if _body is Player:
		if not Global.items.has(item_type) and item_type != -1:
			Global.items.append(item_type)
			Global.emit_signal("pick_up", item_type)
		else:
			Global.emit_signal("pick_up", -1)
		$"Collect Timer".start()
		player = _body
		collected = true



func _on_collect_timer_timeout():
	queue_free()
