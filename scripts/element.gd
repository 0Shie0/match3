extends Area2D

signal dead # to dastroy
signal fallen # finished falling

var color = 0

var hor_same = 0
var ver_same = 0
var falling = false

var original_position
var falling_position_difference
var falling_element

var selected:bool = false
@onready var tween:Tween 
@onready var element = preload("res://scenes/element_v3.tscn")

var queued_movement = []

func _ready():
	GameData.falling_locs_calculated.connect(animate_falling)
	GameData.falling_diagonal_logs_calculated.connect(animate_falling)


func _physics_process(delta):
	pass
	#if GameData.disable_clicked:
	#	check_if_should_fall()
	#if falling:
	#	check_if_should_stop()
	#elif GameData.level_started:
	#	check_if_should_fall()
		#position = falling_element.position-original_position

func set_color(_max):
	randomize()
	color = randi() % _max
	var q = get_same_left()
	var r = range(_max)
	if len(q):
		r.erase(color)
		color = r[randi() % (_max-1)]
	q = get_same_up()
	if len(q):
		r.erase(color)
		color = r[randi() % (_max-2)]
	$Sprite2D.frame = color*3
	$AnimatedSprite2D.frame = color
	original_position = position

func set_random_color(_max):
	randomize()
	color = randi() % _max
	$Sprite2D.frame = color*3
	$AnimatedSprite2D.frame = color
	pass

func set_specific_color(color_id):
	color = color_id
	$Sprite2D.frame = color*3
	$AnimatedSprite2D.frame = color_id
	original_position = position

func get_same_left()->Array:
	var p2 = Vector2(-2*GameData.element_xsize,0) + position
	var p1 = Vector2(-GameData.element_xsize,0) + position
	var result = check_same(p1,p2)
	return result

func get_same_right():
	var p2 = Vector2(2*GameData.element_xsize,0) + position
	var p1 = Vector2(GameData.element_xsize,0) + position
	var result = check_same(p1,p2)
	return result
	
func get_same_up():
	var p2 = Vector2(0,-2*GameData.element_ysize) + position
	var p1 = Vector2(0,-GameData.element_ysize) + position
	var result = check_same(p1,p2)
	return result
func get_same_down():
	var p2 = Vector2(0,2*GameData.element_ysize) + position
	var p1 = Vector2(0,GameData.element_ysize) + position
	var result = check_same(p1,p2)
	return result

func check_same(pos1,pos2):
	var result = []
	var space_state = get_world_2d().direct_space_state
	var query1 = PhysicsPointQueryParameters2D.new()
	query1.position = pos1
	query1.collide_with_areas = true
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = pos2
	query2.collide_with_areas = true
	var result1 = space_state.intersect_point(query1)
	var result2 = space_state.intersect_point(query2)
	if result1 and result1[0].collider.is_in_group("element"):
		if result1[0].collider.color == color:
			result.append(result1[0].collider)
			if result2 and "color" in result2[0].collider:
				if result2[0].collider.color == color:
					result.append(result2[0].collider)
	return result

func print_same(pos1,pos2):
	var result = []
	var space_state = get_world_2d().direct_space_state
	var query1 = PhysicsPointQueryParameters2D.new()
	query1.position = pos1
	query1.collide_with_areas = true
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = pos2
	query2.collide_with_areas = true
	var result1 = space_state.intersect_point(query1)
	var result2 = space_state.intersect_point(query2)
	if result1 and result1[0].collider.is_in_group("element"):
		if result1[0].collider.color == color:
			result.append(result1[0].collider)
			if result2 and "color" in result2[0].collider:
				if result2[0].collider.color == color:
					result.append(result2[0].collider)
	print("same", result)

func clicked():
	if GameData.element_selected1:
		if GameData.element_selected1==self:
			GameData.element_selected1 = null
			deselect()
			GameData.disable_clicked = false
			return
		var x = GameData.element_selected1.get_x_place()
		var y = GameData.element_selected1.get_y_place()
		var xself = get_x_place()
		var yself = get_y_place()
		if abs(x-xself)+ abs(y-yself) == 1:
			pass
			GameData.disable_clicked = true
			GameData.element_selected2 = self
			swap()
		else:
			GameData.element_selected1.deselect()
			select()
			GameData.element_selected1 = self
	else:
		GameData.element_selected1 = self
	select()
	pass
	
