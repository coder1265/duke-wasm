extends Area2D
@onready var board = $"/root/Main/board_layer"
@onready var move = preload("res://Scenes/move_holder.tscn")
@onready var game = preload("res://Scenes/Main_Game.tscn")

var mouse_entered_self:bool = false
var is_striking:bool = false
var showing_moves:bool = false
var is_front:bool = true
var position_on_board:Vector2i
var cell_size:int = 16
@onready var min_left = get_node("/root/Main").min_left
@onready var min_right = get_node("/root/Main").min_right
@onready var min_top = get_node("/root/Main").min_top
@onready var min_bottom = get_node("/root/Main").min_bottom
var move_array:Array = []
var jump_array:Array = []

func _on_mouse_entered() -> void:
	mouse_entered_self = true
func _on_mouse_exited() -> void:
	mouse_entered_self = false

func _input(_event):
	if Input.is_action_just_pressed("left_mouse_click"):
		if mouse_entered_self:
			var is_white = get_node("/root/Main").is_white_turn
			if is_white:
				do_moves()
		if showing_moves:
			print("This is showing_moves",showing_moves)
			clicked_moves()
		if mouse_entered_self == false:
				hide_children()
				showing_moves = false

func do_moves():
	move_array.clear()
	jump_array.clear()
	if is_front:
		jump_array = [
			Vector2i(1,1),Vector2i(2,2),Vector2i(3,3),Vector2i(4,4),Vector2i(5,5),Vector2i(6,6),
			Vector2i(-1,1),Vector2i(-2,2),Vector2i(-3,3),Vector2i(-4,4),Vector2i(-5,5),Vector2i(-6,6),
			Vector2i(1,-1),Vector2i(2,-2),Vector2i(3,-3),Vector2i(4,-4),Vector2i(5,-5),Vector2i(6,-6),
			Vector2i(-1,-1),Vector2i(-2,-2),Vector2i(-3,-3),Vector2i(-4,-4),Vector2i(-5,-5),Vector2i(-6,-6)
		]
	elif is_front == false:
		jump_array = [
			Vector2i(1,1),Vector2i(2,2),
			Vector2i(-1,1),Vector2i(-2,2),
			Vector2i(1,-1),Vector2i(2,-2),
			Vector2i(-1,-1),Vector2i(-2,-2),
		]
	position_on_board = board.local_to_map(self.global_position)
	print("Position on the board is ",position_on_board)
	do_jump()
	show_locations()

func do_jump():
		#checks if moves local to the seer are on the board
	var check_array3 = []
	for i in jump_array:
		var new_pos = i + position_on_board
		if new_pos.x > min_left and new_pos.x < min_right and new_pos.y > min_top and new_pos.y < min_bottom:
			check_array3.append(i)
	var x = check_location(check_array3)
	#var y:Array = []
	#for i in x:
		#var z = i - position_on_board
		#y.append(z)
	jump_array = x
	print("This is final jump array ",jump_array)

func check_location(array):
	# checks if any of the moves are on the location of a white piece
	var check_array2 = []
	var all_white_pieces = get_tree().get_nodes_in_group("white_pieces")
	for i in all_white_pieces:
		if i is Area2D and i != self:
			var i_pos = board.local_to_map(i.global_position) - position_on_board
			check_array2.append(i_pos)
	print("This is the array of places where you can't move", check_array2)
	print("This is incoming array ", array)
	var return_array = []
	for a in check_array2:
		if array.has(a):
			return_array.append(a)
	return return_array

func show_locations():
	if jump_array != null:
		#if is_front:
		print("This is the instantiated jump array", jump_array)
		for i in jump_array:
			var jump_scene = move.instantiate()
			jump_scene.global_position = i * cell_size
			add_child(jump_scene)
		showing_moves = true
	else:
		print("An array is null")

func clicked_moves():
	var current_mouse_pos = board.local_to_map(get_global_mouse_position()) - position_on_board
	print("This is current mouse position for movement click", current_mouse_pos)
	var combined_array:Array = []
	combined_array = move_array + jump_array
	if combined_array.has(current_mouse_pos):
		var enemy_areas = get_tree().get_nodes_in_group("black_pieces")
		for area in enemy_areas:
				var area_tilemap_pos = board.local_to_map(area.global_position) - position_on_board
				if area_tilemap_pos == current_mouse_pos:
					area.queue_free()
		#var current_pos = position_on_board
		self.position = board.map_to_local(current_mouse_pos + position_on_board)
		next_turn()

func next_turn():
	if is_front:
		is_front = false
		$priest.play("back")
	else:
		is_front = true
		$priest.play("front")
	get_node("/root/Main").is_white_turn = false
	#change_turn()

func hide_children():
	for child in range($".".get_children().size()):
		if is_instance_of($".".get_children()[child],Area2D):
			$".".get_child(child).queue_free()

#func white_winner():
	#$"..".white_wins()
