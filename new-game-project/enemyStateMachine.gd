extends CharacterBody2D

@export var speed = 600
@export var avg_jump = -900
@export var jump = 0
@export var max_jump = -100
@export var gravity = 4000
@onready var anim = $AnimationPlayer
@onready var pike_sprite = $Pike/Sprite2D
@onready var sprite = $Sprite
@onready var mat = sprite.material
@onready var rightBound = $RightBound
@onready var leftBound = $LeftBound

var player_position: Vector2 = Vector2.ZERO

var flash_timer := 0.0
const FLASH_DURATION := 0.5

func _process(delta):
	if flash_timer > 0.0:
		flash_timer -= delta
		mat.set_shader_parameter("flash_amount", flash_timer / FLASH_DURATION)
	else:
		mat.set_shader_parameter("flash_amount", 0.0)

func take_damage():
	# your damage logic
	flash_timer = FLASH_DURATION

func _physics_process(delta):
	velocity.y += gravity * delta
	
	var playerDist = player_position.distance_to(position)
	var direction = Vector2()
	if playerDist > 1000:
		anim.play("run")
		var leftOrRight = randi_range(0, 1)
		var timer = randf_range(5, 10)
		if timer > 0:
			if not rightBound.is_colliding():
				leftOrRight = 0
			elif not leftBound.is_colliding():
				leftOrRight = 1
			if leftOrRight == 0:
				sprite.flip_h = true
				pike_sprite.flip_h = true
				velocity.x = -1 * speed
			else:
				sprite.flip_h = false
				pike_sprite.flip_h = false
				velocity.x = speed
			timer -= delta
	elif playerDist > 300:
		anim.play("run")
		if player_position.x < position.x:
			sprite.flip_h = true
			pike_sprite.flip_h = true
			velocity.x = -1 * speed
		else:
			sprite.flip_h = false
			pike_sprite.flip_h = false
			velocity.x = speed
		if !rightBound.is_colliding():
			sprite.flip_h = true
			pike_sprite.flip_h = true
			velocity.x = -1 * speed
		elif !leftBound.is_colliding():
			sprite.flip_h = false
			pike_sprite.flip_h = false
			velocity.x = speed
	else:
		if player_position.x < position.x:
			sprite.flip_h = true
			pike_sprite.flip_h = true
			anim.play("attack_left")
		else:
			sprite.flip_h = false
			pike_sprite.flip_h = false
			anim.play("attack_righdt")
	move_and_slide()


func _on_player_body_position_updated(new_position: Vector2) -> void:
	player_position = new_position
