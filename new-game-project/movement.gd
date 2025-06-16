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

@onready var hitSFX = $HitSFX
@onready var hurtSFX = $HurtSFX
@onready var jumpSFX = $JumpSFX
@onready var parrySparkSFX = $ParrySparkSFX
@onready var slashSFX = $SlashSFX
@onready var parrySFX = $ParrySFX
@onready var walkSFX = $WalkSFX

var wsfxTimer = 0
var parryCount = 1

@onready var svAnim = get_parent().get_parent().get_parent().get_parent().get_node("AnimationPlayer")

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
		svAnim.play("visible")
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
		if not walkSFX.playing and wsfxTimer <= 0:
			wsfxTimer = randf_range(0.5, 0.7)
			walkSFX.pitch_scale = randf_range(0.3, 1.7)
			walkSFX.play(0.0)
		else:
			wsfxTimer -= delta
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
		if attack_anim.is_playing() == false:
			slashSFX.pitch_scale = randf_range(0.7, 1.3)
			slashSFX.play(0.0)
		if sprite.flip_h == true:
			attack_anim.play("attack_left")
		elif sprite.flip_h == false:
			attack_anim.play("attack_right")
	
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall() or coyoteTimer > 0):
		anim.play("jump")
		velocity.y = avg_jump
		jump_count = 1
		jump = max_jump
		jumpSFX.play(0.0)
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
		jumpSFX.play(0.0)
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
			if (((attack_anim.current_animation == "parry_right" or attack_anim.current_animation == "parry_left") and attack_anim.is_playing()) or parryTimer > 0) and parryCount > 0:
				parrySparkSFX.play(0.0)
				camAnim.play("parry")
				parry_anim.play("parry_spark")
				parryCount -= 1
				take_damage(0)
			else:
				hurtSFX.play(0.0)
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
		parryCount = 1
		if attack_anim.is_playing() == false:
			parrySFX.pitch_scale = randf_range(0.7, 1.3)
			parrySFX.play(0.0)
		if sprite.flip_h == true:
			attack_anim.play("parry_left")
		else:
			attack_anim.play("parry_right")
		parryTimer = 0.7
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	takeDmgTimer = 0
	takeDmg = true
	hitArea = area


func _on_hurtbox_area_exited(area: Area2D) -> void:
	takeDmg = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	if attack_anim.is_playing():
		hitSFX.play(0.0)
		camAnim.play("shake")
