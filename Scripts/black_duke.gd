extends Area2D

var mouse_entered_black_duke: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	black_duke_reset()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func black_duke_reset():
	pass

##region code to detect if the mouse is over the white duke changes mouse_entered_white_duke
#func _mouse_enter():
	#mouse_entered_black_duke = true
#func _mouse_exit():
	#mouse_entered_black_duke = false
##endregion
