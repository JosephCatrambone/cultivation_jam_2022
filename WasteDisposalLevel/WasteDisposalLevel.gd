extends Spatial

onready var elevator:Spatial = $Elevator
onready var possible_locations:Spatial = $PileLocations
export(int) var difficulty:int = 0
var generated:bool = false
var garbage_pile_template:PackedScene = preload("res://WasteDisposalLevel/GarbagePile.tscn")
var enemy_template:PackedScene = preload("res://Enemy/Enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.generate(self.difficulty)

func generate(difficulty:int):
	var number_of_piles = Globals.rng.randi_range(5, 10)
	for i in range(number_of_piles):
		if self.possible_locations.get_child_count() < 1:
			return
		# Select a child at random and replace the Position3D with a pile.
		var pile = garbage_pile_template.instance()
		#pile.generate(difficulty)  # Pile auto-generates itself on spawn.
		var random_location_idx:int = Globals.rng.randi()%self.possible_locations.get_child_count()
		var random_location:Position3D = self.possible_locations.get_child(random_location_idx)
		pile.translation = random_location.translation
		self.add_child(pile)
		self.possible_locations.remove_child(random_location)
		random_location.queue_free()
	self.generated = true
	
func _process(delta):
	pass
	#if not self.generated:
	#	self.generate(self.difficulty)
	#	self.generated = true
	#	self.set_process(false)
		
