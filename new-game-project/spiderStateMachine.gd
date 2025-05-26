extends CharacterBody2D

@export var gravity = 4000
var player_position: Vector2 = Vector2.ZERO

var flash_timer := 0.0
const FLASH_DURATION := 0.5

@onready var rightBound = $RightBound
@onready var leftBound = $LeftBound

@export var health = 50
@export var speed = 200
@export var jump = -2000

@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite

@export var projSpeed = 2000

var timer = 0
var attackTimer = 0

func _ready() -> void:
	$Sprite.material = $Sprite.material.duplicate()

func _process(delta):
	var mat = $Sprite.material
	if flash_timer > 0.0:
		flash_timer -= delta
		mat.set_shader_parameter("flash_amount", flash_timer / FLASH_DURATION)
	else:
		mat.set_shader_parameter("flash_amount", 0.0)

func take_damage(damage):
	# your damage logic
	flash_timer = FLASH_DURATION
	health -= damage

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	if health <= 0:
		queue_free()
	
	var playerDist = player_position.distance_to(global_position)
	var direction = Vector2()
	if playerDist > 700:
		var leftOrRight = randi_range(0, 1)
		if timer > 0:
			timer -= delta
			if is_on_floor():
				anim.play("run")
				if leftOrRight == 0:
					if !leftBound.is_colliding():
						anim.play("idle")
						velocity.x = 0
					else:
						velocity.x = -1 * speed
					sprite.flip_h = false
				else:
					if !rightBound.is_colliding():
						anim.play("idle")
						velocity.x = 0
					else:
						velocity.x = speed
					sprite.flip_h = true
		else:
			anim.play("jump")
			velocity.y += jump
			if randi_range(0, 1) == 0:
				velocity.x += speed * 2
			else:
				velocity.x -= speed * 2
			timer = randf_range(1, 3)
	elif playerDist > 200:
		if timer > 0:
			timer -= delta
			if is_on_floor():
				anim.play("run")
				if player_position.x < global_position.x:
					if !leftBound.is_colliding():
						anim.play("idle")
						velocity.x = 0
					else:
						velocity.x = -1 * speed
					sprite.flip_h = false
				else:
					if !rightBound.is_colliding():
						anim.play("idle")
						velocity.x = 0
					else:
						velocity.x = speed
					sprite.flip_h = true
		else:
			anim.play("jump")
			velocity.y += jump
			if randi_range(0, 1) == 0:
				velocity.x += speed * 2
			else:
				velocity.x -= speed * 2
			timer = randf_range(2, 5)
	else:
		if timer > 0:
			timer -= delta
		else:
			velocity.y += jump
			if randi_range(0, 1) == 0:
				velocity.x += speed * 2
			else:
				velocity.x -= speed * 2
			timer = randf_range(1, 2)
		if is_on_floor():
			anim.play("run")
		else:
			anim.play("jump")
	if playerDist < 800:
		if attackTimer > 0:
			attackTimer -= delta
		else:
			var a = preload("res://web.tscn").instantiate()
			a.global_position = global_position - Vector2(0, 500)
			a.velocity = (player_position - global_position).normalized() * projSpeed
			get_parent().add_child(a)
			attackTimer = 3
	
	move_and_slide()

func _on_player_body_position_updated(new_position: Vector2) -> void:
	player_position = new_position


func _on_hurtbox_area_entered(area: Area2D) -> void:
	take_damage(10)
