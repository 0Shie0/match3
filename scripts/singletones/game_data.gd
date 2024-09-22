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
var falling_elements2 = []
var falling_elements2_max_ypos = []
var falling_elements_ypos = []
var walls = []
var taken_diagonal_spaces = [] # for remembering which places would be taken for futur diagonal falls
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
	var dict := {}
	for a in arr:
		dict[a] = 1
	var arr2 = dict.keys()
	print("to destroy_fifference: ", len(arr), ", ", len(arr2))
	
	for i in arr:
		
		var q = i.get_x_place()
		var w = i.get_y_place()
		if w < falling_elements_ypos[q]:
			falling_elements_ypos[q] = w
		i.destroy()
	# look for hollow spaces
	await get_tree().create_timer(0.01).timeout
	var space_state = level.get_world_2d().direct_space_state
	var x = 0
	var y = 0
	#for i in range(level.column_len):
		#for j in range(level.row_len):
			#var query2 = PhysicsPointQueryParameters2D.new()
			#query2.position.x = (x)*element_xsize + level.starting_point.x
			#query2.position.y = (y)*element_ysize + level.starting_point.y
			#query2.collide_with_areas = true
			#var result = space_state.intersect_point(query2)
			#if not result: # if blank space found
				#query2.position.y -= element_ysize
				#var result2 = space_state.intersect_point(query2) # check element above void
				#if not result2 or (result2 and not result2[0].collider.is_in_group("element")):
					#falling_elements[i].append(j)
			#y += 1
		#x += 1
		#y=0
	#largest_fall = len(falling_elements.max())
	
	# how about that?
	# get all floor elements, from each go up until there is not element
	# look only from fall straight down things? for now
	# falling down elements
	var floor_elements = get_tree().get_nodes_in_group("floor")
	var might_fall_diagonally = []
	var cnt = 0
	for i in floor_elements:
		falling_elements2_max_ypos.append(level.column_len)
		var query2 = PhysicsPointQueryParameters2D.new()
		query2.position.x = i.position.x
		query2.position.y = i.position.y
		query2.collide_with_areas = true
		var start_fall = false
		for j in range(i.position.y/element_ysize):
			query2.position.y -= element_ysize
			var result = space_state.intersect_point(query2)
			if not result:
				start_fall = true
			elif start_fall:
				if result and result[0].collider.is_in_group("element"):
					falling_elements2.append(result[0].collider)
					falling_elements2_max_ypos[cnt] = result[0]
				else:
					
					if result and not result[0].collider.is_in_group("element"):
						start_fall = false
		cnt += 1
				
	await get_tree().create_timer(0.01).timeout
	if get_diagonal_movable_elements():
		set_off_diagonal_movement(1)
	else:
		falling_locs_calculated.emit(largest_fall)


func prolong_falling(): # ?
	falling_locs_calculated.emit(largest_fall)

func get_element_at(x,y,specific_color=-1):
	var space_state = level.get_world_2d().direct_space_state
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position.x = (x)*element_xsize + level.starting_point.x
	query2.position.y = (y)*element_ysize + level.starting_point.y
	query2.collide_with_areas = true
	var result = space_state.intersect_point(query2)
	if result:
		if specific_color != -1:
			return result.collider
		elif result.collider.color == specific_color:
			return result.collider
	return null


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

func get_falling_straight_elements():
	var space_state = level.get_world_2d().direct_space_state
	var floor_elements = get_tree().get_nodes_in_group("floor")
	var might_fall_diagonally = []
	var cnt = 0
	for i in floor_elements:
		falling_elements2_max_ypos.append(level.column_len)
		var query2 = PhysicsPointQueryParameters2D.new()
		query2.position.x = i.position.x
		query2.position.y = i.position.y
		query2.collide_with_areas = true
		var start_fall = false
		for j in range(i.position.y/element_ysize):
			query2.position.y -= element_ysize
			var result = space_state.intersect_point(query2)
			# if result[0].collider in falling_elements2 or result[0].collider in diagonally_moving_pieces
			if not result or result[0].collider in falling_elements2 or result[0].collider in diagonally_moving_pieces:
				start_fall = true
			elif start_fall:
				if result and result[0].collider.is_in_group("element"):
					falling_elements2.append(result[0].collider)
					falling_elements2_max_ypos[cnt] = result[0]
				else:
					if result and not result[0].collider.is_in_group("element"):
						start_fall = false
		cnt += 1
	

func get_diagonal_movable_elements():
	var arr = []
	for i in level.get_children():
		if i.is_in_group("element"):
			if i.can_fall_diagonally_left() or i.can_fall_diagonally_right():
				if not i in diagonally_moving_pieces:
					arr.append(i)
	return arr

func set_off_diagonal_movement(is_starter=0):
	taken_diagonal_spaces = []
	diagonally_moving_pieces = {}
	var arr = []
	var check_again = get_diagonal_movable_elements()
	while check_again:
		print("inside continue ", len(get_diagonal_movable_elements()))
		for i in get_diagonal_movable_elements():
			if i in diagonally_moving_pieces:
				printerr("this no no")
		for i in level.get_children():
			if i.is_in_group("element"):
				var can_fall_left = i.can_fall_diagonally_left() 
				var can_fal_right = i.can_fall_diagonally_right()
				if can_fall_left or can_fal_right:
					var directions = []
					if can_fall_left:
						directions.append(-1)
					if can_fal_right:
						directions.append(1)
					directions.shuffle()
					diagonally_moving_pieces[i]= directions[0]
					var y = i.get_y_place()
					var x = i.get_x_place()
		
					if false:
						# idk wahts that for
						var space_state = level.get_world_2d().direct_space_state
						var query2 = PhysicsPointQueryParameters2D.new()
						query2.position.x = (x+directions[0])*element_xsize + level.starting_point.x
						query2.position.y = (y+1)*element_ysize + level.starting_point.y
						query2.collide_with_areas = true
						var result = space_state.intersect_point(query2)
						if not result: # if space above
							falling_elements[x].append(y)
						query2.position.x = (x)*element_xsize + level.starting_point.x
						query2.position.y = (y-1)*element_ysize + level.starting_point.y
						result = space_state.intersect_point(query2)

						if result and result[0].collider.is_in_group("spawner"):
							falling_elements[x].append(y) # shoold only add if there is an empty space
						taken_diagonal_spaces.append(Vector2(x+directions[0],y+1))
					# arr.append(i)
		print(diagonally_moving_pieces)
		get_falling_straight_elements()
		check_again = get_diagonal_movable_elements()
		var q
	for i in diagonally_moving_pieces:
		var spawner_above = i.get_spawner_above()
		if spawner_above:
			var new_el = spawner_above.create_element_at(0)
			falling_elements2.append(new_el)
	for i in falling_elements2:
		if i:
			var spawner_above = i.get_spawner_above()
			if spawner_above:
				var new_el = spawner_above.create_element_at(0)
				if new_el in falling_elements2:
					print("already there")
				# falling_elements2.append(new_el)
	#return arr
	
	await get_tree().create_timer(0.02).timeout
	if is_starter:
		falling_locs_calculated.emit(is_starter)
	else:
		falling_diagonal_logs_calculated.emit()
	pass
