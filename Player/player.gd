class_name Player
extends CharacterBody2D

@export var room_generator: RoomGenerator
var zap_base = preload("res://Player/zap.tscn")
var item = preload("res://Items/item.tscn")
var items = Global.items
var movespeed = 100
@onready var arm = $Arm
@onready var animated_sprite_2d = $AnimatedSprite2D
var health: float = 100.0
@onready var damage_timer = $"AnimatedSprite2D/Damage timer"
var single = 0
var mult = 1
var scaler = 1
var rate = 1.0

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

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
	$CanvasLayer/AnimatedSprite2D.frame = round((100.0 - health) / 20.0)

# movement
func move() -> void:
	var animation = 0
	velocity = Vector2(0,0)
	if Global.items.has(10):
		if Input.is_action_just_pressed("W") and single == 0:
			$"Dash Timer".start(.3)
			single = 1
		elif Input.is_action_just_pressed("W") and single == 1:
			$"Dash Timer".start(.1)
			single = 2
			mult = 5
		if Input.is_action_just_pressed("A") and single == 0:
			$"Dash Timer".start(.3)
			single = 1
		elif Input.is_action_just_pressed("A") and single == 1:
			$"Dash Timer".start(.1)
			single = 2
			mult = 5
		if Input.is_action_just_pressed("S") and single == 0:
			$"Dash Timer".start(.3)
			single = 1
		elif Input.is_action_just_pressed("S") and single == 1:
			$"Dash Timer".start(.1)
			single = 2
			mult = 5
		if Input.is_action_just_pressed("D") and single == 0:
			$"Dash Timer".start(.3)
			single = 1
		elif Input.is_action_just_pressed("D") and single == 1:
			$"Dash Timer".start(.1)
			single = 2
			mult = 5
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
	
	velocity = velocity.normalized() * movespeed * mult
	var frame = animated_sprite_2d.frame
	if animated_sprite_2d.frame == animation:
		animated_sprite_2d.pause()
	elif animation - frame < 8 and animation - frame > 0 or animation - frame < -8:
		animated_sprite_2d.play()
	else:
		animated_sprite_2d.play_backwards()
	
	if animated_sprite_2d.frame in [0, 1, 15]:
		$RightLight.hide()
		$LeftLight.hide()
		$FrontLight.show()
		$BackLight.hide()
	elif animated_sprite_2d.frame in [2, 3, 4, 5, 6]:
		$LeftLight.show()
		$RightLight.hide()
		$FrontLight.hide()
		$BackLight.hide()
	elif animated_sprite_2d.frame in [10, 11, 12, 13, 14]:
		$RightLight.show()
		$LeftLight.hide()
		$FrontLight.hide()
		$BackLight.hide()
	elif animated_sprite_2d.frame == 8:
		$RightLight.hide()
		$LeftLight.hide()
		$FrontLight.hide()
		$BackLight.show()
	else:
		$RightLight.hide()
		$LeftLight.hide()
		$FrontLight.hide()
		$BackLight.hide()
	
	move_and_slide()

# point at mouse
func point() -> void:
	arm.look_at(get_global_mouse_position())

# attack
func attack() -> void:
	
	if ($Arm/Temp.visible):
		$Arm/Temp.visible = false
	else:
		$Arm/Temp.visible = true

func ranged_attack() -> void:
	health -= .5
	
	if items.has(0):
		zap(randf_range(0, 1))
	if items.has(1):
		zap(0.01)
	if items.has(11):
		$"Burst Timer".start()
	if items.has(12):
		zap(.25)
		zap(.5)
		zap(.75)
	zap(0)
	

func zap(dir: float) -> void:
	var zap_child = zap_base.instantiate()
	get_tree().root.add_child(zap_child)
	zap_child.scale = scale * scaler
	zap_child.position = position
	zap_child.look_at(get_global_mouse_position())
	zap_child.rotation += deg_to_rad(360 * dir)

func take_damage(damage: float) -> void:
	if damage_timer.is_stopped():
		audio_stream_player.pitch_scale = randf_range(0.8, 1)
		audio_stream_player.play()
		health -= damage
		var prev_frame = animated_sprite_2d.frame
		animated_sprite_2d.animation = "damage"
		animated_sprite_2d.frame = prev_frame
		damage_timer.start(.5)

func _on_pick_up(_item):
	var prev_frame = animated_sprite_2d.frame
	animated_sprite_2d.animation = "item"
	animated_sprite_2d.frame = prev_frame
	$"AnimatedSprite2D/Item Timer".start(1)
	if _item == -1:
		health += 5
		if health > 100:
			health = 100
	elif _item == 5:
		Global.damage += 2
	elif _item == 6:
		Global.damage += 1.5
	elif _item == 7:
		Global.damage += 1
	elif _item == 9:
		movespeed *= 1.5
	elif _item == 13:
		scaler += 1
	elif _item == 14:
		rate = .5

func _on_damage_timer_timeout():
	var prev_frame = animated_sprite_2d.frame
	animated_sprite_2d.animation = "default"
	animated_sprite_2d.frame = prev_frame

func _on_timer_timeout():
	health -= .25 * rate

func _on_dash_timer_timeout():
	if single == 1:
		single = 0
	elif single == 2:
		$"Dash Timer".start(2)
		single = 3
		mult = 1
	elif single == 3:
		single = 0

func _on_burst_timer_timeout():
	zap(0)


func _on_item_timer_timeout():
	var prev_frame = animated_sprite_2d.frame
	animated_sprite_2d.animation = "default"
	animated_sprite_2d.frame = prev_frame
