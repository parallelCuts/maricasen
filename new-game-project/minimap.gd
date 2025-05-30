extends Control
@export var tile_size: int = 8      # Size of each room tile
@export var spacing: int = 2        # Space between tiles
@export var padding: int = 8        # Padding from the top-right corner
@export var dungeon_visualizer_ref: NodePath  # Reference to dungeon generator

var dungeon_data: Array = []

var map_width = 0
var map_height = dungeon_data.size() * (tile_size + spacing)

func _draw():
	for y in range(dungeon_data.size()):
		for x in range(dungeon_data[y].size()):
			var value = dungeon_data[y][x]
			var color := Color(0, 0, 0, 0)
			match value:
				0:
					continue  # Skip empty
				1:
					color = Color.GREEN      # Starting room
				2:
					color = Color.LIGHT_GRAY # Normal room
				3:
					color = Color.RED        # Final room
			var px = x * (tile_size + spacing)
			var py = y * (tile_size + spacing)
			var rect = Rect2(px, py, tile_size, tile_size)
			draw_rect(rect, color)
	
func _ready():
	await get_tree().process_frame
	queue_redraw()
	var dungeon_node = get_parent().get_parent()
	dungeon_data = dungeon_node.dungeonVisualizer
	set_custom_minimum_size(Vector2(map_width, map_height))
