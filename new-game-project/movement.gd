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

@export var health = 0

@export var attackTimer = 0

var wallJumpTimer = 0
var wallJumpForce = 0

var dealDmg = false

var takeDmg = false;
var takeDmgTimer = 0
var hitArea = null

@onready var camAnim = $PlayerCamera/AnimationPlayer

var parryTimer = 0
@onready var parry_anim = $ParryAnimationPlayer

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
		elif sprite.flip_h == false:
			attack_anim.play("attack_right")
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall() or coyoteTimer > 0):
		anim.play("jump")
		velocity.y = avg_jump
		jump_count = 1
		jump = max_jump
		if is_on_wall() and Input.is_action_pressed("left"):
			wallJumpTimer = 0.2
			wallJumpForce = 1000
		elif is_on_wall() and Input.is_action_pressed("right"):
			wallJumpTimer = 0.2
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
	
	if takeDmg == true:
		if takeDmgTimer < 0:
			takeDmgTimer = 0.5
			if ((attack_anim.current_animation == "parry_right" or attack_anim.current_animation == "parry_left") and attack_anim.is_playing()) or parryTimer > 0:
				camAnim.play("parry")
				parry_anim.play("parry_spark")
				take_damage(0)
			else:
				camAnim.play("shake")
				take_damage(10)
				var particles = preload("res://particle.tscn").instantiate()
				particles.position = Vector2(50, 0)
				particles.one_shot = true
				if hitArea.global_position.x > global_position.x:
					particles.position = Vector2(-50, 0)
					particles.direction.x = -1
				add_child(particles)
		else:
			takeDmgTimer -= delta
	parryTimer -= delta
	if Input.is_action_just_pressed("parry"):
		if sprite.flip_h == true:
			attack_anim.play("parry_left")
		else:
			attack_anim.play("parry_right")
		parryTimer = 0.4
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	takeDmgTimer = 0
	takeDmg = true
	hitArea = area


func _on_hurtbox_area_exited(area: Area2D) -> void:
	takeDmg = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	if attack_anim.is_playing():
		camAnim.play("shake")
