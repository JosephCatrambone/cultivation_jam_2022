extends Spatial

var host_plant: Node

var ui_reference = preload("res://UI/InventoryExchangeUI.tscn")
onready var inventory = $Inventory

func interact(actor, args = null):
	var ui_exchange = ui_reference.instance()
	get_tree().root.add_child(ui_exchange)
	ui_exchange.open_exchange(actor, self)
