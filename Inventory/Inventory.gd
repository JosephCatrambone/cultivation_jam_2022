extends Control

# In hindsight, maybe I should have made this a resource.

signal cursor_moved_out(dx, dy)  # When a cursor moves out of the frame, this is emitted.  dx is -1 for left side, +1 for right.  dy is -1 for top, +1 for bottom.  Will be emitted in addition to calling on_entered on the neighbor.
signal item_dragged_out(item, dx, dy)  # When the cursor moves out of frame with an item dragged, this is emitted.

const CURSOR_MOVE_TIME:float = 0.1
const MIN_MOVE_THRESHOLD:float = 0.1
const H_PAD:int = 16
const V_PAD:int = 16
const CELL_WIDTH:int = 64
const CELL_HEIGHT:int = 64

# How big is the inventory?
export var width:int = 1  # Inventory width in cells.
export var height:int = 1  # Inventory height in cells.
# Display items:
export(Texture) var empty_cell_texture:Texture
export(Texture) var full_cell_texture:Texture
export(Texture) var highlighted_cell_texture:Texture
export(Texture) var invalid_cell_texture:Texture

onready var cells:GridContainer = $Cells
onready var items:Control = $Items
onready var cursor:NinePatchRect = $Cursor
onready var cursor_tween:Tween = $CursorTween
onready var dragged_item_texture:TextureRect = $Cursor/DraggedItemTexture

# Manages what is assigned to where.
# Also used to restore the cell backdrop after the cursor moves.
var cell_to_item:Array = []

# Cursor and movement
var active:bool = true
var cursor_idx:int = -1
var last_cursor_dxdy:Vector2 = Vector2.ZERO
var cursor_max_dxdy:Vector2 = Vector2.ZERO  # If the user pushes right and then snaps back, this holds right.

# Item dragging:
var dragged_item = null
var dragged_origin_cell = null  # IDX, not x/y

func _ready():
	self.resize(self.width, self.height)
	self._update_cursor_position()  # To reset cursor.

func _process(delta):
	if active and self.visible:
		var dx = Input.get_axis("ui_left", "ui_right")
		var dy = Input.get_axis("ui_up", "ui_down")
		self.last_cursor_dxdy = Vector2(dx, dy)
		if self.last_cursor_dxdy.length() > self.cursor_max_dxdy.length():
			self.cursor_max_dxdy = self.last_cursor_dxdy
		elif self.last_cursor_dxdy.length() < MIN_MOVE_THRESHOLD and self.cursor_max_dxdy.length() > MIN_MOVE_THRESHOLD:
			# We went to the edge and snapped back to zero.
			# This is like 'on release' but works for joysticks.
			self._update_cursor_position()
		elif Input.is_action_just_released("ui_accept"):
			if self.dragged_item == null:
				self._start_drag()
			else:
				self._maybe_stop_drag()

func resize(new_width:int, new_height:int):
	# Drops all cell items and reallocates the positions.
	# Will not handle things which are out of bounds after resize.
	for c in self.cells.get_children():
		c.queue_free()
	self.cells.columns = self.width
	self.cell_to_item = []
	self.width = new_width
	self.height = new_height
	for y in range(self.height):
		for x in range(self.width):
			var cell_backdrop:TextureRect = TextureRect.new()
			cell_backdrop.texture = self.empty_cell_texture
			self.cells.add_child(cell_backdrop)
	self._update_cell_status()
	self.rect_min_size = Vector2(self.width*CELL_WIDTH, self.height*CELL_HEIGHT)

func _xy_to_idx(x:int, y:int) -> int:
	return x + self.width*y

func _idx_to_xy(idx:int) -> Array:
	return [idx % self.width, int(idx / self.width)]

