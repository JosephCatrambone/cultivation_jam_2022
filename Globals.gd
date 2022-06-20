extends Node

signal player_spawned(player)
signal player_died(player)

const PLAYER_GROUP:String = "players"
const INVENTORY_CELL_SIZE:int = 64
var active_menu:Node = null
var player_name:String = "test"
var rng:RandomNumberGenerator = RandomNumberGenerator.new()

func get_player() -> KinematicBody:
	# Don't run this in a loop because it's kinda' expensive.
	# Returns the player IF they exist, else null.
	for candidate in get_tree().get_nodes_in_group(PLAYER_GROUP):
		return candidate
	return null
