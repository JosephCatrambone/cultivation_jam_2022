extends Area

# This will break if we load scenes and transition across unloaded scenes because we will have to reference things outside the scope.
export(String) var target_scene: String
export(String) var player_destination: String  # Something that has a position.

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "_on_body_entered")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_body_entered(body):
	# TODO: MainGame is a hardcoded node.  
	# TODO: Be sure that it's actually the player entering.
	get_node("/root/MainGame").change_scene(target_scene, player_destination)
