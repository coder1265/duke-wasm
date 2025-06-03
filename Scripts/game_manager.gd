extends Node2D
var white_duke_preload = preload("res://Scenes/white_duke.tscn")
var black_duke_preload = preload("res://Scenes/black_duke.tscn")
@onready var white_duke_start_pos
var has_instantiated = false
#region

var white_footman = preload("res://Scenes/white_footman.tscn")
#var white_pikeman = preload()
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
func _process(delta: float) -> void:
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
	pass

func white_wins():
	print("White wins")

#endregion 

#region summoning
func summoned_a_piece(piece_to_make):
	print("Summoned a piece ", piece_to_make)
	if $"/root/Main".is_white_turn:
		if piece_to_make == "footman":
			var footman_scene = white_footman.instantiate()
			add_child(footman_scene)
			var footman_instantiate_pos = Vector2i(0,0)
			footman_scene.position = $"/root/Main/board_layer".map_to_local(footman_instantiate_pos)


#endregion
