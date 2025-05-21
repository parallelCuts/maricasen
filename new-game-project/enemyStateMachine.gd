extends CharacterBody2D

@export var speed = 300
@export var avg_jump = -900
@export var jump = 0
@export var max_jump = -100
@export var gravity = 4000
@onready var anim = $AnimationPlayer
@onready var pike_anim = $Pike/AnimationPlayer
@onready var pike_sprite = $Pike/Sprite2D
@onready var sprite = $Sprite
@onready var mat = sprite.material
@onready var rightBound = $RightBound
@onready var leftBound = $LeftBound

var player_position: Vector2 = Vector2.ZERO

var flash_timer := 0.0
const FLASH_DURATION := 0.5

var leftOrRight = randi_range(0, 1)
var timer = randf_range(2, 5)

var attackTimer = 0;

var playerInVision = false
var dealDmg = false
var dealDmgTimer = 0;

var health = 30

signal damage(damage: int)

func _process(delta):
	if flash_timer > 0.0:
		flash_timer -= delta
		mat.set_shader_parameter("flash_amount", flash_timer / FLASH_DURATION)
	else:
		mat.set_shader_parameter("flash_amount", 0.0)

func take_damage(damage):
	# your damage logic
	flash_timer = FLASH_DURATION
	health -= damage

func _physics_process(delta):
	velocity.y += gravity * delta
	
	if health <= 0:
		queue_free()
	
	if dealDmg == true:
		if dealDmgTimer == 0:
			emit_signal("damage", 10)
			dealDmgTimer = 0.5
		else:
			dealDmgTimer -= delta
	
	var playerDist = player_position.distance_to(position)
	var direction = Vector2()
	if playerDist > 300 and playerInVision == true:
		anim.play("run")
		if player_position.x < position.x:
			print(player_position.x)
			print(position.x)
			if !leftBound.is_colliding():
				anim.play("idle")
				velocity.x = 0
			else:
				velocity.x = -1 * speed
			sprite.flip_h = true
			pike_sprite.flip_h = true
		else:
			if !rightBound.is_colliding():
				anim.play("idle")
				velocity.x = 0
			else:
				velocity.x = speed
			sprite.flip_h = false
			pike_sprite.flip_h = false
	elif playerDist > 300:
		print("wandering")	
		anim.play("run")
		if timer > 0:
			if !rightBound.is_colliding():
				leftOrRight = 0
			elif !leftBound.is_colliding():
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
		else:
			leftOrRight = randi_range(0, 1)
			timer = randf_range(2, 5)
	else:
		if attackTimer > 0:
			attackTimer -= delta
		else:
			velocity.x = 0
			if player_position.x < position.x:
				sprite.flip_h = true
				pike_sprite.flip_h = true
				pike_anim.play("attack_left")
			else:
				sprite.flip_h = false
				pike_sprite.flip_h = false
				pike_anim.play("attack_right")
			attackTimer = 2
	move_and_slide()


func _on_player_body_position_updated(new_position: Vector2) -> void:
	player_position = new_position


func _on_vision_body_entered(body: Node2D) -> void:
	playerInVision = true

func _on_vision_body_exited(body: Node2D) -> void:
	playerInVision = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	dealDmg = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	dealDmgTimer = 0
	dealDmg = false
	
func _on_player_body_damage(dmg: int) -> void:
	take_damage(dmg)
