extends Area2D

# need to implement strike capability
@onready var local_white_turn = get_node("/root/Main").is_white_turn
var mouse_entered_self: bool = false
var is_front_side: bool = true
var avaliable_moves = []
var checked_moves = []
var movement_pos = preload("res://Scenes/move_holder.tscn")
var move_holder
var cell_size = 16
var show_pikeman_moves
var self_position

func _on_mouse_entered() -> void:
	mouse_entered_self = true
func _on_mouse_exited() -> void:
	mouse_entered_self = false

func _process(delta: float) -> void:
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
		if mouse_entered_self == false: # eliminate holders if clicked off it 
				for child in range($".".get_children().size()):
					if is_instance_of($".".get_children()[child],Area2D):
						$".".get_child(child).queue_free()
				show_pikeman_moves = false

func do_pikeman_moves(_event):
	get_pikeman_moves() # get avaliable moves in array
	check_tile_moves() # check avaliable moves array and return correct ones in new array
	white_pikeman_holders() # show holders in the array
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
	var tilemap_reference = get_tree().get_nodes_in_group("board")
	var white_pikeman = self.position
	self_position = tilemap_reference[0].local_to_map(white_pikeman)
	
	checked_moves.clear()
	for i in avaliable_moves:
		var new_coords = i + self_position
		if new_coords.x > -1 and new_coords.x < 6 and new_coords.y > -1 and new_coords.y < 6:
			checked_moves.push_back(i) 
	#checked_moves.remove_at(checked_moves.find(Vector2i(0,0)))
	print("Checked avaliable moves are: ",checked_moves)

func white_pikeman_holders():
	for i in range(checked_moves.size()):
		move_holder = movement_pos.instantiate()
		move_holder.global_position = Vector2i(checked_moves[i]*cell_size)
		add_child(move_holder)
	show_pikeman_moves = true
	
func _on_area_entered(area: Area2D):
	if local_white_turn:
		if area.is_in_group("black_pieces"):
			if area.name == "black_duke":
				$"..".white_wins()
			area.queue_free()
