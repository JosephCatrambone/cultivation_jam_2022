extends StaticBody

# This will break if we load scenes and transition across unloaded scenes because we will have to reference things outside the scope.
export(String) var target_scene: String
export(String) var player_destination: String  # Something that has a position.

func interact(actor, args = []):
	# TODO: MainGame is a hardcoded node.
	get_node("/root/MainGame").change_scene(target_scene, player_destination)