func select():
	selected = true
	$Sprite2D.modulate = Color("#808080")
	$AnimatedSprite2D.modulate = Color("#808080")
	pass
func deselect():
	selected = false
	$Sprite2D.modulate = Color("#ffffff")
	$AnimatedSprite2D.modulate = Color("#ffffff")
	pass

func mark():
	$mark.visible = true
	await get_tree().create_timer(0.2)
	$mark.visible = true

func swap():
	var p1 = GameData.element_selected2.position
	var p2 = GameData.element_selected1.position
	GameData.element_selected1.position = p1
	GameData.element_selected2.position = p2
	await get_tree().create_timer(0.2).timeout
	GameData.element_selected1.deselect()
	GameData.element_selected2.deselect()
	
	var q = check_all_same()
	var w = GameData.element_selected1.check_all_same()
	for i in w:
		if not i in q:
			q.append(i)
	#q.append_array(w)
	if len(q):
		GameData.destroy_elements(q)
	else:
		GameData.element_selected1.position = GameData.element_selected1.original_position
		GameData.element_selected2.position = GameData.element_selected2.original_position
		GameData.disable_clicked = false
	
	GameData.element_selected1 = null
	GameData.element_selected2 = null

func check_all_same():
	var hor = []
	var ver = []
	
	var q = get_same_left()
	hor.append_array(q)
	q=get_same_right()
	hor.append_array(q)
	q=get_same_down()
	ver.append_array(q)
	q=get_same_up()
	ver.append_array(q)
	
	var all = []
	if len(hor) > 1:
		all.append_array(hor)
	if len(ver) > 1:
		all.append_array(ver)
		
	if len(all):
		all.append(self)
	return all
		
func destroy():
	queue_free()

func check_if_should_fall():
	if self in GameData.falling_elements2:
		set_falling()

	return
	var result = []
	var space_state = get_world_2d().direct_space_state
	var query1 = PhysicsPointQueryParameters2D.new()
	query1.collide_with_areas = true
	query1.position = position + Vector2(0,GameData.element_ysize)
	var result1 = space_state.intersect_point(query1)
	if position.y >=GameData.lowest_position:
		falling = false
		GameData.disable_clicked = false
		original_position=position
		query1 = PhysicsPointQueryParameters2D.new() # probably dont need that bit, since phys processs check for stopping
		query1.position = position + Vector2(0,-GameData.element_ysize)
		query1.collide_with_areas = true
		result1 = space_state.intersect_point(query1)
		if result1:
			if result1[0].collider.falling:
				result1[0].collider.check_if_should_fall()
		return
	if result1:
		if result1[0].collider.falling:
			pass
			#position = result1[0].collider.position + Vector2(0,GameData.element_ysize)
		else:
			falling = false
			GameData.disable_clicked = false
			original_position=position
			return
	if falling:
		animate_falling()
		return
	#else:
		#set_first_falling()

func check_if_should_stop():
	var areas = get_overlapping_areas()
	for i in areas:
		if i.position.y > position.y and i.position.x == position.x:
			tween.kill()
			falling = false
			GameData.disable_clicked = false
			original_position=position
			return


func set_first_fallingdelete():
	falling = true
	var space_state = get_world_2d().direct_space_state
	var query1 = PhysicsPointQueryParameters2D.new()
	query1.position = position + Vector2(0,-GameData.element_ysize)
	query1.collide_with_areas = true
	var result1 = space_state.intersect_point(query1)
	if result1:
		result1[0].collider.check_if_should_fall()
	query1.position = position - Vector2(0,-GameData.element_ysize)
	result1 = space_state.intersect_point(query1)
	if not result1:
		if position.y>GameData.highest_position:
			if position.y - GameData.element_ysize < GameData.highest_position:
				var q = element.instantiate()
				get_parent().add_child(q)
				q.position = position - Vector2(GameData.element_xsize,GameData.element_ysize)
				q.set_color(get_parent().max_colors)
				q.set_first_falling()
			pass
	animate_falling()
	
