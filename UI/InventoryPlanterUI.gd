extends Control

var player_ref:Node  
var player_inventory_ref:Node

onready var placeholder_inventory_ref:PanelContainer = $Panel/PlayerInventory
onready var player_inventory:PanelContainer = $Panel/PlayerInventory
onready var planter_inventory:PanelContainer = $Panel/PlanterInventory

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.connect("player_spawned", self, "_on_new_player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# For now, escape toggles the planter ui.
	if Input.is_action_just_pressed("ui_cancel"):
		self.visible = !self.visible
		player_inventory.active = self.visible
		if self.visible:
			self._steal_player_inventory()
		else:
			self._return_player_inventory()
		player_inventory.on_cursor_moved_in(0, 0)

func _on_new_player(player):
	self.player_ref = player
	# TODO: Figure out if 'keep_data' is desirable and/or what it does.

func _steal_player_inventory():
	print_debug("Stealing player inventory reference.")
	self.player_inventory_ref = self.player_ref.get_node("Inventory")
	self.player_ref.remove_child(self.player_inventory_ref)
	self.player_inventory_ref.visible = true
	self.player_inventory.replace_by(self.player_inventory_ref, true)
	self.remove_child(self.player_inventory)
	self.player_inventory = self.player_inventory_ref
	self.add_child(self.player_inventory_ref)
	# Can't use replace_by since it appears to be leaving the old reference to the placeholder inventory
	self.connect_inventory_signals()
	self.player_inventory_ref.on_cursor_moved_in(0, 0)

func _return_player_inventory():
	print_debug("Returning player inventory.")
	#self.player_inventory_ref.on_cursor_moved_out(0, 0)
	self.player_inventory.replace_by(self.placeholder_inventory_ref, true)
	self.player_inventory_ref.visible = false
	self.player_ref.add_child(self.player_inventory_ref)
	self.player_inevntory_ref = null
	self.connect_inventory_signals()

func connect_inventory_signals():
	# This is not required if we set neighbor.
	player_inventory.connect("cursor_moved_out", planter_inventory, "on_cursor_moved_in")
	planter_inventory.connect("cursor_moved_out", player_inventory, "on_cursor_moved_in")
	player_inventory.connect("item_dragged_out", planter_inventory, "on_item_dragged_in")
	planter_inventory.connect("item_dragged_out", player_inventory, "on_item_dragged_in")
