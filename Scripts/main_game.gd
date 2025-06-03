extends Node2D


var is_white_turn: bool = true
var is_white_summon = false
var is_black_summon = false
var selected_piece
var mouse_position
@onready var global_tilemaplayer_ref = $board_layer
var main_layer_id
	
# Called when the node enters the scene tree for the first time.
func _ready():
	print("Tilemap object is ", global_tilemaplayer_ref)
	main_layer_id = self.get_instance_id()
	print("Global singleton ID: ", main_layer_id)
	# Find the node in the current scene
	var main_scene = get_tree().current_scene
	print("Tilemap object 2 is ", global_tilemaplayer_ref)

func end_turn():
	if is_white_turn:
		is_white_turn = false
	else:
		is_white_turn = true

func called_summon():
	print("Summon stage 2")
	is_white_summon = true
