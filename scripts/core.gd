extends Node2D

func _input(event):
	if Input.is_action_just_pressed("click") and not GameData.disable_clicked:
		var space_state = get_world_2d().direct_space_state
		var p1 = get_global_mouse_position()
		var query1 = PhysicsPointQueryParameters2D.new()
		query1.position = p1
		query1.collide_with_areas = true
		var result1 = space_state.intersect_point(query1)
		if result1:
			print("somethinghs there", query1.position)
			var q = result1[0].collider
			q.clicked()
	elif Input.is_action_just_pressed("right_click") and not GameData.disable_clicked:
		var space_state = get_world_2d().direct_space_state
		var p1 = get_global_mouse_position()
		var query1 = PhysicsPointQueryParameters2D.new()
		query1.position = p1
		query1.collide_with_areas = true
		var result1 = space_state.intersect_point(query1)
		if result1:
			print("somethinghs there", query1.position)
			var q = result1[0].collider
			var p2 = Vector2(0,-2*GameData.element_ysize) + q.position
			var p_1 = Vector2(0,-GameData.element_ysize) + q.position
			#var w = q.get_same_up()
			q.print_same(p_1,p2)
			print(q.get_same_up())
	if Input.is_action_just_pressed("ui_cancel"):
		pass
