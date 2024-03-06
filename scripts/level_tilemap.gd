extends TileMap

var cells


func _ready():
	cells = get_used_cells(0)
	pass

func custom_get_used_cells():
	return cells

func get_cell_data(coords:Vector2):
	var w:TileData = get_cell_tile_data(0,coords)
	if w:
		var q = w.get_custom_data("Cell")
		return q
	return -1

func is_cell_element():
	pass

