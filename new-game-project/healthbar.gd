extends Node2D
@export var maxHealth := 100

@onready var healthBar = $UI/Healthbar
@onready var world = get_parent().get_parent().get_parent()
@onready var player = $PlayerBody

var last_health := -1
var current_health = 100

func _ready() -> void:
	current_health = player.health
	world.health = current_health
	current_health = world.health
	healthBar.value = current_health
func _process(delta): 
	if player:
		current_health = player.health
	else:
		get_parent().queue_free()
	world.health = current_health
	current_health = world.health
	if current_health != last_health:
		last_health = current_health
		update_health_bar(current_health)

func update_health_bar(new_health):
	var tween = create_tween()
	tween.tween_property(healthBar, "value", new_health, 0.3)