func animate_falling(max_fall=null):
	var is_above_removed = 0
	var is_moved_aside = 0
	var cancel_movement = false
	var spawner_above = get_spawner_above()
	if self in GameData.diagonally_moving_pieces:
		var dir = GameData.diagonally_moving_pieces[self]
		tween = get_tree().create_tween()
		tween.tween_property(self, "position" , position + Vector2(dir*GameData.element_xsize,GameData.element_ysize),0.1)
		await tween.finished
		original_position = position
		return
	var q = get_y_place()
	if get_y_place()==0:
		print("spawned ", self in GameData.falling_elements2, ", ", self in GameData.diagonally_moving_pieces)
	if self in GameData.falling_elements2: # if falls staright down
		
		pass
		# fall straight down
		for i in range(1): # get here falling_elements2 same in same row
			tween = get_tree().create_tween()
			tween.tween_property(self, "position" , position + Vector2(0,GameData.element_ysize),0.1)
			await tween.finished
			original_position = position
	
	return
	for i in GameData.falling_elements[get_x_place()]:
		if cancel_movement:
			break
		var w = get_y_place()
		if get_y_place() < i:
			is_above_removed += 1 # removed element was lower (assuming there was no walls)
		if get_y_place()==i:
			is_moved_aside = 1
		if GameData.walls[get_x_place()]:
			var starting_y = -1
			for y2 in GameData.walls[get_x_place()]:
				if i > y2 and get_y_place() > y2: # thngs are falling though the floor
					# and not falling when they need to
					is_above_removed = 0
					cancel_movement = true
					break
	
	if is_above_removed:
		
		if spawner_above:
			spawner_above.create_single_element_at(0)
		pass
		# if element_below_exist():
		# do nothing
		
		# fall straight down
		for i in range(is_above_removed): # might need evaluate each step for diagonal movement
		#while get_y_place() <
			tween = get_tree().create_tween()
			tween.tween_property(self, "position" , position + Vector2(0,GameData.element_ysize),0.1)
			await tween.finished
			original_position = position

		return
		# cut off that
		# will try to set up start for diagonal falling in level
		# stug below will probably be deleted
		var can_fall_left = element_below_left_exist()
		var can_fall_right = element_below_right_exist()
		var upl = get_y_place()
		var ch = get_y_place() == len(GameData.falling_elements[get_x_place()])-2
		if get_y_place() == len(GameData.falling_elements[get_x_place()])-2:
			if can_fall_left or can_fall_right:
			 # only lowest element sends signal
				var el = get_element_up()
				if el:
					el.move_down()
				if not get_y_place() in GameData.falling_elements[get_x_place()]:
					GameData.falling_elements[get_x_place()] = [get_y_place()+1]
				tween.kill()
				tween = get_tree().create_tween()
				tween.tween_property(self, "position" , position + Vector2(GameData.element_xsize,GameData.element_ysize),1.1)
				await tween.finished
				original_position = position
				# GameData.falling_locs_calculated.emit()
				can_fall_left = element_below_left_exist()
				can_fall_right = element_below_right_exist()
			#GameData.falling_elements[get_x_place()]-=1
			else:
				pass
		
		GameData.moving_pieces.erase(self)
		if not GameData.moving_pieces:
			# GameData.largest_fall = 0
			GameData.all_falling_stopped.emit()


func set_falling(): # will probably need to remove that
	pass

func get_x_place():
	var wew = position.x
	var e = typeof(wew)==TYPE_INT
	var t = int(position.x) / GameData.element_xsize
	# print("xplace ", t)
	return int(position.x) / GameData.element_xsize - 1

func get_y_place():
	return int(position.y) / GameData.element_ysize - 1


func element_below_exist(): # dk, will see TODO
	var space_state = get_world_2d().direct_space_state
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = position+Vector2(0,GameData.element_ysize)/4
	query2.collide_with_areas = true
	var result1 = space_state.intersect_point(query2)
	if result1 and result1.collider and result1[0].collider.is_in_group("element"):
		return true
	return false

func can_fall_diagonally_left():
	if get_y_place() < 0 and not self in GameData.falling_elements2 and not self in GameData.diagonally_moving_pieces:
		return false
	var space_state = get_world_2d().direct_space_state
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = position+Vector2(-GameData.element_xsize,GameData.element_ysize)
	query2.collide_with_areas = true
	var result1 = space_state.intersect_point(query2) # something on the below left
	query2.position = position+Vector2(0,GameData.element_ysize)
	var result2 = space_state.intersect_point(query2) # something below
	query2.position =position+Vector2(-GameData.element_xsize,0)
	var result3 = space_state.intersect_point(query2) # space above diag left
	var have_fall_place
	if (not result1 or result1[0].collider in GameData.falling_elements2 or result1[0].collider in GameData.diagonally_moving_pieces):
		have_fall_place = true
	if result2 and not (result3 and result3[0].collider.is_in_group("element")):
		if have_fall_place and not Vector2(get_x_place()-1,get_y_place()+1) in GameData.taken_diagonal_spaces:
			return true
		elif result1 and result1[0].collider.is_in_group("element") and (result1[0].collider.can_fall_diagonally()):
			return true
	return false

