extends Node2D

@onready var tilemap = %TileMap

func  _ready():
	#GameData.game_info_requested.
	GameData.game_info_requested.connect(on_level_info_requested)
	GameData.game_info_requested.emit()
	# var w = await GameData.game_info_given


# place in parent
func on_level_info_requested():
	var q = get_level_info()
	GameData.game_info_given.emit(q)

func get_level_info():
	var map_size:Vector2 = tilemap.get_used_rect().size
	var end_array:Array = []
	for i in range(map_size.y):
		end_array.append([])
		for j in range(map_size.x):
			var cell_data = tilemap.get_cell_data(Vector2(j,i))
			end_array[i].append(cell_data)
			pass
	return end_array
