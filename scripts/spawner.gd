extends StaticBody2D

@export var max_colors = 6
@export var column_len = 7 # horizontal
@export var row_len = 7 # vertical
var x
@onready var element = preload("res://scenes/element_v3.tscn")

func _ready():
	column_len = get_parent().column_len
	row_len = get_parent().row_len
	max_colors = get_parent().max_colors
	
	# GameData.falling_locs_calculated.connect(create_new_elements)
	#GameData.falling_diagonal_logs_calculated.connect(create_new_elements_from_diagonal)
	pass

func create_new_elements(fall_length):

	# print("f1 create new el")
	var w = 0
	for i in GameData.falling_elements:
		if len(i):
			if w==x and len(GameData.falling_elements[x]) and GameData.falling_elements[x][0]>=0:
				for q in range(len(i)):
					create_element_at(-0-q)
		w += 1
	pass
	await get_tree().create_timer(0.1).timeout
	#GameData.falling_elements = []
	#GameData.falling_elements_ypos = []
	#for i in range(row_len):
		#GameData.falling_elements.append(0)
		#GameData.falling_elements_ypos.append(column_len)
	#GameData.disable_clicked=false

func create_new_elements_from_diagonal():
	# print("f1 create new el")
	var w = 0
	for i in GameData.falling_elements:
		if len(i):
			if w==x and len(GameData.falling_elements[x]) and GameData.falling_elements[x][0]>=0:
				for q in range(len(i)):
					create_element_at(-0-q)
		w += 1
	pass
	await get_tree().create_timer(0.1).timeout


func create_element_at(_y):
	# print("f2 create el at ",_y)
	var q = element.instantiate()
	get_parent().add_child(q)
	q.position.x = position.x
	q.position.y = _y*GameData.element_ysize + position.y
	q.set_color(max_colors)
	GameData.falling_elements2.append(q)
	return q
	# q.animate_falling()
	#q.move_down()
	pass

func create_single_element_at(_y):
	if not len(GameData.diagonally_moving_pieces):
		return
	# print("f2 create el at ",_y)
	var q = element.instantiate()
	get_parent().add_child(q)
	q.position.x = position.x
	q.position.y = _y*GameData.element_ysize + position.y
	q.set_color(max_colors)
	GameData.falling_elements2.append(q)
	#q.move_down()
	pass 
