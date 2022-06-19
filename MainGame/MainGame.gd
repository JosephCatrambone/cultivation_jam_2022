extends Spatial

onready var current_room = $Room
onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("ui_home"):
		self.save_game("user://save_game_" + Globals.player_name + ".json")
	if Input.is_action_just_released("ui_end"):
		self.load_game("user://save_game_" + Globals.player_name + ".json")

# Options for changing scenes:
# 1. WE CANNOT JUST MARK INACTIVE ONES AS INVISIBLE! (Because collision still runs.)
# 2. Remove them from the scene tree when inactive.
#  - Downside: we will have to worry about serialization eventually anyway.
#  - Upside: removing from the scene tree means we don't use graphics resources, but we use compute.
#  - Upside: no catch-up logic for restoring room (yet).

# 3. Dynamically load the scenes from memory/restore from disk and fast forward.
#  - Downside: catch-up logic is probably hard.  Serialization is also hard.
#  - Upside: much faster when not in use.
#  - Upside: gives us the save/load logic.

func load_game(filename:String):
	# Spawn a new resource, add to itself as a named child, and return the object.
	
	var fin = File.new()
	fin.open(filename, File.READ)
	
	var saved_state = parse_json(fin.get_line())
	
	# Destroy old room and old player:
	self.remove_child(self.player)
	self.player.queue_free()
	self.remove_child(self.current_room)
	self.current_room.queue_free()
	
	# Restore the player:
	self.player = load(saved_state["player"]["resource"]).instance()
	self.player.restore(saved_state["player"])
	self.add_child(self.player)
	
	# Restore the level.
	self.current_room = load(saved_state["current_room"]["resource"]).instance()
	self.current_room.restore(saved_state["current_room"])
	self.add_child(self.current_room)
	
	fin.close()
	
	pass

#
# TODO!!!!
# Figure out how to automatically get the name of the resource and/or the base instance type.
# It will mean we can do load(x).instance() when .save() is not implemented.
#

func save_game(filename:String):
	# This is cool but will take too long to figure out.  Maybe come back to it?
	#var resource_save_location = "user://" + Globals.save_game_name + "__" + node.name + ".tscn"
	#node.get_parent().remove_child(node)
	#var scene = PackedScene.new()
	#var packed_result = scene.pack(node)
	#if packed_result == OK:
	#	ResourceSaver.save(resource_save_location, scene)
	#node.queue_free()
	
	pass
	
	# Saves the state of the player and the rooms as they are.
	# Will call _save_room on the given object and the player.
	var fout = File.new()
	fout.open(filename, File.WRITE)
	
	var save_state:Dictionary = {
		"player": self.player.save(),
		"current_room": self.current_room.save()
	}
	
	fout.store_line(to_json(save_state))
	fout.close()

func _save_room(node:Node) -> Dictionary:
	# Expected that anything which needs to be persisted will implement a save method that returns a Dictionary.
	# HACK: Everything that implements save has to give back a resource inside which says what to instance.
	return node.save()
