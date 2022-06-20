extends Camera

var tracking_target:KinematicBody
export(Vector3) var tracking_offset:Vector3 = Vector3(0, 0, 0)
export(float) var smoothing_amount:float = 1.0  # TODO: Remember how to do range type hints and don't let this be less than one.

# Called when the node enters the scene tree for the first time.
func _ready():
	tracking_target = Globals.get_player()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Interpolate from our current position to the target position, based on the player's location.
	var target_position = (tracking_target.transform.origin + tracking_offset)
	# TODO: Worry about global/local translation in the future.
	self.translation = lerp(self.translation, target_position, 1.0/(0.00001+self.smoothing_amount))
