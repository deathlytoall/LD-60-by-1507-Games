class_name Player
extends CharacterBody2D

@export var room_generator: RoomGenerator
var zap_base = preload("res://Player/zap.tscn")
var item = preload("res://Items/item.tscn")
var items = Global.items
var movespeed = 100
@onready var arm = $Arm
@onready var animated_sprite_2d = $AnimatedSprite2D
var health = 100
@onready var damage_timer = $"AnimatedSprite2D/Damage timer"


func _ready():
	Global.pick_up.connect(_on_pick_up)
	if room_generator:
		room_generator.generate()
		global_position = room_generator.get_starting_room_center() 


func _process(_delta) -> void:
	move()
	point()
	if Input.is_action_just_pressed("Mouse_Left"):
		attack()
	if Input.is_action_just_pressed("Mouse_Right"):
		ranged_attack()

# movement
func move() -> void:
	var animation = 0
	velocity = Vector2(0,0)
	if Input.is_action_pressed("D"):
		velocity.x += 1
	if Input.is_action_pressed("A"):
		velocity.x -= 1
	if Input.is_action_pressed("W"):
		velocity.y -= 1
	if Input.is_action_pressed("S"):
		velocity.y += 1
	if velocity == Vector2(0, 1):
		animation = 0
	elif velocity == Vector2(-1, 1):
		animation = 2
	elif velocity == Vector2(-1, 0):
		animation = 4
	elif velocity == Vector2(-1, -1):
		animation = 6
	elif velocity == Vector2(0, -1):
		animation = 8
	elif velocity == Vector2(1, -1):
		animation = 10
	elif velocity == Vector2(1, 0):
		animation = 12
	elif velocity == Vector2(1, 1):
		animation = 14
	velocity = velocity.normalized() * movespeed
	var frame = animated_sprite_2d.frame
	if animated_sprite_2d.frame == animation:
		animated_sprite_2d.pause()
	elif animation - frame < 8 and animation - frame > 0 or animation - frame < -8:
		animated_sprite_2d.play()
	else:
		animated_sprite_2d.play_backwards()
	move_and_slide()

# point at mouse
func point() -> void:
	arm.look_at(get_global_mouse_position())

# attack
func attack() -> void:
	take_damage(1)
	if ($Arm/Temp.visible):
		$Arm/Temp.visible = false
	else:
		$Arm/Temp.visible = true

func ranged_attack() -> void:
	zap(0)
	if items.has(0):
		zap(randf_range(0, 1))
	if items.has(1):
		zap(0.01)

func zap(dir: float) -> void:
	var zap_child = zap_base.instantiate()
	get_tree().root.add_child(zap_child)
	zap_child.scale = scale
	zap_child.position = position
	zap_child.look_at(get_global_mouse_position())
	zap_child.rotation += deg_to_rad(360 * dir)

func take_damage(damage: int) -> void:
	health -= damage
	animated_sprite_2d.animation = "damage"
	damage_timer.start(.5)

func _on_pick_up(item):
	items.append(item)

func _on_damage_timer_timeout():
	animated_sprite_2d.animation = "default"
