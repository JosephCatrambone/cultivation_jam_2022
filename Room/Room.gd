extends Spatial

# We start with all layouts ready and available, then remove them from the active tree based on which room is active.

export(String) var active_layout:String = ""
var rooms = {}  # A map of layout name to node.
onready var layouts = $Layouts

func _ready():
	for layout in self.layouts.get_children():
		if self.rooms.has(layout.name):
			printerr("Room with name ", layout.name, " already exists inside of tree!  Needs a unique name!")
		self.rooms[layout.name] = layout
		layout.visible = true
		self.layouts.remove_child(layout)
	self.set_active_layout(self.active_layout)
	
func _process(delta):
	pass

func set_active_layout(layout_name:String):
	# Get the current layout and maybe deactivate it.
	var current_layout = self.get_node_or_null(self.active_layout)
	if current_layout != null:
		# TODO: Race condition where going back and forth too fast leads _current_layout to be null.
		self.remove_child(current_layout)
	
	if self.rooms.has(layout_name):
		self.add_child(self.rooms[layout_name])
		self.active_layout = layout_name

func get_active_layout() -> Node:
	return self.get_node_or_null(self.active_layout)

func save() -> Dictionary:
	# HACK: Everything that implements save has to give back a resource inside which says what to instance.
	var save_state = {
		"name": self.name,
		"resource": "res://Room/Room.tscn",
		"children": [],
		"rooms": {},
		"active_layout": self.active_layout,
	}
	
	for child in self.get_children():
		if child.has_method("save"):
			var child_state = child.save()
			save_state["children"].append(child_state)
	
	for room_layout in self.rooms:
		save_state["rooms"][room_layout.name] = room_layout.save()
		
	return save_state

func restore(save_state:Dictionary):
	# Should sanity check later.
	self.name = save_state["name"]
	assert(save_state["resource"] == "res://RingModule/RingModule.tscn")
	for child in save_state["children"]:
		var instance = load(child["resource"]).instance()
		if instance.has_method("restore"):
			instance.restore(child)
		self.add_child(instance)
	# GDSCript iteration works on keys.  :/
	for room_layout_name in save_state["rooms"]:
		# We don't need to re-instantiate the layouts because they're made when _THIS_ resource is spawned, but we should restore them.
		self.rooms[room_layout_name].restore(save_state["rooms"][room_layout_name])
	self.set_active_layout(save_state["active_layout"])
