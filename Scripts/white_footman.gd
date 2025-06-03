extends Area2D

var mouse_entered_footman: bool = false
var is_front_side = false
var avaliable_moves = []
var checked_moves = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_mouse_entered() -> void:
	mouse_entered_footman = true
func _on_mouse_exited() -> void:
	mouse_entered_footman = false

func _input(event):
	if Input.is_action_just_pressed("left_mouse_click") && mouse_entered_footman == true:
		do_footman_moves()

func do_footman_moves():
	pass
	get_footman_moves()
	#get avaliable moves
	#check avaliable moves
	#show checked moves
	#movement if clicked
	#hide if not clicked

func get_footman_moves():
	avaliable_moves.clear()
	if is_front_side:
		avaliable_moves = [
			Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)
		]
	else:
		avaliable_moves = [
			Vector2i(1,1), Vector2i(1,-1),Vector2i(0,-2), Vector2i(-1,1), Vector2i(-1,-1)
		]
		print("Footman moves are", avaliable_moves)
