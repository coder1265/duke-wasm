extends Node2D


var is_white_turn: bool = true
var is_white_summon = false
var is_black_summon = false
var selected_piece
var mouse_position
@onready var global_tilemaplayer_ref = $board_layer
var main_layer_id
var min_left:int = -1
var min_right:int = 6
var min_top:int = -1
var min_bottom:int = 6
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#print("Tilemap object is ", global_tilemaplayer_ref)
	#main_layer_id = self.get_instance_id()
	#print("Global singleton ID: ", main_layer_id)
	## Find the node in the current scene
	#var main_scene = get_tree().current_scene
	#print("Tilemap object 2 is ", global_tilemaplayer_ref)

func end_turn():
	if is_white_turn:
		is_white_turn = false
	else:
		is_white_turn = true

func called_summon():
	if is_white_turn:
		is_white_summon = true
		$"Piece Holder".summoned_white()
	else:
		is_black_summon = true
		$"Piece Holder".summoned_black()
