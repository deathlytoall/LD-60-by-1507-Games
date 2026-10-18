extends Area2D

@onready var color_rect = $ColorRect
var health = 10
var single = false
var player = null
var speed = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var type = randf_range(0, 10)
	color_rect.color = Color(1,type/10.0,0,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player is CharacterBody2D:
		var rad = get_angle_to(player.global_position)
		position += Vector2(cos(rad) * speed, sin(rad) * speed)

func take_damage(damage):
	health -= damage
	if health <= 0 and not single:
		single = true
		queue_free()
		get_parent().generate_doors(0)
		get_parent().generate_item()


func _on_player_detection_body_entered(body):
	if body is CharacterBody2D:
		player = body
