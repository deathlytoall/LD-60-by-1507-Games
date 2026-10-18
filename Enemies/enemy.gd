extends Area2D
class_name Enemy

@onready var animated_sprite_2d = $AnimatedSprite2D
var health = 10
var single = false
var player = null
var speed = 0.1
var rad: float
var velocity: Vector2
var back: = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var _type = randf_range(0, 10)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player is CharacterBody2D:
		rad = get_angle_to(player.global_position)
		velocity = Vector2(cos(rad) * speed, sin(rad) * speed) * back
		var animation = 0
		position += velocity
		velocity = velocity.round()
		if velocity == Vector2(0, 1):
			animation = 0
		elif velocity == Vector2(-1, 1):
			animation = 1
		elif velocity == Vector2(-1, 0):
			animation = 2
		elif velocity == Vector2(-1, -1):
			animation = 3
		elif velocity == Vector2(0, -1):
			animation = 4
		elif velocity == Vector2(1, -1):
			animation = 5
		elif velocity == Vector2(1, 0):
			animation = 6
		elif velocity == Vector2(1, 1):
			animation = 7
		var frame = animated_sprite_2d.frame
		if animated_sprite_2d.frame == animation:
			animated_sprite_2d.pause()
		elif animation - frame < 4 and animation - frame > 0 or animation - frame < -4:
			animated_sprite_2d.play()
		else:
			animated_sprite_2d.play_backwards()


func take_damage(damage):
	health -= damage
	if health <= 0 and not single:
		single = true
		var item = preload("res://Items/item.tscn")
		var item_clone = item.instantiate()
		if randf() > 0.7:
			get_tree().root.add_child.call_deferred(item_clone)
			item_clone.global_position = Vector2(global_position.x, global_position.y)
			item_clone.item_type = -1
		queue_free()
		#get_parent().enemies_to_kill -= 1
		#if get_parent().enemies_to_kill == 0:
			#get_parent().open_doors()
			#get_parent().generate_item()


func _on_player_detection_body_entered(body):
	if body is CharacterBody2D:
		player = body


func _on_body_entered(body):
	if body is Player:
		body.take_damage(5)
		back = -2

func _on_body_exited(body):
	back = 1
