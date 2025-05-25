extends CharacterBody2D

@export var gravity = 4000
var player_position: Vector2 = Vector2.ZERO

var flash_timer := 0.0
const FLASH_DURATION := 0.5

func _process(delta):
	var mat = $Sprite.material
	if flash_timer > 0.0:
		flash_timer -= delta
		mat.set_shader_parameter("flash_amount", flash_timer / FLASH_DURATION)
	else:
		mat.set_shader_parameter("flash_amount", 0.0)

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	
	var playerDist = player_position.distance_to(global_position)
	var direction = Vector2()
	if playerDist > 700:
		pass
	else:
		pass
	
	move_and_slide()

func _on_player_body_position_updated(new_position: Vector2) -> void:
	player_position = new_position
