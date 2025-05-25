extends Node

@export var enemyList = []
@onready var player = get_node("/root/Node2D/PlayerGroup/PlayerBody")

func _ready():
	var a = preload("res://stickler.tscn").instantiate()
	enemyList.append(a)
	var b = preload("res://leech.tscn").instantiate()
	b.position = Vector2(500, 0)
	enemyList.append(b)
	var c = preload("res://leech.tscn").instantiate()
	c.position = Vector2(500, 0)
	enemyList.append(c)
	for enemy in enemyList:
		player.position_updated.connect(enemy._on_player_body_position_updated)
		add_child(enemy)
