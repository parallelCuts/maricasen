extends CharacterBody2D

@onready var sprite = $Sprite
@onready var mat = sprite.material
@onready var anim = $AnimationPlayer

@export var health = 400

var flash_timer := 0.0
const FLASH_DURATION := 0.5

var player_position: Vector2 = Vector2.ZERO
var hurtTime = 0

var isDead = false

@export var speed = 100
var moveTimer = 0
var rng = 0
var inVision = false

var dropTimer = randf_range(0.5, 1.25)

@onready var vessels_anim = $Vessels/AnimationPlayer
@onready var blood_anim = $Blood/AnimationPlayer

@export var projSpeed = 1000

@onready var riseSFX = $RiseSFX
@onready var dropSFX = $DropSFX
@onready var vesselsSFX = $VesselsSFX
@onready var bloodSFX = $BloodSFX
@onready var svAnim = get_parent().get_parent().get_parent().get_parent().get_node("AnimationPlayer")

func _ready() -> void:
	sprite.material = sprite.material.duplicate()
	mat = sprite.material

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

func _physics_process(delta: float) -> void:
	if health <= 0:
		svAnim.play("visible")
		queue_free()
		isDead = true
	
	if not isDead:
		pass
		if health > 300:
			if inVision:
				if dropTimer <= 0:
					dropTimer = randf_range(0.2, 0.5)
					anim.play("drop")
				dropTimer -= delta
			elif moveTimer <= 0 and ((not anim.is_playing()) or anim.current_animation == "seek"):
				anim.play("seek")
				moveTimer = randf_range(1, 2)
				if player_position.x > global_position.x:
					velocity.x = speed
				else:
					velocity.x = -speed
			else:
				moveTimer -= delta
		elif health > 200:
			if inVision:
				if dropTimer <= 0:
					dropTimer = randf_range(0.2, 0.5)
					anim.play("drop")
				dropTimer -= delta
			elif moveTimer <= 0 and ((not anim.is_playing()) or anim.current_animation == "seek"):
				rng = randi_range(0, 6)
				anim.play("seek")
				moveTimer = randf_range(1, 2)
				if player_position.x > global_position.x:
					velocity.x = speed
					if rng == 0:
						vessels_anim.play("vessels_right")
						vesselsSFX.play(0.0)
				else:
					velocity.x = -speed
					if rng == 0:
						vessels_anim.play("vessels_left")
						vesselsSFX.play(0.0)
				if rng == 1:
					blood_anim.play("bloodwave")
					bloodSFX.play(0.0)
			else:
				moveTimer -= delta
		else:
			if inVision:
				if dropTimer <= 0:
					dropTimer = randf_range(0.2, 0.5)
					anim.play("drop")
				dropTimer -= delta
			elif moveTimer <= 0 and ((not anim.is_playing()) or anim.current_animation == "seek"):
				rng = randi_range(0, 1)
				anim.play("seek")
				moveTimer = randf_range(1, 2)
				if player_position.x > global_position.x:
					velocity.x = speed
					if rng == 0:
						vessels_anim.play("vessels_right")
						vesselsSFX.play(0.0)
				else:
					velocity.x = -speed
					if rng == 0:
						vessels_anim.play("vessels_left")
						vesselsSFX.play(0.0)
				if rng == 1:
					blood_anim.play("bloodwave")
					bloodSFX.play(0.0)
			else:
				moveTimer -= delta
		move_and_slide()

func _on_player_body_position_updated(new_position: Vector2) -> void:
	player_position = new_position

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if hurtTime <= 0:
		take_damage(10)
		var particles = preload("res://boss_particle.tscn").instantiate()
		particles.position = Vector2(5, 0)
		particles.one_shot = true
		if area.global_position.x > global_position.x:
			particles.position = Vector2(-5, 0)
			particles.direction.x = -1
		add_child(particles)


func _on_vision_body_entered(body: Node2D) -> void:
	inVision = true

func _on_vision_body_exited(body: Node2D) -> void:
	inVision = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "drop":
		if health <= 200:
			var a = preload("res://World1/heart_shot.tscn").instantiate()
			a.global_position = global_position + Vector2(0, 500)
			a.velocity = Vector2.RIGHT * projSpeed
			get_parent().add_child(a)
			var b = preload("res://World1/heart_shot.tscn").instantiate()
			b.global_position = global_position + Vector2(0, 500)
			b.velocity = Vector2.LEFT * projSpeed
			b.get_node("Sprite").flip_h = true
			get_parent().add_child(b)
		anim.play("rise")
		dropSFX.play(0.0)
	if anim_name == "rise" and inVision:
		anim.play("drop")
		riseSFX.play(0.0)
