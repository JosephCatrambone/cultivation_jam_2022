# A module floor tile, when a new thing like a planter or a seed or something is added,
# will turn into either a potted plant or a hydroponics setup or a grow light or a heater.
# We have to check in proces whether the contents of our inventory is something, then depending
# on precisely what our type is, we should transform into that.

extends StaticBody

var exchange_ui:PackedScene = preload("res://UI/InventoryExchangeUI.tscn")
var planter:Node
onready var inventory = $Inventory
export(int) var tile_inventory_capacity:int = 2
var player_interacted:bool = false  # Used to maybe detect changes.

func _ready():
	inventory.width = tile_inventory_capacity
	inventory.height = tile_inventory_capacity

func _process(delta):
	if self.player_interacted:
		self.player_interacted = false  # Reset the trigger.

func interact(actor:Node = null, args = null):
	self.player_interacted = true
	# If this is not populated by a planter, show an inventory exchange UI.
	if self.planter == null:
		# Spawn the UI to allow the user to install something.
		var ui_exchange = exchange_ui.instance()
		get_tree().root.add_child(ui_exchange)
		ui_exchange.open_exchange(actor, self)
	else:
		self.planter.interact(actor, args)