func _update_cell_status():
	# Iterate over the cells and, based on their contents, assign the cell as fulled, empty, etc.
	# Updates the visual appearance.
	# Also updates the cell_to_item map.
	
	# Clear assignment:
	self.cell_to_item = []
	for idx in range(self.width*self.height):
		self.cell_to_item.append(null)
		self.cells.get_child(idx).texture = self.empty_cell_texture
	
	# Update the style of the cell and the assignment map.
	for i in self.items.get_children():
		var item:InventoryItem = i
		# Map from item i to the position inside the parent, then use that to map to the cell position.
		var pos:Vector2 = i.rect_position
		var cell_x:int = int(pos.x / CELL_WIDTH)
		var cell_y:int = int(pos.y / CELL_HEIGHT)
		# This gives us the _origin_ cell, but then the item has to be treated as an inventory item with cell shape.
		for dxdy in item.occupied_cells:
			var cell_idx:int = self._xy_to_idx(cell_x + dxdy[0], cell_y + dxdy[1])
			self.cell_to_item[cell_idx] = item
			var texture_panel:TextureRect = self.cells.get_child(cell_idx)
			if texture_panel == null:
				printerr("Managed to place an item out of bounds?  No cell background for cell idx ", cell_idx)
				continue
			texture_panel.texture = self.full_cell_texture

func _update_cursor_position():
	if self.cursor_idx == -1 or not self.active:
		self.cursor.visible = false
		return
	self.cursor.visible = true
	
	# Reset the last dxdy and move the cursor.  Update the tiles in the background.
	var dx = int(self.cursor_max_dxdy.x)
	var dy = int(self.cursor_max_dxdy.y)
		
	# Update current IDX.
	var cursor_xy = self._idx_to_xy(self.cursor_idx)
	var new_cursor_xy = [cursor_xy[0]+dx, cursor_xy[1]+dy]
	var new_idx = self._xy_to_idx(new_cursor_xy[0], new_cursor_xy[1])
	var new_cursor_oob = new_cursor_xy[0] < 0 or new_cursor_xy[0] >= self.width or new_cursor_xy[1] < 0 or new_cursor_xy[1] >= self.height
	print_debug(self.name, " New cursor: ", new_cursor_xy, " ", new_idx)
	
	# If we are dragging outside of the inventory space, signal this.
	if new_cursor_oob:
		# See if we have a neighbor/
		# Eventually perhaps we will use this to do the dragging.
		var neighbor = null
		if dx > 0:
			neighbor = get_node_or_null(self.focus_neighbour_right)
		elif dx < 0:
			neighbor = get_node_or_null(self.focus_neighbour_left)
		elif dy > 0:
			neighbor = get_node_or_null(self.focus_neighbour_bottom)
		elif dy < 0:
			neighbor = get_node_or_null(self.focus_neighbour_top)
			
		if dragged_item == null:
			emit_signal("cursor_moved_out", dx, dy)
			if neighbor != null:
				pass
				#neighbor.on_cursor_moved_in(dx, dy)
				#neighbor.call_deferred("on_cursor_moved_in", dx, dy)
		else:
			emit_signal("item_dragged_out", dragged_item, dx, dy)
			# Item removal is handled by the start_drag method.  No need for self.items.remove_child(dragged_item)
			# but we do have to clear the drag to avoid item duplication.
			self.dragged_item = null
			self.dragged_item_texture.texture = null
			if neighbor != null:
				pass
				#neighbor.on_item_dragged_in(dragged_item, dx, dy)
		self.active = false
		self.cursor_idx = -1
		self.cursor.visible = false
	else:
		self.cursor_idx = new_idx
		#self.cells.get_child(new_idx).texture = highlighted_cell_texture
		# If the new position belongs to something, match the cursor to that size.
		# This will be wrong if we're dragging.
		var new_size = Vector2(CELL_WIDTH, CELL_HEIGHT)
		if self.cell_to_item[cursor_idx] != null:
			var item:InventoryItem = self.cell_to_item[cursor_idx]
			new_size = Vector2(CELL_WIDTH*item.inventory_width, CELL_HEIGHT*item.inventory_height)
			# TODO: If we happen to be approaching from the bottom or the right, then move our cursor to the top left.
			# BUT ONLY IF APPROACHING FROM THE BOTTOM/RIGHT otherwise we won't be able to move off of a bigger tile.
		self.cursor_tween.interpolate_property(cursor, "rect_position", cursor.rect_position, Vector2(new_cursor_xy[0]*CELL_WIDTH, new_cursor_xy[1]*CELL_HEIGHT), CURSOR_MOVE_TIME)
		self.cursor_tween.interpolate_property(cursor, "rect_size", cursor.rect_size, new_size, CURSOR_MOVE_TIME)
		self.cursor_tween.start()
	
	# Reset the positions.
	self.cursor_max_dxdy = Vector2()
	self.last_cursor_dxdy = Vector2()

