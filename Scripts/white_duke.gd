extends Area2D

@onready var duke_pos = $"..".white_duke_start_pos
@onready var local_white_turn = get_node("/root/Main").is_white_turn
@onready var local_white_summon = get_node("/root/Main").is_white_summon
@onready var board = $"/root/Main/board_layer"
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
var summonable_pieces = ["footman","footman","pikeman"]
var summoned_piece
var placeable_locations = []
var unplaceable_locations = []
var current_tile_pos
var checked_move_holders = []
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
			#print("upto here in summoning")
			if placeable_locations.has(current_tile_pos):
				#print("mouse clicked: ",current_tile_pos)
				clicked_summon()
				$"..".instantiate_location = current_tile_pos
				show_summon_locations = false
		if mouse_entered_white_duke == true:
			local_white_turn = get_node("/root/Main").is_white_turn
			if local_white_turn == true:
				#print("you clicked the white duke")
				do_moves(event)
		if show_moves: # movement code
			var x2 = checked_move_holders.map(func(element): return element + duke_pos)
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
	if summonable_pieces.size() > 0:
		local_pos_to_map()
		if duke_pos != null:
			var x9 = $"/root/Main/board_layer".get_surrounding_cells(duke_pos)
			placeable_locations.clear()
			for i in x9:
				if i.x > -1 && i.x < 6 && i.y > -1 && i.y < 6:
					placeable_locations.append(i)
			print("This is placeable locations ",placeable_locations)
			
		
			var new_positions = cant_move_there(placeable_locations)
			
			print("This is new positions", new_positions)
			for i in range(new_positions.size()):
				var summon_place = summon_holder.instantiate()
				add_child(summon_place)
				#summon_place.position = $"/root/Main/board_layer".map_to_local(Vector2i(placeable_locations[i]))
				summon_place.global_position = Vector2i(new_positions[i]*cell_size) + Vector2i(8,8)
			show_summon_locations = true
	else:
		print("Can't summon")
		# implement function to state on information board that you can't summon
func cant_move_there(x):
	get_used_positions()
	var valid_moves = []
	for move in x:
		if not unplaceable_locations.has(move):
			valid_moves.append(move)
	return valid_moves
		#print("these are used positions - can't move there", unplaceable_locations)
		#print("This is valid moves", valid_moves)

func clicked_summon():
	summoned_piece = summonable_pieces.pick_random()
	summonable_pieces.erase(summoned_piece)
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
	checked_move_holders = cant_move_there(active_move_holders)
	print("This is active move holders", checked_move_holders)


func local_pos_to_map():
	var x1 = get_tree().get_nodes_in_group("board")
	var white_duke_position = self.position
	duke_pos = x1[0].local_to_map(white_duke_position)

func white_holders():
	for i in range(checked_move_holders.size()):
		holder = movement_pos.instantiate()
		holder.global_position = Vector2i(checked_move_holders[i]*cell_size)
		add_child(holder)
	show_moves = true

func _on_area_entered(area: Area2D):
	if local_white_turn:
		if area.is_in_group("black_pieces"):
			if area.name == "black_duke":
				$"..".white_wins()
			area.queue_free()
#endregion

func get_used_positions() -> Array:
	# Get all Area2D nodes in the "active_pieces" group
	var active_pieces = get_tree().get_nodes_in_group("active_pieces")
	unplaceable_locations.clear()
	# For each active piece, convert its world position to tile coordinates
	for piece in active_pieces:
		if piece is Area2D:
			var world_pos = piece.global_position
			#print("World pos of the pieces", world_pos)
			var tile_pos1 = board.local_to_map(world_pos)
			var tile_pos2 = tile_pos1 - duke_pos
			#print("Tile pos 1 - aka local to the tilemap ", tile_pos1)
			#need to convert to local to the duke player
			#var tile_pos = board.map_to_local(tile_pos1/cell_size)
			#print("Tile pos 2 ", tile_pos)
			unplaceable_locations.append(tile_pos2)
	print("This is unplaceable locations", unplaceable_locations)
	return unplaceable_locations
