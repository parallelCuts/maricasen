extends Node2D

@export var numOfRooms = 0
@export var length = 0
@export var world = ""
var dungeonVisualizer = []
var dungeonArray = []

var playerPos = Vector2.ZERO
var pastPlayerPos = Vector2.ZERO

var roomQueue = []
var health = 0

var counter = 0

@onready var sv = $SubViewport
@onready var tr = $TextureRect

@onready var ostPlayer = $OSTPlayer

class room:
	var openings = []
	var down = false
	var left = false
	var right = false
	var entrance = ''
	var position = Vector2.ZERO

	func _init(o: Array, e: String, p : Vector2):
		openings = o
		entrance = e
		position = p

func _on_viewport_size_changed() -> void:
	var base_res = Vector2(1920, 1080)
	sv.size = base_res
	var window_size = Vector2(DisplayServer.window_get_size())
	var scale_factor = min(window_size.x / base_res.x, window_size.y / base_res.y)
	# Ensure scale factor is never zero
	scale_factor = max(scale_factor, 0.01)
	# Scaled size while maintaining aspect ratio
	var scaled_size = base_res * scale_factor
	# Center the TextureRect (letterbox/pillarbox)
	tr.size = scaled_size
	tr.position = (window_size - scaled_size) / 2.0
	# Set the SubViewport texture
	tr.texture = sv.get_texture()
	# Set shader parameter if applicable
	if tr.material:
		tr.material.set_shader_parameter("viewport_tex", sv.get_texture())
 
func _ready() -> void:
	# Initialize the arrays
	for a in range(length):
		var tempArray = []
		var tempVisualizer = []
		for b in range(length):
			tempArray.append(null)
			tempVisualizer.append(0)
		dungeonArray.append(tempArray)
		dungeonVisualizer.append(tempVisualizer)
	
	ostPlayer.play()
	
	_on_viewport_size_changed()
	# Connect to the root viewport's size_changed signal
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_size_changed"))
	
	var i = 0
	while i < numOfRooms:
		var position = Vector2.ZERO
		if i == 0:
			#spawn
			position = Vector2(randi_range(0, length - 1), 0)
			var tempOpenings = []
			if randi_range(0, 1) == 0 and position.x - 1 > 0:
				tempOpenings.append("left")
			if randi_range(0, 1) == 0 and position.y + 1 < length - 1:
				tempOpenings.append("down")
			if randi_range(0, 1) == 0 and position.x + 1 < length - 1:
				tempOpenings.append("right")
			if tempOpenings.size() == 0:
				if position.x - 1 > 0:
					tempOpenings.append("left")
				if position.y + 1 < length:
					tempOpenings.append("down")
				if position.x + 1 < length:
					tempOpenings.append("right")

			playerPos = position
			var r = room.new(tempOpenings, "spawn", position)
			roomQueue.append(r)
			dungeonArray[position.y][position.x] = r
			dungeonVisualizer[position.y][position.x] = 1
			i += 1
		elif i == numOfRooms - 1:
			var rm = roomQueue[randi_range(0, roomQueue.size() - 1)]
			var op = rm.openings[randi_range(0, rm.openings.size() - 1)]
			match op:
				"left":
					if rm.position.x - 1 < 0 or dungeonArray[rm.position.y][rm.position.x - 1] != null:
						continue
					rm.left = true
					position = Vector2(rm.position.x - 1, rm.position.y)
				"down":
					if rm.position.y + 1 >= length or dungeonArray[rm.position.y + 1][rm.position.x] != null:
						continue
					rm.down = true
					position = Vector2(rm.position.x, rm.position.y + 1)
				"right":
					if rm.position.x + 1 >= length or dungeonArray[rm.position.y][rm.position.x + 1] != null:
						continue
					rm.right = true
					position = Vector2(rm.position.x + 1, rm.position.y)
					
			var r = room.new([], op, position)
			dungeonArray[position.y][position.x] = r
			dungeonVisualizer[position.y][position.x] = 3 if i == numOfRooms - 1 else 2
			i += 1
			pastPlayerPos = playerPos
		else:
			var rm = roomQueue[randi_range(0, roomQueue.size() - 1)]
			var op = rm.openings[randi_range(0, rm.openings.size() - 1)]
			match op:
				"left":
					if rm.position.x - 1 < 0 or dungeonArray[rm.position.y][rm.position.x - 1] != null:
						continue
					rm.left = true
					position = Vector2(rm.position.x - 1, rm.position.y)
				"down":
					if rm.position.y + 1 >= length or dungeonArray[rm.position.y + 1][rm.position.x] != null:
						continue
					rm.down = true
					position = Vector2(rm.position.x, rm.position.y + 1)
				"right":
					if rm.position.x + 1 >= length or dungeonArray[rm.position.y][rm.position.x + 1] != null:
						continue
					rm.right = true
					position = Vector2(rm.position.x + 1, rm.position.y)

			var tempOpenings = []
			if randi_range(0, 1) == 0 and position.x - 1 >= 0 and op != "right":
				tempOpenings.append("left")
			if randi_range(0, 1) == 0 and position.y + 1 < length:
				tempOpenings.append("down")
			if randi_range(0, 1) == 0 and position.x + 1 < length and op != "left":
				tempOpenings.append("right")
			if tempOpenings.size() == 0:
				if position.x - 1 >= 0 and op != "right":
					tempOpenings.append("left")
				if position.y + 1 < length:
					tempOpenings.append("down")
				if position.x + 1 < length and op != "left":
					tempOpenings.append("right")
			var r = room.new(tempOpenings, op, position)
			roomQueue.append(r)
			dungeonArray[position.y][position.x] = r
			dungeonVisualizer[position.y][position.x] = 3 if i == numOfRooms - 1 else 2
			i += 1
			pastPlayerPos = playerPos
	
	roomChange()

