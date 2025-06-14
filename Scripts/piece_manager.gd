extends Node2D
var white_duke_preload = preload("res://Scenes/white_duke.tscn")
var black_duke_preload = preload("res://Scenes/black_duke.tscn")
@onready var white_duke_start_pos
@onready var black_duke_start_pos
var white_duke_scene
var black_duke_scene
var has_instantiated = false
var instantiate_location
var white_duke
var black_duke
var summon_move_checker:bool = false
var startup_senario:Array = [1,2] # do this later

@onready var board = $"/root/Main/board_layer"

#region preloading summon pieces

var white_footman = preload("res://Scenes/white_pieces/white_footman.tscn")
var white_pikeman = preload("res://Scenes/white_pieces/white_pikeman.tscn")
var white_priest = preload("res://Scenes/white_pieces/priest.tscn")
var white_assassin = preload("res://Scenes/white_pieces/assassin.tscn")
var white_champion = preload("res://Scenes/white_pieces/champion.tscn")
#var white_knight = preload()
#var white_bowman = preload()
#var white_longbowman = preload()
#var white_general = preload()
var white_seer = preload("res://Scenes/white_pieces/seer.tscn")
var white_wizard = preload("res://Scenes/white_pieces/wizard.tscn")
#var white_ranger = preload()
#var white_marshal = preload()
#var white_dragoon = preload()
var black_footman = preload("res://Scenes/black_pieces/black_footman.tscn")
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game()

func start_game():
	white_duke_scene = white_duke_preload.instantiate()
	add_child(white_duke_scene)
	white_duke_start_pos = Vector2i(2,5)
	white_duke_scene.position = $"../board_layer".map_to_local(white_duke_start_pos)
	var all_children = self.get_children()
	print("This is current all children", all_children)
	#var white_duke_connect = $"./white_dule"
	#print("This is white duke connect", white_duke_connect)
	#white_duke_connect.tree_exiting.connect(black_wins())
	white_scenarios()
	
	black_duke_scene = black_duke_preload.instantiate()
	add_child(black_duke_scene)
	black_duke_start_pos = Vector2i(3,0)
	black_duke_scene.position = $"../board_layer".map_to_local(black_duke_start_pos)
	has_instantiated = true
	black_scenarios()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var the_mouse_position = get_global_mouse_position()
	var local_pos = $"../board_layer".local_to_map(the_mouse_position)
	if Input.is_action_just_pressed("left_mouse_click"):
		print(local_pos)
	if has_instantiated:
		var white = get_tree().get_nodes_in_group("white_duke")
		var black = get_tree().get_nodes_in_group("black_duke")
		if white.size() == 0:
			black_wins()
		if black.size() == 0:
			white_wins()

func white_scenarios():
	var place_1 = startup_senario.pick_random()
	var footman_scene = white_footman.instantiate()
	var footman_start_pos = Vector2i(2,4)
	footman_scene.position = board.map_to_local(footman_start_pos)
	add_child(footman_scene)
	if place_1 == 1:
		var footman_scene1 = white_footman.instantiate()
		var footman_start_pos1 = Vector2i(1,5)
		footman_scene1.position = board.map_to_local(footman_start_pos1)
		add_child(footman_scene1)
	elif place_1 == 2:
		var footman_scene2 = white_footman.instantiate()
		var footman_start_pos2 = Vector2i(3,5)
		footman_scene2.position = board.map_to_local(footman_start_pos2)
		add_child(footman_scene2)

func black_scenarios():
	var place_b = startup_senario.pick_random()
	var footman_scene = black_footman.instantiate()
	var footman_start_pos = Vector2i(3,1)
	footman_scene.position = board.map_to_local(footman_start_pos)
	add_child(footman_scene)
	if place_b == 1:
		var footman_scene1 = black_footman.instantiate()
		var footman_start_pos1 = Vector2i(4,0)
		footman_scene1.position = board.map_to_local(footman_start_pos1)
		add_child(footman_scene1)
	elif place_b == 2:
		var footman_scene2 = black_footman.instantiate()
		var footman_start_pos2 = Vector2i(2,0)
		footman_scene2.position = board.map_to_local(footman_start_pos2)
		add_child(footman_scene2)

#region sort the winner code with kester later

			
func black_wins():
	print("Black wins")

func white_wins():
	print("white_wins")
	#get_tree().change_scene_to_file("res://Scenes/win_screen.tscn")

#endregion 

#region summoning
func summoned_white():
	#print("Summoned white")
	var all_children = get_children()
	for child in all_children:
		if child.name == "white_duke":
			white_duke = child
	if white_duke != null:
		summon_move_checker = true
		white_duke.get_summon_data()

func summoned_black():
	print("You have summoned black piece")
	var all_children = get_children()
	for child in all_children:
		if child.name == "black_duke":
			black_duke = child
	if black_duke != null:
		summon_move_checker = true
		black_duke.get_summon_data()


func summoned_a_piece(piece_to_make):
	print("Summoned a piece ", piece_to_make, "Coordinates of piece are", instantiate_location)
	if $"/root/Main".is_white_turn:
		if instantiate_location != null:
			if piece_to_make == "footman":
				var footman_scene = white_footman.instantiate()
				add_child(footman_scene)
				#var footman_instantiate_pos = Vector2i(2,2)
				footman_scene.position = board.map_to_local(instantiate_location)
				next_turn()
			if piece_to_make == "pikeman":
				var pikeman_scene = white_pikeman.instantiate()
				add_child(pikeman_scene)
				pikeman_scene.position = board.map_to_local(instantiate_location)
				next_turn()
			if piece_to_make == "champion":
				var champion_scene = white_champion.instantiate()
				add_child(champion_scene)
				champion_scene.position = board.map_to_local(instantiate_location)
			if piece_to_make == "seer":
				var seer_scene = white_seer.instantiate()
				add_child(seer_scene)
				seer_scene.position = board.map_to_local(instantiate_location)
			if piece_to_make == "wizard":
				var wizard_scene = white_wizard.instantiate()
				add_child(wizard_scene)
				wizard_scene.position = board.map_to_local(instantiate_location)
			if piece_to_make == "assassin":
				var assassin_scene = white_assassin.instantiate()
				add_child(assassin_scene)
				assassin_scene.position = board.map_to_local(instantiate_location)
			if piece_to_make == "priest":
				var priest_scene = white_priest.instantiate()
				add_child(priest_scene)
				priest_scene.position = board.map_to_local(instantiate_location)
		elif instantiate_location == null:
			summon_move_checker = false
#endregion

func next_turn():
	if $"/root/Main".is_white_turn:
		$"/root/Main".is_white_turn = false
	else:
		$"/root/Main".is_white_turn = true

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_mouse_click"):
		print("This is white turn variable ",$"/root/Main".is_white_turn)
