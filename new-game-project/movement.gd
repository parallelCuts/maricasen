extends CharacterBody2D

@export var speed = 1200
@export var avg_jump = -900
@export var jump = 0
@export var max_jump = -100
@export var gravity = 4000
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite
@onready var mat = sprite.material
@onready var attack_anim = $Attack/AnimationPlayer

var flash_timer := 0.0
const FLASH_DURATION := 0.5
var invisible = false

var coyoteTimer := 0.0
const coyoteTime := 0.15

var jump_count = 0
const maxJumps = 2

signal position_updated(new_position: Vector2)
signal damage(damage: int)

@export var health = 50

@export var attackTimer = 0
@export var attackKnockback = 0
var attackKnockbackTimer = 3
var attackKnockbackDirection = 1

var wallJumpTimer = 0
var wallJumpForce = 0

var dealDmg = false

func _process(delta):
	if flash_timer > 0.0:
		flash_timer -= delta
		mat.set_shader_parameter("flash_amount", flash_timer / FLASH_DURATION)
		invisible = true
	else:
		mat.set_shader_parameter("flash_amount", 0.0)
		invisible = false

func take_damage(damage):
	# your damage logic
	flash_timer = FLASH_DURATION
	health -= damage

func _physics_process(delta):
	if health <= 0:
		queue_free()
		get_tree().paused = true
	# Add gravity every frame
	emit_signal("position_updated", global_position)
	velocity.y += gravity * delta
	# Input affects x axis only
	velocity.x = Input.get_axis("left", "right") * speed
	if velocity.x < 0:
		sprite.flip_h = true
	elif velocity.x > 0:
		sprite.flip_h = false
	if velocity.x != 0 and is_on_floor():
		anim.play("run")
	elif is_on_floor():
		anim.play("idle")
	if !is_on_floor() and coyoteTimer == 0:
		coyoteTimer = coyoteTime
	elif !is_on_floor():
		coyoteTimer -= delta
	if is_on_floor():
		coyoteTimer = 0
		jump_count = 0
	
	if Input.is_action_just_pressed("attack"):
		if sprite.flip_h == true:
			attack_anim.play("attack_left")
			if dealDmg == true:
				emit_signal("damage", 10)
				attackKnockbackDirection = 1
				attackKnockback = 500
				attackKnockbackTimer = 0.2
		elif sprite.flip_h == false:
			attack_anim.play("attack_right")
			if dealDmg == true:
				emit_signal("damage", 10)
				attackKnockbackDirection = -1
				attackKnockback = 500
				attackKnockbackTimer = 0.2
	if attackKnockbackTimer > 0 and attackKnockback > 0:
		velocity.x += attackKnockback * attackKnockbackDirection
		attackKnockback -= 5
		attackKnockbackTimer -= delta
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall() or coyoteTimer > 0):
		anim.play("jump")
		velocity.y = avg_jump
		jump_count += 1
		jump = max_jump
		if is_on_wall() and Input.is_action_pressed("left"):
			wallJumpTimer = 0.2
			wallJumpForce = 1000
		elif is_on_wall() and Input.is_action_pressed("right"):
			wallJumpTimer = 2
			wallJumpForce = -1000
	elif Input.is_action_just_pressed("jump") and jump_count < maxJumps:
		anim.play("jump")
		velocity.y = avg_jump
		jump_count += 2
		jump = max_jump
	if Input.is_action_pressed("jump") and jump < 0:
		velocity.y += jump;
		jump += 10;
	if wallJumpForce != 0 and wallJumpTimer > 0:
		wallJumpTimer -= delta
		velocity.x += wallJumpForce
		if wallJumpForce > 0:
			wallJumpForce -= 10
		else:
			wallJumpForce += 10
	move_and_slide()


func _on_stickler_damage(dmg: int) -> void:
	take_damage(dmg)


func _on_hitbox_body_entered(body: Node2D) -> void:
	dealDmg = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	dealDmg = false
