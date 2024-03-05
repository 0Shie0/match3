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
	generate_grid()

func generate_level():
	pass
	
func load_level():
	pass
	
func generate_grid():
	var x = 0
	var y = 0
	GameData.falling_elements = []
	GameData.falling_elements_ypos = []
	for i in range(row_len):
		GameData.falling_elements.append(0)
		GameData.falling_elements_ypos.append(column_len)
		for j in range(column_len):
			var q
			
			if not i:
				q = spawner_element.instantiate()
				add_child(q)
				q.position.x = (x)*GameData.element_xsize + starting_point.x
				q.position.y = (-1)*GameData.element_ysize + starting_point.y
				q.x = x
			q = element.instantiate()
			add_child(q)
			q.position.x = x*GameData.element_xsize + starting_point.x
			q.position.y = y*GameData.element_ysize + starting_point.y
			q.set_color(max_colors)
			x += 1
			await get_tree().create_timer(0.01).timeout
			if i+1 == row_len:
				q = floor_element.instantiate()
				add_child(q)
				q.position.x = (x-1)*GameData.element_xsize + starting_point.x
				q.position.y = (y+1)*GameData.element_ysize + starting_point.y
		y += 1
		x=0
	GameData.lowest_position = (row_len-1)*GameData.element_ysize + starting_point.y
	GameData.highest_position = starting_point.y
	GameData.level_started = true

func get_elements_as_grid():
	var x = 0
	var y = 0
	var temp_arr
	for i in range(row_len):
		GameData.falling_elements.append(0)
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

func create_new_elements():
	#var w = 0
	#for i in GameData.falling_elements:
		#if i:
			#for q in range(i):
				#create_element_at(w,-1-q)
		#w += 1
	#pass
	await get_tree().create_timer(0.2).timeout
	GameData.falling_elements = []
	GameData.falling_elements_ypos = []
	for i in range(row_len):
		GameData.falling_elements.append(0)
		GameData.falling_elements_ypos.append(column_len)
	GameData.disable_clicked=false
	

func create_element_at(x,y):
	var q = element.instantiate()
	add_child(q)
	q.position.x = x*GameData.element_xsize + starting_point.x
	q.position.y = y*GameData.element_ysize + starting_point.y
	q.set_color(max_colors)
	q.animate_falling()
	pass
