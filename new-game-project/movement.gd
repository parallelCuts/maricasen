extends CharacterBody2D

@export var speed = 1200
@export var avg_jump = -900
@export var jump = 0
@export var max_jump = -100
@export var gravity = 4000
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite
@onready var mat = sprite.material

var flash_timer := 0.0
const FLASH_DURATION := 0.5
var invisible = false

var coyoteTimer := 0.0
const coyoteTime := 0.15

func _process(delta):
	if flash_timer > 0.0:
		flash_timer -= delta
		mat.set_shader_parameter("flash_amount", flash_timer / FLASH_DURATION)
		invisible = true
	else:
		mat.set_shader_parameter("flash_amount", 0.0)
		invisible = false

func take_damage():
	# your damage logic
	flash_timer = FLASH_DURATION

func _physics_process(delta):
	# Add gravity every frame
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
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyoteTimer > 0):
		anim.play("jump")
		velocity.y = avg_jump
		jump = max_jump
	if Input.is_action_pressed("jump") and anim.current_animation == "jump" and jump < 0:
		velocity.y += jump;
		jump += 10;
	move_and_slide()
