extends StaticBody

var ui_reference = preload("res://UI/InventoryExchangeUI.tscn")
onready var inventory = $Inventory

var loot_by_tier = [
	# Level 0 loot:
	[
		
	],
	# Level 1 loot:
	[
		
	],
	# Level 2 loot:
	[
		
	],
	# Level 3 loot:
	[
		
	],
]

func generate(value:int):
	pass

func interact(actor, args = null):
	var ui_exchange = ui_reference.instance()
	get_tree().root.add_child(ui_exchange)
	ui_exchange.open_exchange(actor, self)
