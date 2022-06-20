extends Spatial

export(PackedScene) var menu:PackedScene
export(bool) var single_shot:bool = false

func interact(actor, args = []):
	var new_menu = menu.instance()
	new_menu.visible = true
	get_tree().get_root().add_child(new_menu)
	Globals.active_menu = new_menu
	
	if single_shot:
		self.queue_free()
