extends Area2D

signal dead # to destroy

var color = 0

var hor_same = 0
var ver_same = 0

var original_position

var selected:bool = false
@onready var tween:Tween 
@onready var element = preload("res://scenes/element_v3.tscn")


func _ready():
	GameData.falling_locs_calculated.connect(animate_falling)
	GameData.falling_diagonal_logs_calculated.connect(animate_falling)


func _physics_process(delta):
	pass

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

func swap(): # check for matches as if selected elements were swapped
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
	$AnimationPlayer.play("destroy")
	await $AnimationPlayer.animation_finished
	queue_free()

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

		# fall straight down
		for i in range(1): # get here falling_elements2 same in same row
			tween = get_tree().create_tween()
			tween.tween_property(self, "position" , position + Vector2(0,GameData.element_ysize),0.1)
			await tween.finished
			original_position = position
	return


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
	var result3 = space_state.intersect_point(query2) # space left
	
	var have_fall_place
	if (not result1 or result1[0].collider in GameData.falling_elements2 or result1[0].collider in GameData.diagonally_moving_pieces):
		have_fall_place = true
	if result2 and (result3 and not result3[0].collider.is_in_group("element") and not result3[0].collider.is_in_group("spawner")):
		if have_fall_place and not Vector2(get_x_place()-1,get_y_place()+1) in GameData.taken_diagonal_spaces:
			return true
		#elif result1 and result1[0].collider.is_in_group("element") and (result1[0].collider.can_fall_diagonally()):
		#	return true
	return false

func can_fall_diagonally_right():
	if get_y_place() < 0:
		return false
	var space_state = get_world_2d().direct_space_state
	var query2 = PhysicsPointQueryParameters2D.new()
	query2.position = position+Vector2(+GameData.element_xsize,GameData.element_ysize)
	query2.collide_with_areas = true
	var fall_space = space_state.intersect_point(query2) # fall space
	
	query2.position = position+Vector2(0,GameData.element_ysize)
	var space_down = space_state.intersect_point(query2) # space down
	
	query2.position =position+Vector2(+GameData.element_xsize,0)
	var space_right = space_state.intersect_point(query2) # space on the right right
	var have_fall_place
	if (not fall_space or fall_space[0].collider in GameData.falling_elements2 or fall_space[0].collider in GameData.diagonally_moving_pieces):
		have_fall_place = true
		
	if space_down and (space_right and not space_right[0].collider.is_in_group("element") and not space_right[0].collider.is_in_group("spawner")):
		if have_fall_place and not Vector2(get_x_place()+1,get_y_place()+1) in GameData.taken_diagonal_spaces:
			return true
		#elif fall_space and fall_space[0].collider.is_in_group("element") and (fall_space[0].collider.can_fall_diagonally()):
		#	return true
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
	if result1 and result1[0].collider.is_in_group("spawner") and not len(result1)>1:
		return result1[0].collider
	else:
		return null
