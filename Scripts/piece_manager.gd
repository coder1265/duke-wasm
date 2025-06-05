extends Node2D
var white_duke_preload = preload("res://Scenes/white_duke.tscn")
var black_duke_preload = preload("res://Scenes/black_duke.tscn")
@onready var white_duke_start_pos
var has_instantiated = false
var instantiate_location

@onready var board = $"/root/Main/board_layer"

#region preloading summon pieces

var white_footman = preload("res://Scenes/white_footman.tscn")
var white_pikeman = preload("res://Scenes/white_pikeman.tscn")
#var white_priest = preload()
#var white_assassin = preload()
#var white_champion = preload()
#var white_knight = preload()
#var white_bowman = preload()
#var white_longbowman = preload()
#var white_general = preload()
#var white_seer = preload()
#var white_wizard = preload()
#var white_ranger = preload()
#var white_marshal = preload()
#var white_dragoon = preload()
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()

func start_game():
	var white_duke_scene = white_duke_preload.instantiate()
	add_child(white_duke_scene)
	white_duke_start_pos = Vector2i(2,5)
	white_duke_scene.position = $"../board_layer".map_to_local(white_duke_start_pos)
	
	var black_duke_scene = black_duke_preload.instantiate()
	add_child(black_duke_scene)
	var black_duke_start_pos = Vector2i(3,0)
	black_duke_scene.position = $"../board_layer".map_to_local(black_duke_start_pos)
	has_instantiated = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	mousemappos()

func mousemappos():
	var the_mouse_position = get_global_mouse_position()
	var local_pos = $"../board_layer".local_to_map(the_mouse_position)
	if Input.is_action_just_pressed("left_mouse_click"):
		print(local_pos)


#region sort the winner code with kester later
#func is_winner():
	#var group = get_tree().get_nodes_in_group("active_pieces")
	#if str(group[0]) != "white_duke:<Area2D#26608665888>":
		#print("Black wins")
		#black_wins()
	#if str(group[1]) != "black_duke:<Area2D#26658997540>":
		#print("White wins")
		#white_wins()
	##print("black duke is still alive")
	##print(group)
	##print(get_tree().get_nodes_in_group("active_pieces").has("Piece Holder/white_duke"))

func black_wins():
	print("Black wins")
	emit_signal("black_winner")

func white_wins():
	emit_signal("white_winner")
	get_tree().change_scene_to_file("res://Scenes/win_screen.tscn")

#endregion 

#region summoning
func summoned_white():
	#print("Summoned white")
	var all_children = get_children()
	var found_duke
	for child in all_children:
		if child.name == "white_duke":
			found_duke = child
	if found_duke != null:
		found_duke.get_summon_data()
	

func summoned_black():
	print("You have summoned black piece")
	pass

func summoned_a_piece(piece_to_make,current_tile_pos):
	print("Summoned a piece ", piece_to_make)
	if $"/root/Main".is_white_turn:
		if piece_to_make == "footman":
			var footman_scene = white_footman.instantiate()
			add_child(footman_scene)
			#var footman_instantiate_pos = Vector2i(2,2)
			footman_scene.position = board.map_to_local(current_tile_pos)
			next_turn()
		if piece_to_make == "pikeman":
			var pikeman_scene = white_pikeman.instantiate()
			add_child(pikeman_scene)
			pikeman_scene.position = board.map_to_local(current_tile_pos)
	


#endregion

func next_turn():
	if $"/root/Main".is_white_turn:
		$"/root/Main".is_white_turn = false
	else:
		$"/root/Main".is_white_turn = true
var used_positions = []
#func get_used_positions() -> Array:
	## Get all Area2D nodes in the "active_pieces" group
	#var active_pieces = get_tree().get_nodes_in_group("active_pieces")
	#used_positions.clear()
	## For each active piece, convert its world position to tile coordinates
	#for piece in active_pieces:
		#if piece is Area2D:
			#var world_pos = piece.global_position
			#var tile_pos = board.local_to_map(world_pos)
			#used_positions.append(tile_pos)
	#return used_positions
