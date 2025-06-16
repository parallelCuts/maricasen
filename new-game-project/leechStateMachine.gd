extends Node2D

@export var speed = 500
@export var segment_spacing = 10

@onready var head = $Head
@onready var body_parts = [$Body1, $Body2, $Body3, $Body4]
@onready var hurtboxes = [$Hurtbox/CollisionShape2D, $Hurtbox/CollisionShape2D2, $Hurtbox/CollisionShape2D3, $Hurtbox/CollisionShape2D4, $Hurtbox/CollisionShape2D5]
@onready var hitboxes = [$Head/Tongue/Hitbox/CollisionShape2D2, $Head/Tongue/Hitbox/CollisionShape2D3, $Head/Tongue/Hitbox/CollisionShape2D4, $Head/Tongue/Hitbox/CollisionShape2D5, $Head/Tongue/Hitbox/CollisionShape2D6]

var player_position: Vector2 = Vector2.ZERO

var flash_timer := 0.0
const FLASH_DURATION := 0.5

var timer = 0
var randPosition = Vector2.ZERO

@export var health = 20

var attackTimer = 0;

@onready var tongue = $Head/Tongue
@onready var tongue_anim = $Head/Tongue/AnimationPlayer

@onready var anim = $AnimationPlayer
var isDead = false

var hurtTime = 0

@onready var lickSFX = $LickSFX

@onready var svAnim = get_parent().get_parent().get_parent().get_parent().get_node("AnimationPlayer")

func _ready() -> void:
	head.get_node("Sprite").material = head.get_node("Sprite").material.duplicate()
	for part in body_parts:
		part.get_node("Sprite").material = head.get_node("Sprite").material.duplicate()
	anim.play("idle")

func _process(delta):
	var mat = head.get_node("Sprite").material
	if flash_timer > 0.0:
		flash_timer -= delta
		mat.set_shader_parameter("flash_amount", flash_timer / FLASH_DURATION)
	else:
		mat.set_shader_parameter("flash_amount", 0.0)
	for part in body_parts:
		mat = part.get_node("Sprite").material
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
	var playerDist = player_position.distance_to(head.global_position)
	
	if health <= 0:
		if isDead == false:
			anim.play("death")
		if !anim.is_playing() and isDead == true:
			queue_free()
		isDead = true
	
	if not isDead:
		for h in range(hurtboxes.size()):
			if h == 0:
				hurtboxes[h].global_position = head.global_position
				hitboxes[h].global_position = head.global_position
			else:
				hurtboxes[h].global_position = body_parts[h - 1].global_position
				hitboxes[h].global_position = body_parts[h - 1].global_position
		if playerDist > 700:
			if timer > 0:
				movement(randPosition + head.global_position)
				timer -= delta
			else:
				randPosition = Vector2(randf_range(-1, 1), randf_range(-1, 1))
				timer = randf_range(2, 5)
		elif playerDist > 200:
			timer = 0
			movement(player_position)
		else:
			timer = 0
			head.velocity = Vector2.ZERO
			head.look_at(player_position)
			if attackTimer > 0:
				attackTimer -= delta
			else:
				tongue.look_at(player_position)
				tongue_anim.play("lick")
				lickSFX.play(0.0)
				attackTimer = 1
			for i in range(body_parts.size()):
				body_parts[i].velocity = Vector2.ZERO
				if i == 0:
					body_parts[i].look_at(head.global_position)
				else:
					body_parts[i].look_at(body_parts[i - 1].global_position)
	hurtTime -= delta

func movement(target):
	var direction = (target - head.global_position).normalized()
	head.velocity = direction * speed
	head.move_and_slide()
	if head.velocity.length() > 0.1:
		head.rotation = head.velocity.angle()
	for i in range(body_parts.size()):
		if i == 0:
			direction = (head.get_node("Link").global_position - body_parts[i].global_position).normalized()
		else:
			direction = (body_parts[i - 1].get_node("Link").global_position - body_parts[i].global_position).normalized()
		body_parts[i].velocity = direction * speed
		body_parts[i].move_and_slide()
		if body_parts[i].velocity.length() > 0.1:
			body_parts[i].rotation = body_parts[i].velocity.angle()

func _on_player_body_position_updated(new_position: Vector2) -> void:
	player_position = new_position


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if hurtTime <= 0:
		take_damage(10)
		var particles = preload("res://enemy_particle.tscn").instantiate()
		particles.position = body_parts[3].position
		particles.one_shot = true
		if area.global_position.x > body_parts[3].global_position.x:
			particles.direction.x = -1
		add_child(particles)
		hurtTime = 0.5
