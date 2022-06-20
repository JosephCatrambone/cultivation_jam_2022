extends Spatial

onready var elevator:Spatial = $Elevator
onready var possible_locations:Spatial = $PileLocations
var garbage_pile_template:PackedScene = preload("res://WasteDisposalLevel/GarbagePile.tscn")
var enemy_template:PackedScene = preload("res://Enemy/Enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func generate(difficulty:int):
	var number_of_piles = Globals.rng.randi_range(5, 10)
	for i in range(number_of_piles):
		# Select a child at random and replace the Position3D with a pile.
		var pile = garbage_pile_template.instance()
		pile.randomize(difficulty)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
