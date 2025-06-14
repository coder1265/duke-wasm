extends Area2D

@onready var board = $"/root/Main/board_layer"
@onready var strike = preload("res://Scenes/Strike.tscn")
@onready var move = preload("res://Scenes/move_holder.tscn")
@onready var game = preload("res://Scenes/Main_Game.tscn")

var mouse_entered_self:bool = false
var is_striking:bool = false
var showing_moves:bool = false
var is_front:bool = true
var position_on_board:Vector2i
var cell_size:int = 16
var min_left = -1
var min_right = 6
var min_top = -1
var min_bottom = 6
var move_array:Array = []
var jump_array:Array = []
var strike_array:Array = []

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
		if is_striking:
			clicked_striking()
		if mouse_entered_self == false:
				hide_children()
				showing_moves = false

func do_moves():
	# get side, #get movement array
	#strike function as well, check within board
	# get white pieces, check white pieces, return correct array, check for movement 
	#delete nodes if capturing
	move_array.clear()
	strike_array.clear()
	jump_array.clear()
	if is_front:
		move_array = [
			Vector2i(1,0),Vector2i(-1,0),Vector2i(0,-1),Vector2i(0,1)
		]
		jump_array = [
			Vector2i(2,0),Vector2i(-2,0),Vector2i(0,-2),Vector2i(0,2)
		]
	elif is_front == false:
		jump_array = [
			Vector2i(2,0),Vector2i(-2,0),Vector2i(0,-2),Vector2i(0,2)
		]
		strike_array = [
			Vector2i(1,0),Vector2i(-1,0),Vector2i(0,-1),Vector2i(0,1)
		]
	position_on_board = board.local_to_map(self.global_position)
	print("Position on the board is ",position_on_board)
	do_move()
	do_jump()
	do_strike()
	show_locations()

func do_move():
	#checks if moves local to the champion are on the board
	var check_array = []
	for i in move_array:
		var new_pos = i + position_on_board
		if new_pos.x > min_left and new_pos.x < min_right and new_pos.y > min_top and new_pos.y < min_bottom:
			check_array.append(i)
	print("This is check array ", check_array)
	var x:Array = check_location(check_array)
	#var y:Array = []
	#for i in x:
		#var z = i - position_on_board
		#y.append(z)
	#move_array = y
	move_array = x
	print("This is final movement array ",move_array)

func do_jump():
		#checks if moves local to the champion are on the board
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

func do_strike():
	if is_front == false:
			#checks if moves local to the champion are on the board
		var check_array = []
		for i in strike_array:
			var new_pos = i + position_on_board
			if new_pos.x > min_left and new_pos.x < min_right and new_pos.y > min_top and new_pos.y < min_bottom:
				check_array.append(i)
		#strike_array = check_array
		var x = check_location(check_array)
		print("This is x",x)
		#var y:Array = []
		#for i in x:
			#var z = i - position_on_board
			#y.append(z)
		strike_array = x
		print("This is final strike array ",strike_array)

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
	for a in check_array2:
		if array.has(a):
			print("Found this", a)
			array.erase(a)
	print("This is returning array", array)
	return array

func show_locations():
	if move_array != null:
		if is_front:
			print("This is the instantiated movement array", move_array)
			for i:Vector2i in move_array:
				var move_scene = move.instantiate()
				move_scene.global_position = cell_size * i
				add_child(move_scene)
	if jump_array != null:
		if is_front:
			print("This is the instantiated jump array", jump_array)
			for i in jump_array:
				var jump_scene = move.instantiate()
				jump_scene.global_position = i * cell_size
				add_child(jump_scene)
	if strike_array != null:
		if is_front == false:
			print("This is the instantiated strike array", strike_array)
			for i in strike_array:
				var strike_scene = strike.instantiate()
				strike_scene.global_position = i * cell_size
				add_child(strike_scene)
				is_striking = true
	if jump_array != null:
		if is_front == false:
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
	if is_front:
		combined_array = move_array + jump_array
	elif is_front == false:
		combined_array = jump_array
	if combined_array.has(current_mouse_pos):
		var enemy_areas = get_tree().get_nodes_in_group("black_pieces")
		for area in enemy_areas:
				var area_tilemap_pos = board.local_to_map(area.global_position) - position_on_board
				if area_tilemap_pos == current_mouse_pos:
					area.queue_free()
		#var current_pos = position_on_board
		self.position = board.map_to_local(current_mouse_pos + position_on_board)
		next_turn()

func clicked_striking():
	var current_mouse_pos = board.local_to_map(get_global_mouse_position()) - position_on_board
	if strike_array.has(current_mouse_pos):
		var enemy_areas = get_tree().get_nodes_in_group("black_pieces")
		for area in enemy_areas:
			var area_tilemap_pos = board.local_to_map(area.global_position) - position_on_board
			if area_tilemap_pos == current_mouse_pos:
				area.queue_free()
				next_turn()

func next_turn():
	if is_front:
		is_front = false
		$AnimatedSprite2D.play("back")
	else:
		is_front = true
		$AnimatedSprite2D.play("front")
	call_deferred("x10")
func x10():
	$"/root/Main".is_white_turn = false

func hide_children():
	for child in range($".".get_children().size()):
		if is_instance_of($".".get_children()[child],Area2D):
			$".".get_child(child).queue_free()

#func white_winner():
	#$"..".white_wins()
