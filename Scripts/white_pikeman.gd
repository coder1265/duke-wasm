extends Area2D

# need to implement strike capability
@onready var local_white_turn = get_node("/root/Main").is_white_turn
@onready var pikeman_pos
@onready var board = $"/root/Main/board_layer"
var movement_pos = preload("res://Scenes/move_holder.tscn")
var strike_img = preload("res://Scenes/Strike.tscn")
var mouse_entered_self: bool = false
var is_front_side: bool = true
var avaliable_moves = []
var checked_moves = []
var strike_positions: Array = []
var move_holder
var cell_size = 16
var show_pikeman_moves
var self_position
var min_left = -1
var min_right = 6
var min_top = -1
var min_bottom = 6
var possible_moves = []
var possible_moves_on_board = []
var placeable_locations = []
var unplaceable_locations = []
var checked_move_holders = []
var map_not_valid_locations = [] # locations local to the tilemap of all the white piece
var holder
var is_striking: bool = false

func _ready() -> void:
	pikeman_pos = board.local_to_map($".".global_position)
func _on_mouse_entered() -> void:
	mouse_entered_self = true
func _on_mouse_exited() -> void:
	mouse_entered_self = false

func _process(_delta: float) -> void:
	if is_front_side:
		$white_pikeman.animation = "front"
	else:
		$white_pikeman.animation = "back"

func _input(event):
	if Input.is_action_just_pressed("left_mouse_click"):
		if mouse_entered_self == true:
			local_white_turn = get_node("/root/Main").is_white_turn
			if local_white_turn == true:
				do_pikeman_moves(event)
		if show_pikeman_moves: # movement if clicked
			var x2 = checked_move_holders.map(func(element): return element + self_position)
			#print("This is x2 ",x2)
			if x2.has(Vector2i(get_global_mouse_position()/cell_size)):
				#print("Upto here quick check")
				self.position = (Vector2i(get_global_mouse_position()/cell_size)*cell_size)+Vector2i(8,8)
				if is_front_side:
					is_front_side = false
				else:
					is_front_side = true
				get_node("/root/Main").is_white_turn = false
		if is_striking:
			clicked_strike()
		if mouse_entered_self == false: # eliminate holders if clicked off it 
				for child in range($".".get_children().size()):
					if is_instance_of($".".get_children()[child],Area2D):
						$".".get_child(child).queue_free()
				show_pikeman_moves = false

func do_pikeman_moves(_event):
	get_pikeman_moves() # get avaliable moves in array
	check_tile_moves() # check avaliable moves array and return correct ones in new array
	white_pikeman_holders() # show holders in the array
	if is_front_side == false:
		strike_moves()
	#movement if clicked
	#hide if not clicked

func get_pikeman_moves():
	avaliable_moves.clear()
	if is_front_side:
		avaliable_moves = [
			Vector2i(1,-1), Vector2i(2,-2),Vector2i(-1,-1), Vector2i(-2,-2)
		]
	else:
		avaliable_moves = [
			Vector2i(0,-1), Vector2i(0,1),Vector2i(0,2)
		]
		#print("pikeman moves are", avaliable_moves)

func check_tile_moves():
	var white_pikeman = self.position
	self_position = board.local_to_map(white_pikeman)
	
	checked_moves.clear()
	for i in avaliable_moves:
		var new_coords = i + self_position
		if new_coords.x > min_left and new_coords.x < min_right and new_coords.y > min_top and new_coords.y < min_bottom:
			checked_moves.push_back(i) 
	#checked_moves.remove_at(checked_moves.find(Vector2i(0,0)))
	print("Checked avaliable moves are: ",checked_moves)
	var checked_move_holders1 = updates_moves_to_not_include_white_pieces(checked_moves)
	for i in checked_move_holders1:
		if is_front_side:
			if i == Vector2i(-2,-2):
				if not checked_move_holders1.has(Vector2i(-1,-1)):
					checked_move_holders1.erase(i)
			if i == Vector2i(2,-2):
				if not checked_move_holders1.has(Vector2i(1,-1)):
					checked_move_holders1.erase(i)
		elif is_front_side == false:
			if i == Vector2i(0,2):
				if not checked_move_holders1.has(Vector2i(0,1)):
					checked_move_holders1.erase(i)
	checked_move_holders = checked_move_holders1
	print("This is what we is working on, ",checked_move_holders1)
	print("This is checked move holders", checked_move_holders)
func white_pikeman_holders():
	for i in range(checked_move_holders.size()):
		var target_position = Vector2i(checked_move_holders[i]*cell_size) # Adding offset like you do for piece movement
		
		# Check if there's already an Area2D at this position
		if not is_position_occupied(target_position):
			move_holder = movement_pos.instantiate()
			move_holder.global_position = target_position
			add_child(move_holder)
	show_pikeman_moves = true

