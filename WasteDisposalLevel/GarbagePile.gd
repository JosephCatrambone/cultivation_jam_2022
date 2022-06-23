extends StaticBody

export(int) var value:int = 0
var ui_reference = preload("res://UI/InventoryExchangeUI.tscn")
onready var inventory = $Inventory

var loot_by_tier = [
	# Level 0 loot:
	[
		preload("res://Inventory/SeedInventoryItem.tscn"),
		preload("res://FloorItem/DirtPlanter/DirtPlanterInventoryItem.tscn"),
	],
	# Level 1 loot:
	[
		preload("res://Inventory/SeedInventoryItem.tscn"),
		preload("res://FloorItem/DirtPlanter/DirtPlanterInventoryItem.tscn"),
	],
	# Level 2 loot:
	[
		preload("res://Inventory/SeedInventoryItem.tscn"),
		preload("res://FloorItem/DirtPlanter/DirtPlanterInventoryItem.tscn"),
	],
	# Level 3 loot:
	[
		preload("res://Inventory/SeedInventoryItem.tscn"),
		preload("res://FloorItem/DirtPlanter/DirtPlanterInventoryItem.tscn"),
	],
	# Level 4 loot:
	[
		preload("res://Inventory/SeedInventoryItem.tscn"),
		preload("res://FloorItem/DirtPlanter/DirtPlanterInventoryItem.tscn"),
	]
]

func _ready():
	self.generate(self.value)

func generate(value:int):
	var random_item_idx = Globals.rng.randi_range(0, len(loot_by_tier[value])-1)
	self.inventory.add_item(loot_by_tier[value][random_item_idx].instance())

func interact(actor, args = null):
	var ui_exchange = ui_reference.instance()
	get_tree().root.add_child(ui_exchange)
	ui_exchange.open_exchange(actor, self)
