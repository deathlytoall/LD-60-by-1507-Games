class_name Player
extends CharacterBody2D

@export var room_generator: RoomGenerator

var movespeed = 100
@onready var arm = $Arm

# Called when the node enters the scene tree for the first time.
func _ready():
	if room_generator:
		room_generator.generate()
		global_position = room_generator.get_starting_room_center() 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	move()
	point()
	if Input.is_action_just_pressed("Mouse_Left"):
		attack()

# movement
func move() -> void:
	velocity = Vector2(0,0)
	if Input.is_action_pressed("D"):
		velocity.x += 1
	if Input.is_action_pressed("A"):
		velocity.x -= 1
	if Input.is_action_pressed("W"):
		velocity.y -= 1
	if Input.is_action_pressed("S"):
		velocity.y += 1
	velocity = velocity.normalized() * movespeed
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
