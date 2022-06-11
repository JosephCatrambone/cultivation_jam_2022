extends KinematicBody

var destination:Vector3 = Vector3()
var active_path:PoolVector3Array = []
var movement_direction:Vector3 = Vector3()
var movement_volition:Vector3 = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _follow_path(delta):
	# Move towards the next step in the path, possibly popping a node along the way.
	pass

func move_to(destination: Vector3, wayfinder:Navigation):
	# How does navigationagent work?
	pass

