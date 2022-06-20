extends Spatial

onready var rooms:Spatial = $Room
onready var player:Spatial = $Player

var waste_disposal_level_generator = preload("res://WasteDisposalLevel/WasteDisposalLevel.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.start_dungeon()

func start_dungeon():
	self.remove_child(self.rooms)
	var dungeon = waste_disposal_level_generator.instance()
	self.add_child(dungeon)
	self.player.translation = Vector3(0, 0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("ui_home"):
		self.save_game("user://save_game_" + Globals.player_name + ".json")
	if Input.is_action_just_released("ui_end"):
		self.load_game("user://save_game_" + Globals.player_name + ".json")

func change_scene(new_scene:String, target_location_path:String):
	rooms.set_active_layout(new_scene)
	var target_location:Position3D = rooms.get_active_layout().get_node(target_location_path)
	player.translation = target_location.translation

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
	self.remove_child(self.rooms)
	self.rooms.queue_free()
	
	# Restore the player:
	self.player = load(saved_state["player"]["resource"]).instance()
	self.player.restore(saved_state["player"])
	self.add_child(self.player)
	
	# Restore the level.
	self.rooms = load(saved_state["rooms"]["resource"]).instance()
	self.rooms.restore(saved_state["rooms"])
	self.add_child(self.rooms)
	
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
		"rooms": self.rooms.save()
	}
	
	fout.store_line(to_json(save_state))
	fout.close()

func _save_room(node:Node) -> Dictionary:
	# Expected that anything which needs to be persisted will implement a save method that returns a Dictionary.
	# HACK: Everything that implements save has to give back a resource inside which says what to instance.
	return node.save()
