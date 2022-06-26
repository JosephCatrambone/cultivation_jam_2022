extends Panel

var left_entity:Node
var left_inventory:Node
onready var left_ui_pane:Container = $HBoxContainer/VBoxContainerL/InvLeft

var right_entity:Node
var right_inventory:Node
onready var right_ui_pane:Container = $HBoxContainer/VBoxContainerR/InvRight

# All inventories need to be named this!
export(String) var inventory_identifier_string:String = "Inventory"

func _process(_delta):
	pass

func open_exchange(left, right):
	Globals.active_menu = self
	
	# Remove left and right from their parent holders.
	self.left_entity = left
	self.left_inventory = self.left_entity.get_node(self.inventory_identifier_string)
	self.right_entity = right
	self.right_inventory = self.right_entity.get_node(self.inventory_identifier_string)
	
	# Add the left and right to this UI.
	self.left_entity.remove_child(self.left_inventory)
	self.left_ui_pane.add_child(self.left_inventory)
	self.right_entity.remove_child(self.right_inventory)
	self.right_ui_pane.add_child(self.right_inventory)
	
	# Connect signals between the items.
	self.left_inventory.connect("cursor_moved_out", self.right_inventory, "on_cursor_moved_in")
	self.right_inventory.connect("cursor_moved_out", self.left_inventory, "on_cursor_moved_in")
	self.left_inventory.connect("item_dragged_out", self.right_inventory, "on_item_dragged_in")
	self.right_inventory.connect("item_dragged_out", self.left_inventory, "on_item_dragged_in")
	self.left_inventory.on_cursor_moved_in(0, 0)
	
	# Reveal
	self.left_inventory.visible = true
	self.right_inventory.visible = true
	self.visible = true

func close_exchange():
	# Disconnect signals.
	self.left_inventory.disconnect("cursor_moved_out", self.right_inventory, "on_cursor_moved_in")
	self.right_inventory.disconnect("cursor_moved_out", self.left_inventory, "on_cursor_moved_in")
	self.left_inventory.disconnect("item_dragged_out", self.right_inventory, "on_item_dragged_in")
	self.right_inventory.disconnect("item_dragged_out", self.left_inventory, "on_item_dragged_in")
	
	# Remove from UI tree + return to parents.
	self.left_ui_pane.remove_child(self.left_inventory)
	self.left_entity.add_child(self.left_inventory)
	self.right_ui_pane.remove_child(self.right_inventory)
	self.right_entity.add_child(self.right_inventory)
	
	# Clear visibility of child inventories.
	self.left_inventory.visible = false
	self.right_inventory.visible = false
	self.left_inventory = null
	self.right_inventory = null
	self.visible = false
	Globals.active_menu = null
	self.queue_free()
