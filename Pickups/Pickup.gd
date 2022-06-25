extends Spatial

export(NodePath) var inventory_item_path:NodePath
var inventory_item:Node

func _ready():
	# I hate this code.
	# Prevent child object from having '_process'
	self.inventory_item = self.get_node(self.inventory_item_path)
	self.remove_child(self.inventory_item)

func interact(actor:Node, args = null):
	assert(actor != null)
	# TODO: This is maybe error prone if the actor has more than one inventory.
	# TODO: This is also a bug because it only calls children one deep.
	for child in actor.get_children():
		if child.has_method("add_item"):
			if self.inventory_item != null:
				child.add_item(self.inventory_item)
				self.queue_free()
				return
