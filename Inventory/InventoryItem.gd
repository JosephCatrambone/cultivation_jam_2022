extends TextureButton

class_name InventoryItem

const INVENTORY_CELL_WIDTH:int = 64
const INVENTORY_CELL_HEIGHT:int = 64

export(int) var inventory_width:int = 1
export(int) var inventory_height:int = 1
export(String) var hack_reflection_resource_name:String
export(PackedScene) var unspawned_node_reference:PackedScene
var spawned_node_reference:Spatial  # Might be a reference to an existing packed scene.

var occupied_cells:Array = []
var inventory_rotation:int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	if inventory_width < 1 and inventory_height < 1:
		printerr("Inventory Item has size less than one.  Trying to determine automatically.")
		self.inventory_width = int(self.texture_normal.get_width() / INVENTORY_CELL_WIDTH)
		self.inventory_height = int(self.texture_normal.get_height() / INVENTORY_CELL_HEIGHT)
	self.rect_size = Vector2(INVENTORY_CELL_WIDTH*self.inventory_width, INVENTORY_CELL_HEIGHT*self.inventory_height)
	self.rect_min_size = Vector2(INVENTORY_CELL_WIDTH*self.inventory_width, INVENTORY_CELL_HEIGHT*self.inventory_height)
	
	# For the sake of simplification, for now we just return a solid square.
	for y in range(self.inventory_height):
		for x in range(self.inventory_width):
			self.occupied_cells.append([x, y])

func get_texture() -> Texture:
	return self.texture_normal

func get_physical_item() -> Spatial:
	if self.spawned_node_reference == null:
		# Unspawned node ref may be null.
		var instance = unspawned_node_reference.instance()
		self.spawned_node_reference = instance
	return self.spawned_node_reference

