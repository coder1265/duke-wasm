extends Control

var wduke = preload("res://Scenes/white_duke.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta):
	display_data()
	show_clicked_imgs()

func display_data():
	if $"..".is_white_turn == true:
		$Turn_label.text = "It is white's turn"
	elif $"..".is_white_turn == false:
		$Turn_label.text = "It is black's turn"

func show_clicked_imgs():
	$Side1_Label.text = "Side 1"
	$Side2_Label.text = "Side 2"
	#if get_node("Piece Holder/white_duke").is_valid_instance():
		#print("White duke node is valid")
		#if wduke.mouse_entered_white_duke == true:
			#$Side1.texture = "res://Assets/white_king.png"
			#$Side2.texture = "res://Assets/white_knight.png"
	#else:
		#print("duke isn't valid instance")


func _on_summon_pressed():
	$"..".called_summon()

func _on_end_turn_pressed():
	$"..".end_turn()
