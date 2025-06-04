extends Area2D

@onready var duke_pos = $"..".white_duke_start_pos
@onready var local_white_turn = get_node("/root/Main").is_white_turn
@onready var local_white_summon = get_node("/root/Main").is_white_summon
var cell_size = 16
var is_front: bool = true
var possible_moves = []
var mouse_entered_white_duke: bool = false
var active_move_holders = []
var move_coordinates
var holder
var is_holder_clicked = false
var show_moves
var show_summon_locations
var movement_pos = preload("res://Scenes/move_holder.tscn")
var summon_holder = preload("res://Scenes/summon_holder.tscn")
var summonable_pieces = ["footman","footman"]
var summoned_piece
var placeable_locations = []
var current_tile_pos
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
		if show_summon_locations:
			current_tile_pos = Vector2i(get_global_mouse_position()/cell_size)
			print("upto here in summoning")
			if placeable_locations.has(current_tile_pos):
				print("mouse clicked: ",current_tile_pos)
				clicked_summon()
				$"..".instantiate_location = current_tile_pos
				show_summon_locations = false
		if mouse_entered_white_duke == true:
			local_white_turn = get_node("/root/Main").is_white_turn
			if local_white_turn == true:
				#print("you clicked the white duke")
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

func get_summon_data():
	#print("White duke summoned")
	local_pos_to_map()
	#print("This is duke pos ", duke_pos)
	if duke_pos != null:
		var x9 = $"/root/Main/board_layer".get_surrounding_cells(duke_pos)
		print("This is array x9 ",x9)
	#print("This is local white summon ", local_white_summon)
		for i in x9:
			if i.x > -1 && i.x < 6 && i.y > -1 && i.y < 6:
				placeable_locations.append(i)
		print("This is placeable locations ",placeable_locations)
		
		for i in range(placeable_locations.size()):
			var summon_place = summon_holder.instantiate()
			add_child(summon_place)
			#summon_place.position = $"/root/Main/board_layer".map_to_local(Vector2i(placeable_locations[i]))
			summon_place.global_position = Vector2i(placeable_locations[i]*cell_size) + Vector2i(8,8)
			print("Summon place position", summon_place.position)
		show_summon_locations = true

func clicked_summon():
	print("Upto clicked summon")
	summoned_piece = summonable_pieces.pick_random()
	$"..".summoned_a_piece(summoned_piece,current_tile_pos)
	get_node("/root/Main").is_white_summon = false
	if is_front:
			is_front = false
	else:
			is_front = true
		

#region this region is for movement and capturing of the duke
func do_moves(_event):
	avaliable_moves()
	check_tile_moves()
	white_holders()

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

func _on_area_entered(area: Area2D):
	if local_white_turn:
		if area.is_in_group("black_pieces"):
			if area.name == "black_duke":
				$"..".white_wins()
			area.queue_free()
#endregion
