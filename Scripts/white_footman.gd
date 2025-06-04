extends Area2D

@onready var local_white_turn = get_node("/root/Main").is_white_turn
var mouse_entered_footman: bool = false
var is_front_side = false
var avaliable_moves = []
var checked_moves = []
var movement_pos = preload("res://Scenes/move_holder.tscn")
var move_holder
var cell_size = 16
var show_footman_moves
var self_position

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
	var tilemap_reference = get_tree().get_nodes_in_group("board")
	var white_footman_position = self.position
	self_position = tilemap_reference[0].local_to_map(white_footman_position)
	
	checked_moves.clear()
	for i in avaliable_moves:
		var new_coords = i + self_position
		if new_coords.x > -1 and new_coords.x < 6 and new_coords.y > -1 and new_coords.y < 6:
			checked_moves.push_back(i) 
	#checked_moves.remove_at(checked_moves.find(Vector2i(0,0)))
	print("Checked avaliable moves are: ",checked_moves)

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
