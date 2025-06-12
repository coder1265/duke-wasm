extends Area2D

@onready var local_white_turn = get_node("/root/Main").is_white_turn
@onready var board = $"/root/Main/board_layer"
var mouse_entered_footman: bool = false
var is_front_side = false
var avaliable_moves = []
var checked_moves = []
var movement_pos = preload("res://Scenes/move_holder.tscn")
var move_holder
var cell_size = 16
var show_footman_moves
var self_position
var min_left = -1
var min_right = 6
var min_top = -1
var min_bottom = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_mouse_entered() -> void:
	mouse_entered_footman = true
func _on_mouse_exited() -> void:
	mouse_entered_footman = false

func _input(event):
	if Input.is_action_just_pressed("left_mouse_click"):
		if mouse_entered_footman == true:
			local_white_turn = get_node("/root/Main").is_white_turn
			if local_white_turn == true:
				do_footman_moves(event)
		if show_footman_moves: # movement if clicked
			var x2 = checked_moves.map(func(element): return element + self_position)
			#print("This is x2 ",x2)
			if x2.has(Vector2i(get_global_mouse_position()/cell_size)):
				#print("Upto here quick check")
				self.position = (Vector2i(get_global_mouse_position()/cell_size)*cell_size)+Vector2i(8,8)
				if is_front_side:
					is_front_side = false
				else:
					is_front_side = true
				get_node("/root/Main").is_white_turn = false
		if mouse_entered_footman == false: # eliminate holders if clicked off it 
				for child in range($".".get_children().size()):
					if is_instance_of($".".get_children()[child],Area2D):
						$".".get_child(child).queue_free()
				show_footman_moves = false

func do_footman_moves(_event):
	get_footman_moves() # get avaliable moves in array
	check_tile_moves() # check avaliable moves array and return correct ones in new array
	white_footman_holders() # show holders in the array
	#movement if clicked
	#hide if not clicked

func get_footman_moves():
	avaliable_moves.clear()
	if is_front_side:
		avaliable_moves = [
			Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)
		]
	else:
		avaliable_moves = [
			Vector2i(1,1), Vector2i(1,-1),Vector2i(0,-2), Vector2i(-1,1), Vector2i(-1,-1)
		]
		#print("Footman moves are", avaliable_moves)

func check_tile_moves():
	var white_footman_position = self.position
	self_position = board.local_to_map(white_footman_position)
	
	checked_moves.clear()
	for i in avaliable_moves:
		var new_coords = i + self_position
		if new_coords.x > min_left and new_coords.x < min_right and new_coords.y > min_top and new_coords.y < min_bottom:
			checked_moves.push_back(i) 
	#checked_moves.remove_at(checked_moves.find(Vector2i(0,0)))
	var white_piece_locations = get_tree().get_nodes_in_group("white_pieces")
	var delete_from_checked_moves = []
	for i in white_piece_locations:
		if i is Area2D and i != self:
			var area_tilemap_pos = board.local_to_map(i.global_position) - self_position
			delete_from_checked_moves.append(area_tilemap_pos)
	for i in checked_moves:
		if delete_from_checked_moves.has(i):
			checked_moves.erase(i)
	
	

func white_footman_holders():
	for i in range(checked_moves.size()):
		move_holder = movement_pos.instantiate()
		move_holder.global_position = Vector2i(checked_moves[i]*cell_size)
		add_child(move_holder)
	show_footman_moves = true
	
func _on_area_entered(area: Area2D):
	if local_white_turn:
		if area.is_in_group("black_pieces"):
			if area.name == "black_duke":
				$"..".white_wins()
			area.queue_free()
