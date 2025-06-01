extends TileMapLayer


var board_layer_id = self.get_instance_id()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Board id is", board_layer_id)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
