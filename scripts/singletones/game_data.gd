extends Node

var element_xsize = 64
var element_ysize = 64

var element_selected1
var element_selected2

var disable_clicked = false
var lowest_position
var highest_position
var level_started = false
var level
var falling_elements = []
var falling_elements_ypos = []
var largest_fall:int

var spawn_fase = true

signal all_falling_el_set
signal all_falling_stopped
signal falling_locs_calculated

signal game_info_requested
signal game_info_given

signal custom_level_info_requested

func destroy_elements(arr):
	for i in arr:
		var q = i.get_x_place()
		var w = i.get_y_place()
		#falling_elements[q] += 1
		falling_elements[q].append(w)
		#
		#if w < falling_elements_ypos[q]:
		#	falling_elements_ypos[q] = w
		i.destroy()
	largest_fall = len(falling_elements.max())
	await get_tree().create_timer(0.01).timeout
	falling_locs_calculated.emit()
	# for i in get_tree().get_nodes_in_group("element"):
	#for i in level.get_children():
	# 	i.check_if_should_fall()


func check_if_should_fall():
	for i in level.get_children():
		i.check_if_should_fall()

func finish_fall():
	element_selected1 = null
	element_selected2 = null
	disable_clicked = false

func get_level_info():
	pass
