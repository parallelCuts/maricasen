extends Node2D
@export var maxHealth := 100

@onready var healthBar = $UI/Healthbar
@onready var world = get_parent().get_parent()
var last_health := -1
var current_health
func _process(delta): 
	world.health = current_health
	if $PlayerBody:
		current_health = $PlayerBody.health
	else:
		current_health = 0
	if current_health != last_health:
		last_health = current_health
		update_health_bar(current_health)

func update_health_bar(new_health):
	var tween = create_tween()
	tween.tween_property(healthBar, "value", new_health, 0.3)
