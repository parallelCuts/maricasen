extends Node

@export var enemyList = []
@onready var player = get_node("/root/Node2D/PlayerGroup/PlayerBody")

func _ready():
	var a = preload("res://spider.tscn").instantiate()
	enemyList.append(a)
	var b = preload("res://spider.tscn").instantiate()
	enemyList.append(b)
	var c = preload("res://leech.tscn").instantiate()
	enemyList.append(c)
	var d = preload("res://leech.tscn").instantiate()
	enemyList.append(d)
	var e = preload("res://stickler.tscn").instantiate()
	enemyList.append(e)
	var f = preload("res://stickler.tscn").instantiate()
	enemyList.append(f)
	for enemy in enemyList:
		player.position_updated.connect(enemy._on_player_body_position_updated)
		add_child(enemy)
