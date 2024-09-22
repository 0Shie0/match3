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

func create_new_elements(fall_length):

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
	var q = element.instantiate()
	get_parent().add_child(q)
	q.position.x = position.x
	q.position.y = _y*GameData.element_ysize + position.y
	q.set_color(max_colors)
	GameData.falling_elements2.append(q)
	return q
	pass

func create_single_element_at(_y):
	if not len(GameData.diagonally_moving_pieces):
		return
	var q = element.instantiate()
	get_parent().add_child(q)
	q.position.x = position.x
	q.position.y = _y*GameData.element_ysize + position.y
	q.set_color(max_colors)
	GameData.falling_elements2.append(q)
	pass 
