extends Spatial

var floor_module:Resource = preload("res://ModuleFloorTile/ModuleFloorTile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func interact(command, interact_position):
	print("Tap!")