func roomChange():
	var r = dungeonArray[playerPos.y][playerPos.x]
	var reference = "res://" + world + "/levels/"
	if r.entrance == "spawn":
		reference += "Spawn/start_"
	elif r.entrance == "left":
		reference += "Left/l_"
	elif r.entrance == "down":
		reference += "Down/d_"
	elif r.entrance == "right":
		reference += "Right/r_"
	for opening in r.openings:
		match opening:
			"left":
				reference += "l"
			"down":
				reference += "d"
			"right":
				reference += "r"
	reference += ".tscn"
	if dungeonVisualizer[playerPos.y][playerPos.x] == 3:
		reference = "res://" + world + "/levels/Boss/boss_room.tscn"
	print(reference)
	var room = load(reference).instantiate()
	if dungeonVisualizer[playerPos.y][playerPos.x] == 3:
		room.get_node("Ground/LeftDoor/AnimationPlayer").play("closed")
		room.get_node("Ground/RightDoor/AnimationPlayer").play("closed")
		room.get_node("Ground/UpDoor/AnimationPlayer").play("closed")
	else:
		for opening in r.openings:
			match opening:
				"left":
					if r.left == true:
						room.get_node("Ground/LeftDoor/AnimationPlayer").play("open")
					else:
						room.get_node("Ground/LeftDoor/AnimationPlayer").play("closed")
				"down":
					if r.down == true:
						room.get_node("Ground/DownDoor/AnimationPlayer").play("open")
					else:
						room.get_node("Ground/DownDoor/AnimationPlayer").play("closed")
				"right":
					if r.right == true:
						room.get_node("Ground/RightDoor/AnimationPlayer").play("open")
					else:
						room.get_node("Ground/RightDoor/AnimationPlayer").play("closed")
			match r.entrance:
				"left":
					room.get_node("Ground/RightDoor/AnimationPlayer").play("open")
				"right":
					room.get_node("Ground/LeftDoor/AnimationPlayer").play("open")
				"down":
					room.get_node("Ground/UpDoor/AnimationPlayer").play("open")
	if counter == 0:
		health = 100
	counter += 1
	room.get_node("PlayerGroup/PlayerBody").health = health
	if pastPlayerPos.x > playerPos.x:
		room.get_node("PlayerGroup/PlayerBody").global_position = room.get_node("Ground/RightDoor").global_position + Vector2(-150, 0)
	elif pastPlayerPos.x < playerPos.x:
		room.get_node("PlayerGroup/PlayerBody").global_position = room.get_node("Ground/LeftDoor").global_position + Vector2(150, 0)
	elif pastPlayerPos.y > playerPos.y:
		room.get_node("PlayerGroup/PlayerBody").global_position = room.get_node("Ground/DownDoor").global_position + Vector2(0, -150)
	elif pastPlayerPos.y < playerPos.y:
		room.get_node("PlayerGroup/PlayerBody").global_position = room.get_node("Ground/UpDoor").global_position + Vector2(0, 150)
	pastPlayerPos = playerPos
	sv.add_child(room)
