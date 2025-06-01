extends Area2D

@onready var duke_pos = $"..".white_duke_start_pos
var cell_size = 16
var is_front: bool = true
var possible_moves = []
var mouse_entered_white_duke: bool = false
var movement_pos = preload("res://Scenes/move_holder.tscn")
var active_move_holders = []
var move_coordinates
var holder
var is_holder_clicked = false
var show_moves
@onready var local_white_turn = get_node("/root/Main").is_white_turn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	white_duke_reset()
	pass

func white_duke_reset():
	pass

#region code to detect if the mouse is over the white duke changes mouse_entered_white_duke
func _on_mouse_entered():
	mouse_entered_white_duke = true
	#print("mouse enterd wduke")
func _on_mouse_exited():
	#print("mouse exited wduke")
	mouse_entered_white_duke = false
#endregion

func _input(event):
	if Input.is_action_just_pressed("left_mouse_click"):
		if mouse_entered_white_duke == true:
			local_white_turn = get_node("/root/Main").is_white_turn
			if local_white_turn == true:
				print("you clicked the white duke")
				do_moves(event)
		if show_moves:
			var x2 = active_move_holders.map(func(element): return element + duke_pos)
			if x2.has(Vector2i(get_global_mouse_position()/cell_size)):
				print("new position is: ",Vector2i(get_global_mouse_position()/cell_size))
				self.position = (Vector2i(get_global_mouse_position()/cell_size)*cell_size)+Vector2i(8,8)
				if is_front:
					is_front = false
				else:
					is_front = true
				get_node("/root/Main").is_white_turn = false
				
		if mouse_entered_white_duke == false:
				for child in range($".".get_children().size()):
					if is_instance_of($".".get_children()[child],Area2D):
						$".".get_child(child).queue_free()
				show_moves = false
	#before restructuring
	#if mouse_entered_white_duke == true:
		#if Input.is_action_just_pressed("left_mouse_click"):
			#local_white_turn = get_node("/root/Main").is_white_turn
			#if local_white_turn == true:
				#print("you clicked the white duke")
				#do_moves(event)
	#if Input.is_action_just_pressed("left_mouse_click") and active_move_holders.has(Vector2i(get_global_mouse_position()/cell_size)):
		#print("oi")
		#pass
	#if mouse_entered_white_duke == false:
		#if Input.is_action_just_pressed("left_mouse_click"):
			#for child in range($".".get_children().size()):
				#if is_instance_of($".".get_children()[child],Area2D):
					#$".".get_child(child).queue_free()



func do_moves(event):
	avaliable_moves()
	check_tile_moves()
	white_holders()
	#movement / capture

func avaliable_moves():
	possible_moves.clear() # clears any possible moves
	if is_front == true:
		for i in range(0,11):
			var x_coord = i-5
			possible_moves.push_back(Vector2i(x_coord,0))
	if is_front == false:
		for i in range(0,11):
			var y_coord = i-5
			possible_moves.push_back(Vector2i(0,y_coord))
	print("Possible moves ", possible_moves)

func check_tile_moves():
	local_pos_to_map()
	active_move_holders.clear()
	for iterable in possible_moves:
		var umm = iterable + duke_pos
		if umm.x > -1 and umm.x < 6 and umm.y > -1 and umm.y < 6:
			active_move_holders.push_back(iterable) 
	active_move_holders.remove_at(active_move_holders.find(Vector2i(0,0)))
	print("Possible moves are: ",active_move_holders)

func local_pos_to_map():
	var x1 = get_tree().get_nodes_in_group("board")
	var white_duke_position = self.position
	duke_pos = x1[0].local_to_map(white_duke_position)

func white_holders():
	for i in range(active_move_holders.size()):
		holder = movement_pos.instantiate()
		holder.global_position = Vector2i(active_move_holders[i]*cell_size)
		add_child(holder)
	show_moves = true
	#for i:Vector2 in active_move_holders:
		#holder = movement_pos.instantiate()
		#holder.global_position = Vector2(i.x * cell_size, i.y * cell_size)
		#add_child(holder)

func _on_area_entered(area: Area2D):
	if local_white_turn:
		if area.is_in_group("black_pieces"):
			#print("It's a black piece")
			if area.name == "black_duke":
				#print("on the black duke")
				$"..".white_wins()
			area.queue_free()