func can_fall_diagonally_right():
	if get_y_place() < 0:
		return false
	var space_state = get_world_2d().direct_space_state
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = position+Vector2(+GameData.element_xsize,GameData.element_ysize)
	query2.collide_with_areas = true
	var result1 = space_state.intersect_point(query2)
	query2.position = position+Vector2(0,GameData.element_ysize)
	var result2 = space_state.intersect_point(query2)
	query2.position =position+Vector2(+GameData.element_xsize,0)
	var result3 = space_state.intersect_point(query2) # space above diag right
	var have_fall_place
	if (not result1 or result1[0].collider in GameData.falling_elements2 or result1[0].collider in GameData.diagonally_moving_pieces):
		have_fall_place = true
	if result2 and not (result3 and result3[0].collider.is_in_group("element")):
		if have_fall_place and not Vector2(get_x_place()+1,get_y_place()+1) in GameData.taken_diagonal_spaces:
			return true
		elif result1 and result1[0].collider.is_in_group("element") and (result1[0].collider.can_fall_diagonally()):
			return true
	return false

func can_fall_diagonally():
	return can_fall_diagonally_left() or can_fall_diagonally_right()

func element_below_left_exist(): # might need to leave this
	var space_state = get_world_2d().direct_space_state
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = position+Vector2(-GameData.element_xsize,GameData.element_ysize)
	query2.collide_with_areas = true
	var result1 = space_state.intersect_point(query2)
	if result1:# and result1[0].collider:# and result1[0].collider.is_in_group("element"):
		return true
	return false

func element_below_right_exist(): # and that
	var space_state = get_world_2d().direct_space_state
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = position+Vector2(GameData.element_xsize,GameData.element_ysize)
	query2.collide_with_areas = true
	var result1 = space_state.intersect_point(query2)
	if result1:# and result1[0].collider:# and result1[0].collider.is_in_group("element"):
		return true
	return false

func move_down(): # IGNORE
	var el = get_element_up()
	if el:
		el.move_down()
	tween = get_tree().create_tween()
	tween.tween_property(self, "position" , position + Vector2(0,GameData.element_ysize),0.1)
	await tween.finished
	original_position = position
	if not get_element_down():
		move_down()

func get_element_up(): # IGNORE
	var space_state = get_world_2d().direct_space_state
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = position+Vector2(0,-GameData.element_ysize)
	query2.collide_with_areas = true
	var result1 = space_state.intersect_point(query2)
	if result1:# and result1[0].collider:# and result1[0].collider.is_in_group("element"):
		if result1[0].collider.is_in_group("element"):
			return result1[0].collider
		else:
			result1[0].collider.create_element_at(-1)
			#result1[0].collider.spawn_element_at(get_x_place(),-1)
	return null

func get_element_down(): # IGNORE
	var space_state = get_world_2d().direct_space_state
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = position+Vector2(0,GameData.element_ysize)
	query2.collide_with_areas = true
	var result1 = space_state.intersect_point(query2)
	if result1:# and result1[0].collider:# and result1[0].collider.is_in_group("element"):
		return true
	else:
		return false

func get_wall_below():
	var space_state = get_world_2d().direct_space_state
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = position+Vector2(0,GameData.element_ysize)
	query2.collide_with_areas = true
	var result1 = space_state.intersect_point(query2)
	if result1 and result1[0].collider.is_in_group("wall"):
		return true
	else:
		return false


func get_wall_above():
	var space_state = get_world_2d().direct_space_state
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = position+Vector2(0,-GameData.element_ysize)
	query2.collide_with_areas = true
	var result1 = space_state.intersect_point(query2)
	if result1 and result1[0].collider.is_in_group("wall"):
		return true
	else:
		return false

func get_spawner_above():
	var space_state = get_world_2d().direct_space_state
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = position+Vector2(0,-GameData.element_ysize)
	query2.collide_with_areas = true
	var result1 = space_state.intersect_point(query2)
	if result1 and result1[0].collider.is_in_group("spawner"):
		return result1[0].collider
	else:
		return null
