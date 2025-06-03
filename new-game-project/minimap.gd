extends Control
@export var tile_size: int = 8      # Size of each room tile
@export var spacing: int = 2        # Space between tiles
@export var padding: int = 8        # Padding from the top-right corner
@export var dungeon_visualizer_ref: NodePath  # Reference to dungeon generator

var dungeon_data: Array = []

var map_width = 0
var map_height = dungeon_data.size() * (tile_size + spacing)
@onready var dungeon_node = get_parent().get_parent().get_parent().get_parent().get_parent()

func _draw():
	for y in range(dungeon_data.size()):
		for x in range(dungeon_data[y].size()):
			var value = dungeon_data[y][x]
			var color := Color(0, 0, 0, 0)
			match value:
				0:
					continue  # Skip empty
				1:
					color = Color(0.3, 1, 0.3, 0.5)
				2:
					color = Color(0.7, 0.7, 0.7, 0.5)
				3:
					color = Color(1, 0.3, 0.3, 0.5)
			var px = x * (tile_size + spacing)
			var py = y * (tile_size + spacing)
			if dungeon_node.playerPos == Vector2(x, y):
				color = Color(0.3, 0.3, 1, 0.5)
			var rect = Rect2(px, py, tile_size, tile_size)
			draw_rect(rect, color)
	
func _ready():
	await get_tree().process_frame
	queue_redraw()
	dungeon_data = dungeon_node.dungeonVisualizer
	set_custom_minimum_size(Vector2(map_width, map_height))
