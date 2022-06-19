extends Node

signal player_spawned(player)
signal player_died(player)

const INVENTORY_CELL_SIZE:int = 64
var active_menu:Node = null
var player_name:String = "test"
