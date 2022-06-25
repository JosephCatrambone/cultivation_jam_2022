# A module floor tile, when a new thing like a planter or a seed or something is added,
# will turn into either a potted plant or a hydroponics setup or a grow light or a heater.
# We have to check in proces whether the contents of our inventory is something, then depending
# on precisely what our type is, we should transform into that.

extends StaticBody

var exchange_ui:PackedScene = preload("res://UI/InventoryExchangeUI.tscn")
var inventory_planter:InventoryItem
var planter:Node
onready var inventory = $Inventory
onready var mesh:MeshInstance = $FloorTileMesh
onready var collision_shape:CollisionShape = $CollisionShape
var player_interacted:bool = false  # Used to maybe detect changes.

func _ready():
	self.inventory.connect("item_dragged_in", self, "_on_item_dragged_in")

func _on_item_dragged_in(item, _dx, _dy):
	# Monitor for when an item is dragged in.  If it's a planter, set it up.
	if item is InventoryItem and item.name.find("Planter"):
		self.inventory_planter = item

func _process(delta):
	# If we just had an inventory item dragged in, inventory will be not null.
	if self.inventory_planter != null:
		var new_planter = self.inventory_planter.get_physical_item()
		self.planter = new_planter
		self.add_child(planter)
		self.inventory_planter = null  # Convert the planter from an inventory item to a real item.
	
		self.mesh.visible = (self.planter == null)
		self.collision_shape.disabled = (self.planter != null)
	
	# Check if the planter is removed:
	if self.player_interacted:
		if Globals.active_menu != null:
			return  # Player is still interacting.  Hack to make this only register the change on menu close.
		self.player_interacted = false  # Reset the trigger.
		
		# HACK:
		# If the player happened to remove the child planter, then let's assume that they got one in their inventory.
		# Remove and discard the items from our inventory, then mark self as visible.
		if self.planter == null:
			pass
		
		"""
		var inv_items = self.inventory.get_items()
		# This is an awful hack.
		for item in inv_items:
			if item is InventoryItem and item.name.find("Planter"):
				
				
		# Maybe render planter
		self.dirt_planter_mesh.visible = (self.planter != null)
		self.floor_tile_mesh.visible = (self.planter == null)
		"""

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
