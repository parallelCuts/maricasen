extends StaticBody2D
@export var assigned = Vector2.ZERO
func _on_area_2d_body_entered(body: Node2D) -> void:
	var world = get_parent().get_parent().get_parent().get_parent()
	world.playerPos += assigned
	print(assigned)
	world.call_deferred("roomChange")
	get_parent().get_parent().queue_free()
