extends CharacterBody2D

var movespeed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move()
	if Input.is_action_just_pressed("Space"):
		attack()

# movement
func move():
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

# attack
func attack():
	pass
