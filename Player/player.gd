extends CharacterBody2D

var movespeed = 500
@onready var arm = $Arm
var zap = preload("res://Player/zap.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	move()
	point()
	if Input.is_action_just_pressed("Mouse_Left"):
		melee_attack()
	elif Input.is_action_just_pressed("Mouse_Right"):
		ranged_attack()

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

# melee attack
func melee_attack() -> void:
	if ($Arm/Temp.visible):
		$Arm/Temp.visible = false
	else:
		$Arm/Temp.visible = true

# ranged attack
func ranged_attack() -> void:
	var zap_child = zap.instantiate()
	get_tree().root.add_child(zap_child)
	zap_child.position = position
	zap_child.look_at(get_global_mouse_position())
	
