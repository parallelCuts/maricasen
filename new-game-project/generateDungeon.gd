extends Node2D

@export var numOfRooms = 0
@export var length = 0
var dungeonVisualizer = []
var dungeonArray = []

class room:
	var openings = []

	func _init(o: Array):
		openings = o

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

	var i = 0
	var roomQueue = []

	while i < numOfRooms:
		if i == 0:
			# Starting room
			var xPos = randi_range(0, length - 1)
			var yPos = 0
			var directions = ["left", "right", "down"]
			var roomDirs = [directions[randi_range(0, directions.size() - 1)]]
			dungeonArray[yPos][xPos] = room.new(roomDirs)
			dungeonVisualizer[yPos][xPos] = 1
			roomQueue.append(Vector2(xPos, yPos))
			i += 1
		elif i == numOfRooms - 1:
			var addedRoom = false

			while not addedRoom and roomQueue.size() > 0:
				var index = randi_range(0, roomQueue.size() - 1)
				var pos = roomQueue[index]
				var x = int(pos.x)
				var y = int(pos.y)

				var directions = ["left", "right", "down"]
				directions.shuffle()
				for dir in directions:
					var nx = x
					var ny = y

					match dir:
						"left":
							nx -= 1
						"right":
							nx += 1
						"down":
							ny += 1

					if nx >= 0 and nx < length and ny >= 0 and ny < length:
						if dungeonArray[ny][nx] == null:
							# Create new room
							var newDirs = ["left", "right", "down"]
							newDirs.shuffle()
							var openDirs = [newDirs[randi_range(0, newDirs.size() - 1)]]

							dungeonArray[ny][nx] = room.new(openDirs)
							dungeonVisualizer[ny][nx] = 3
							roomQueue.append(Vector2(nx, ny))
							addedRoom = true
							i += 1
							break

				if not addedRoom:
					# Dead end, remove from queue
					roomQueue.remove_at(index)
			
		else:
			var addedRoom = false

			while not addedRoom and roomQueue.size() > 0:
				var index = randi_range(0, roomQueue.size() - 1)
				var pos = roomQueue[index]
				var x = int(pos.x)
				var y = int(pos.y)

				var directions = ["left", "right", "down"]
				directions.shuffle()

				for dir in directions:
					var nx = x
					var ny = y

					match dir:
						"left":
							nx -= 1
						"right":
							nx += 1
						"down":
							ny += 1

					if nx >= 0 and nx < length and ny >= 0 and ny < length:
						if dungeonArray[ny][nx] == null:
							# Create new room
							var newDirs = ["left", "right", "down"]
							newDirs.shuffle()
							var openDirs = [newDirs[randi_range(0, newDirs.size() - 1)]]

							dungeonArray[ny][nx] = room.new(openDirs)
							dungeonVisualizer[ny][nx] = 2
							roomQueue.append(Vector2(nx, ny))
							addedRoom = true
							i += 1
							break

				if not addedRoom:
					# Dead end, remove from queue
					roomQueue.remove_at(index)

			# Safety: If queue is empty and not enough rooms, restart generation
			if roomQueue.size() == 0 and i < numOfRooms:
				print("Restarting dungeon generation (ran out of room options)")
				_ready()  # Restart
				return

	# Print result
	for row in dungeonVisualizer:
		print(row)
