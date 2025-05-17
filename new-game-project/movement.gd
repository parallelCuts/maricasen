extends CharacterBody2D

@export var speed = 1200
@export var avg_jump = -900
@export var jump = 0
@export var max_jump = -100
@export var gravity = 4000
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite

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
	if Input.is_action_just_pressed("jump") and is_on_floor():
		anim.play("jump")
		velocity.y = avg_jump
		jump = 0
	if Input.is_action_pressed("jump") and anim.current_animation == "jump" and jump > max_jump:
		velocity.y -= 50;
		jump -= 5;
	move_and_slide()
