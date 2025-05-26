extends CharacterBody2D

@onready var anim = $AnimationPlayer

func _ready() -> void:
	anim.play("spin")

func _physics_process(delta: float) -> void:
	if not anim.is_playing():
		queue_free()
	move_and_slide()

func _on_check_collision_body_entered(body: Node2D) -> void:
	anim.play("hit")
	velocity = Vector2.ZERO
