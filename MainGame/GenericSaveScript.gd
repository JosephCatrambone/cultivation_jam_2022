extends Node

export(String) var base_resource:String

func restore(save_state:Dictionary):
	# Should sanity check later.
	self.name = save_state["name"]
	for child in save_state["children"]:
		var instance = load(child["resource"]).instance()
		if instance.has_method("restore"):
			instance.restore(child)
		self.add_child(instance)	

func save() -> Dictionary:
	# HACK: Everything that implements save has to give back a resource inside which says what to instance.
	var save_state = {
		"name": self.name,
		"resource": base_resource,
		"children": []
	}
	
	for child in self.get_children():
		if child.has_method("save"):
			var child_state = child.save()
			save_state["children"].append(child_state)
	return save_state