func _start_drag():
	# Takes no parameters.  Mutates internal state.
	# Removes the highlighted item from the inventory and then pretends the item is dragged in.
	if cursor_idx == -1:
		printerr("_start_drag() called when cursor is not inside panel.")
		return
	if self.cell_to_item[self.cursor_idx] == null:
		return  # Nothing to drag!
	else:
		# Handle setting texture and everything, then REMOVE the item from our inventory.
		# This will set self.dragged_item
		self.on_item_dragged_in(self.cell_to_item[self.cursor_idx], 0, 0)
		self.items.remove_child(self.dragged_item)
		# Now update all the cells to mark them as cleared.
		self._update_cell_status()
		
func _maybe_stop_drag():
	# If the space is open, add the inventory item to the inventory.
	if cursor_idx == -1:
		printerr("Can't call stop_drag when the cursor is not in the panel.")
		return
	if self.dragged_item == null:
		printerr("_maybe_stop_drag() called with no dragged item!  Race condition!")
		return
	var xy = self._idx_to_xy(self.cursor_idx)
	if self._valid_position(self.dragged_item, xy[0], xy[1]):
		var item:InventoryItem = self.dragged_item
		self.dragged_item_texture.texture = null
		self.dragged_item = null
		item.rect_position = Vector2(xy[0]*CELL_WIDTH, xy[1]*CELL_HEIGHT)
		self.items.add_child(item)
		self._update_cell_status()

func on_item_dragged_in(item:InventoryItem, dx:int = 0, dy:int = 0):
	# Calls 'on_cursor_moved_in' first and then updates the dragged items.
	self.on_cursor_moved_in(dx, dy)
	
	self.dragged_item = item
	self.dragged_item_texture.texture = item.get_texture()

	var new_size = Vector2(self.dragged_item.inventory_width*CELL_WIDTH, self.dragged_item.inventory_height*CELL_HEIGHT)
	self.cursor_tween.interpolate_property(cursor, "rect_size", cursor.rect_size, new_size, CURSOR_MOVE_TIME)
	self.cursor_tween.start()

func on_cursor_moved_in(dx:int = 0, dy:int = 0):
	# This, generally, is called by on_item_dragged_in and by start_drag.  (Or by signal.)
	# Makes the cursor visible, sets this as active, and, if dx/dy are nonzero, calculates the new approximate position of the cursor.
	# If dx/dy are zero AND the current cursor idx is not -1, does not change cursor.
	self.active = true
	self.cursor.visible = true
	self.cursor_max_dxdy = Vector2()  # Reset this so we don't accidentally trigger a move.
	if dx != 0 or dy != 0 or self.cursor_idx == -1:
		var new_cursor_x = int(self.width/2)
		var new_cursor_y = int(self.height/2)
		if dx < 0:
			new_cursor_x = self.width-1
		elif dx > 0:
			new_cursor_x = 0
		elif dy < 0:
			new_cursor_y = self.height-1
		elif dy > 0:
			new_cursor_y = 0
		self.cursor_idx = self._xy_to_idx(new_cursor_x, new_cursor_y)
		self.cursor.rect_position = Vector2(new_cursor_x*CELL_WIDTH, new_cursor_y*CELL_HEIGHT)
		print_debug("Cursor came from some direction: ", dx, " ", dy, " with new position ", self.cursor.rect_position)
	print_debug(self.name, " on_cursor_moved: ", self.cursor_idx)
	self._update_cursor_position()

func _valid_position(item:InventoryItem, x:int, y:int) -> bool:
	# If the item does not have an InventoryItem, checks to see if there's a direct child with an inventory item.
	# If that is also not the case, returns false.
	# If there are no open spaces that fit, returns false.
	# Returns true if the item was added successfully.
	# Sets the item's position in the inventory, snapping to grid.
	return true

func add_item(item:InventoryItem) -> bool:
	# Returns TRUE if the item was able to be added to the inventory.
	for y in range(self.height):
		for x in range(self.width):
			if self._valid_position(item, x, y):
				item.rect_position = Vector2(x*CELL_WIDTH, y*CELL_HEIGHT)
				self.items.add_child(item)
				self._update_cell_status()
				return true
	return false
	
func save() -> Dictionary:
	return {}

func restore(saved_state:Dictionary) -> void:
	pass
