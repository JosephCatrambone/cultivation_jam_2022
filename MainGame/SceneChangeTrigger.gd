extends Area

# This will break if we load scenes and transition across unloaded scenes because we will have to reference things outside the scope.
export(NodePath) var target_scene: NodePath
export(NodePath) var player_destination: NodePath  # Soemthing that has a position.

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("body_entered", self, "_on_body_entered")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_body_entered(body):
	# TODO: Be sure that it's actually the player entering.
	print("Player entered")
