extends CharacterBody2D

func _physics_process(delta: float) -> void:
	velocity.x = velocity.x
	move_and_slide()

func _on_check_collision_body_entered(body: Node2D) -> void:
	queue_free()
