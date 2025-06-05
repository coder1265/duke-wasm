extends Control

var main = preload("res://Scripts/main_game.gd")
@onready var turn = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if turn:
		$RichTextLabel.text = "White wins"
	else:
		$RichTextLabel.text = "Black wins"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("left_mouse_click"):
		$particles_left.emitting = true
		$particles_right.emitting= true


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main_Game.tscn")
