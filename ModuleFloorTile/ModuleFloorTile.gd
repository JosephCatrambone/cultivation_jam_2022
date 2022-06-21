# A module floor tile, when a new thing like a planter or a seed or something is added,
# will turn into either a potted plant or a hydroponics setup or a grow light or a heater.
# We have to check in proces whether the contents of our inventory is something, then depending
# on precisely what our type is, we should transform into that.

extends StaticBody

var exchange_ui:PackedScene = preload("res://UI/InventoryExchangeUI.tscn")
var planter:Node
onready var inventory = $Inventory
onready var floor_tile_mesh:MeshInstance = $FloorTileMesh
onready var dirt_planter_mesh:MeshInstance = $DirtPlanterMesh
var player_interacted:bool = false  # Used to maybe detect changes.

func _ready():
	pass

func _process(delta):
	if self.player_interacted:
		if Globals.active_menu != null:
			return  # Player is still interacting.  Hack to make this only register the change on menu close.
		self.player_interacted = false  # Reset the trigger.
		var inv_items = self.inventory.get_items()
		# This is an awful hack.
		for item in inv_items:
			if item is InventoryItem and item.name.find("Planter"):
				var new_planter = item.get_physical_item()
				self.planter = new_planter
		# Maybe render planter
		self.dirt_planter_mesh.visible = (self.planter != null)
		self.floor_tile_mesh.visible = (self.planter == null)

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