func is_position_occupied(world_position: Vector2) -> bool:
	var tilemap_pos = board.local_to_map(world_position)
	var all_areas = get_tree().get_nodes_in_group("white_pieces") + get_tree().get_nodes_in_group("black_pieces")
	for area in all_areas:
		if area is Area2D and area != self: # Don't check against self
			var area_tilemap_pos = board.local_to_map(area.global_position)
			if area_tilemap_pos == tilemap_pos:
				return true
	
	return false

	
func _on_area_entered(area: Area2D):
	if local_white_turn:
		if area.is_in_group("black_pieces"):
			area.queue_free()

func updates_moves_to_not_include_white_pieces(incoming_array_to_check):
	var x = self.position
	pikeman_pos = board.local_to_map(x)
	print("This is pikeman position", pikeman_pos)
	var valid_moves = []
	var active_pieces = get_tree().get_nodes_in_group("white_pieces") # gets all white piece objects including positions
	unplaceable_locations.clear()
	map_not_valid_locations.clear()
	for piece in active_pieces: # piece is each object in the group white_pieces, so all the white pieces ¬_¬
		if piece is Area2D:
			var world_pos = piece.global_position # returns in pixels 
			var white_piece_local_to_tilemap = board.local_to_map(world_pos) # converts to local to the tilemap
			map_not_valid_locations.append(white_piece_local_to_tilemap)
			print("This is map not valid locations", map_not_valid_locations)
			var white_piece_local_to_duke = white_piece_local_to_tilemap - pikeman_pos  # converts the tilemap locations to local to the duke by minusing the duke position of all the places, so effectively moves 0,0 to the dukes position
			unplaceable_locations.append(white_piece_local_to_duke)
	print("This is unplaceable locations, ",unplaceable_locations)
	for move in incoming_array_to_check: # this code checks the incoming array and compares it to the locations of the white pieces, if there is a white piece there it does not add it to the array
		if not unplaceable_locations.has(move):
			valid_moves.append(move)
	return valid_moves # returns the incoming array less the positions of other white piece (if there is any)

#region for striking code
func strike_moves():
	var x = self.position
	pikeman_pos = board.local_to_map(x)
 # declares strike positions
	strike_positions.clear()
	strike_positions = [
		Vector2i(1,-2), Vector2i(-1,-2)
	]
		# creates array to check strike positions against
	for i in strike_positions:
		var coord_to_map = i + pikeman_pos
		if coord_to_map.x > min_left or coord_to_map.x < min_right or coord_to_map.y > min_top or coord_to_map.y < min_bottom:
			strike_positions.erase(i)
	var new_array = [] # array of unmovable positions local to the pikeman
	var no_move_to = get_tree().get_nodes_in_group("white_pieces")
	for i in no_move_to:
		if i is Area2D:
			var pos = i.global_position
			var pos_to_map = board.local_to_map(pos) - pikeman_pos
			new_array.append(pos_to_map)
			#print("This is position of one piece", i)
	print("This is new_array", new_array)
	for i in strike_positions:
		if new_array.has(i):
			strike_positions.erase(i)
	#print("This is strike positions before board check", strike_positions)
	for i in range(strike_positions.size()):
		var target_position = Vector2i(strike_positions[i]*cell_size) # Adding offset like you do for piece movement
		# Check if there's already an Area2D at this position
		if not is_strike_occupied(target_position):
			var strike_holder = strike_img.instantiate()
			strike_holder.global_position = target_position
			add_child(strike_holder)
			is_striking = true
func is_strike_occupied(world_position) -> bool:
	var tilemap_pos = board.local_to_map(world_position)
	var all_areas = get_tree().get_nodes_in_group("white_pieces") + get_tree().get_nodes_in_group("black_pieces")
	for area in all_areas:
		if area is Area2D and area != self: # Don't check against self
			var area_tilemap_pos = board.local_to_map(area.global_position)
			if area_tilemap_pos == tilemap_pos:
				return true
	return false
func clicked_strike():
	var current_mouse_pos = board.local_to_map(get_global_mouse_position()) - pikeman_pos
	if strike_positions.has(current_mouse_pos):
		var enemy_areas = get_tree().get_nodes_in_group("black_pieces")
		for area in enemy_areas:
				var area_tilemap_pos = board.local_to_map(area.global_position) - pikeman_pos
				if area_tilemap_pos == current_mouse_pos:
					if area.name == "black_duke":
						$"..".white_wins()
					area.queue_free()
		if is_front_side:
			is_front_side = false
		else:
			is_front_side = true
		get_node("/root/Main").is_white_turn = false

#endregion
