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
signal falling_diagonal_logs_calculated

signal game_info_requested
signal game_info_given

signal custom_level_info_requested

var moving_pieces:Array = []
var diagonally_moving_pieces = {}

func _physics_process(delta):
	if largest_fall:
		pass
	pass


func destroy_elements(arr):
	for i in arr:
		var q = i.get_x_place()
		var w = i.get_y_place()
		#falling_elements[q] += 1
		#
		if w < falling_elements_ypos[q]:
			falling_elements_ypos[q] = w
		i.destroy()
	# look for hollow spaces
	await get_tree().create_timer(0.01).timeout
	var space_state = level.get_world_2d().direct_space_state
	var x = 0
	var y = 0
	for i in range(level.row_len):
		for j in range(level.column_len):
			var query2 = PhysicsPointQueryParameters2D.new()
			query2.position.x = (x)*element_xsize + level.starting_point.x
			query2.position.y = (y)*element_ysize + level.starting_point.y
			query2.collide_with_areas = true
			var result = space_state.intersect_point(query2)
			if not result:
				falling_elements[i].append(j)
			elif result[0].collider.is_in_group("wall"):
				falling_elements[i].append(-1)
			y += 1
		x += 1
		y=0
	largest_fall = len(falling_elements.max())
	await get_tree().create_timer(0.01).timeout
	falling_locs_calculated.emit(largest_fall)
	# for i in get_tree().get_nodes_in_group("element"):
	#for i in level.get_children():
	# 	i.check_if_should_fall()

func prolong_falling(): # ?
	falling_locs_calculated.emit(largest_fall)


func check_if_should_fall():
	for i in level.get_children():
		i.check_if_should_fall()

func finish_fall():
	element_selected1 = null
	element_selected2 = null
	disable_clicked = false

func get_level_info():
	pass

func add_to_falling_elements(el):
	if not el in moving_pieces:
		moving_pieces.append(el)

func get_diagonal_movable_elements():
	var arr = []
	for i in level.get_children():
		if i.is_in_group("element"):
			if i.can_fall_diagonally_left() or i.can_fall_diagonally_right():
				arr.append(i)
	return arr

func set_off_diagonal_movement():
	var arr = []
	for i in level.get_children():
		if i.is_in_group("element"):
			var can_fall_left = i.can_fall_diagonally_left() 
			var can_fal_right = i.can_fall_diagonally_right()
			if can_fall_left or can_fal_right:
				if can_fall_left:
					diagonally_moving_pieces[i]= -1
				elif can_fal_right:
					diagonally_moving_pieces[i]= 1
				var y = i.get_y_place()
				var x = i.get_x_place()
				falling_elements[x].append(y)
				# arr.append(i)
	#return arr
	falling_diagonal_logs_calculated.emit()
	pass
