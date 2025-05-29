extends Node2D
@export var maxHealth := 100

@onready var healthBar = $UI/Healthbar

var last_health := -1

func _process(delta):
	var current_health = $PlayerBody.health
	if current_health != last_health:
		last_health = current_health
		update_health_bar(current_health)

func update_health_bar(new_health):
	var tween = create_tween()
	tween.tween_property(healthBar, "value", new_health, 0.3)
