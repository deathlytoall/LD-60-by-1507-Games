class_name Boss
extends CharacterBody2D

@export var health: float = 500 :
	set(v):
		health = v
		if health <= 0:
			call_deferred("queue_free")

@export var bounds: Rect2 = Rect2(Vector2(100, 100), Vector2(380, 380))

@onready var cooldown_timer: Timer = $CooldownTimer

var projectile_preload := preload("res://Boss/Projectile/projectile.tscn")
@onready var last_pos: Vector2 = position

func _ready() -> void:
	start()

func start() -> void:
	cooldown_timer.start(0)

func _process(_delta: float) -> void:
	$Sprite2D.flip_h = (position - last_pos).x < 0

func _tween_to_spot(pos: Vector2, duration: float) -> void:
	var t := create_tween()
	t.tween_property(self, "position", pos, duration
	).set_trans(Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN_OUT)

func _tween_jump(pos: Vector2, duration: float) -> void:
	var t := create_tween()
	
	var telegraph := position - (pos - position).normalized() * 10
	t.chain().tween_property(self, "position", telegraph, duration * 0.3
	).set_trans(Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN_OUT)
	
	t.chain().tween_property(self, "position", pos, duration * 0.7
	).set_trans(Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN_OUT)

func shoot(vel: Vector2) -> void:
	var t := create_tween()
	
	t.chain().tween_property(self, "scale:y", 0.8, 0.8
	).set_trans(Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN_OUT
	).finished.connect(
		func():
			var proj: BossProjectile = projectile_preload.instantiate()
			proj.velocity = vel
			proj.global_position = global_position
			get_tree().current_scene.add_child(proj)
	)
	
	t.chain().tween_property(self, "scale:y", 1, 0.1
	).set_trans(Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN_OUT)

func _on_cooldown_timer_timeout() -> void:
	match randi_range(0, 1):
		0: 
			_tween_jump(Vector2(
				randi_range(bounds.position.x, bounds.size.x), 
				randi_range(bounds.position.y, bounds.size.y)
			), 3)
			cooldown_timer.start(3)
		1:
			for x in range(-5, 5):
				for y in range(-5, 5):
					if x == 0 and y == 0:
						continue
					shoot(Vector2(x, y).normalized() * 100)
