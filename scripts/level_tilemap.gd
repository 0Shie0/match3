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
		var data = {}
		data["Cell"]= w.get_custom_data("Cell")
		data["Element"]= w.get_custom_data("Element")
		var q = w.get_custom_data("Cell")
		return data
	return -1

func is_cell_element():
	pass
