extends Node2D

@export var max_colors = 6
@export var column_len = 7 # horizontal
@export var row_len = 7 # vertical
@export var starting_point = Vector2(100,100)

@onready var element = preload("res://scenes/element_v3.tscn")
@onready var element2 = preload("res://scenes/element_v2.tscn")
@onready var floor_element = preload("res://scenes/floor.tscn")
@onready var spawner_element = preload("res://scenes/spawner.tscn")

func _ready():
	GameData.level = self
	GameData.falling_locs_calculated.connect(create_new_elements)
	GameData.game_info_given.connect(data_info_given)
	#generate_grid()
	load_level()

func generate_level():
	pass

	
func generate_grid():
	var x = 0
	var y = 0
	GameData.falling_elements = []
	GameData.falling_elements_ypos = []
	for i in range(row_len):
		GameData.falling_elements.append([])
		GameData.falling_elements_ypos.append(0)
		for j in range(column_len):
			var q
			
			if not i: # ceiling?
				q = spawner_element.instantiate()
				add_child(q)
				q.position.x = (x)*GameData.element_xsize + starting_point.x
				q.position.y = (-1)*GameData.element_ysize + starting_point.y
				q.x = x
				#q.set_specific_color(8)
			q = element.instantiate()
			add_child(q)
			q.position.x = x*GameData.element_xsize + starting_point.x
			q.position.y = y*GameData.element_ysize + starting_point.y
			q.set_color(max_colors)
			x += 1
			await get_tree().create_timer(0.01).timeout
			if i+1 == row_len:  # floor?
				q = floor_element.instantiate()
				add_child(q)
				q.position.x = (x-1)*GameData.element_xsize + starting_point.x
				q.position.y = (y+1)*GameData.element_ysize + starting_point.y
				#q.set_specific_color(8)
		y += 1
		x=0
	GameData.lowest_position = (row_len-1)*GameData.element_ysize + starting_point.y
	GameData.highest_position = starting_point.y
	GameData.level_started = true
	check_all()
	# GameData.spawn_fase

func get_elements_as_grid():
	var x = 0
	var y = 0
	var temp_arr
	for i in range(row_len):
		GameData.falling_elements.append([])
		for j in range(column_len):
			var q = element.instantiate()
			add_child(q)
			q.position.x = x*GameData.element_xsize + starting_point.x
			q.position.y = y*GameData.element_ysize + starting_point.y
			q.set_color(max_colors)
			x += 1
			await get_tree().create_timer(0.01).timeout
	for i in get_children():
		
		pass

func create_new_elements(fall_length):
	print("fakll length ",0.1*fall_length + 0.1)
	await get_tree().create_timer(0.1*fall_length + 0.1).timeout # should change to how long it would fall
	print("fall end")
	GameData.falling_elements = []
	GameData.falling_elements_ypos = []
	for i in range(row_len):
		GameData.falling_elements.append([])
		GameData.falling_elements_ypos.append(column_len)
	var new_deletable = check_all()
	if new_deletable:
		print("wait to delete new")
		GameData.destroy_elements(new_deletable)
	else:
		GameData.disable_clicked=false



func check_all():
	var elms = []
	var q =0
	for i in get_children():
		q += 1
		if i.has_method("check_all_same"):
			var new_arr = i.check_all_same()
			if len(new_arr)>1:
				for el in new_arr:
					if not el in elms:
						elms.append(i)
	var unique = []
	for i in elms:
		if not i in unique:
			unique.append(i)
	return unique
	# print(len(unique), " len ", q, " elms")

func spawn_element_at(x,y,specific_color=-1):
	var q = element.instantiate()
	add_child(q)
	q.position.x = x*GameData.element_xsize + starting_point.x
	q.position.y = y*GameData.element_ysize + starting_point.y
	if specific_color != -1:
		q.set_color(max_colors)
	else:
		q.set_specific_color(specific_color)
	q.animate_falling()
	pass

func create_element_at(x,y,specific_color=-1):
	var q = element.instantiate()
	add_child(q)
	q.position.x = x*GameData.element_xsize + starting_point.x
	q.position.y = y*GameData.element_ysize + starting_point.y
	if specific_color != -1:
		q.set_specific_color(specific_color)
	else:
		q.set_color(max_colors)

func load_level(level_id:String="test_level"):
	var new_level = load("res://scenes/levels/" + level_id + ".tscn").instantiate()
	add_child(new_level)
	await get_tree().create_timer(0.1).timeout
	GameData.game_info_requested.emit()

func data_info_given(data:Array):
	GameData.falling_elements = []
	GameData.falling_elements_ypos = []
	var x = 0
	var y = 0
	for i in data:
		GameData.falling_elements.append([])
		GameData.falling_elements_ypos.append(0)
		for j in i:
			create_cell_from_data(x,y,j)
			
			await get_tree().create_timer(0.01).timeout
			pass
			x+= 1
		y+=1
		x=0
	
	check_all()

func create_cell_from_data(x,y,cell_data):
	if cell_data["Cell"] == -1:
		if cell_data["Element"]==-1:
			create_element_at(x,y)
		else:
			create_element_at(x,y,cell_data["Element"])
	else:
		if cell_data["Cell"] == 0:
			var q = spawner_element.instantiate()
			add_child(q)
			q.position.x = x*GameData.element_xsize + starting_point.x
			q.position.y = y*GameData.element_ysize + starting_point.y
			q.x = x
		elif cell_data["Cell"] == 1:
			var q = floor_element.instantiate()
			add_child(q)
			q.position.x = x*GameData.element_xsize + starting_point.x
			q.position.y = y*GameData.element_ysize + starting_point.y
		pass

func delete_selected():
	var arr = []
	for i in get_children():
		if i.has_meta("color") and i.selected:
			arr.append(i)
	GameData.destroy_elements(arr)
