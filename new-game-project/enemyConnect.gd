extends Node2D

@onready var player = $PlayerGroup/PlayerBody
@onready var enemies = $EnemyGroup.get_children()

func _ready() -> void:
	for enemy in enemies:
		player.position_updated.connect(enemy._on_player_body_position_updated)
