extends KinematicBody

const DESIRE_TO_MOVE_TOWARD_PLAYER:float = 5.0
const DESIRE_TO_MOVE_AWAY_FROM_WALLS:float = -2.0
const NUM_RAYS:int = 24
const RAY_LENGTH:float = 5.0
const RAY_OFFSET:Vector3 = Vector3(0, 0.25, 0)
export(float) var speed:float = 10.0
var rays:Array = []
var volition_vector:PoolRealArray = []  # Holds how much we want to move in a direction.
var movement_vector:Vector3 = Vector3()


# Called when the node enters the scene tree for the first time.
func _ready():
	_create_raycasts()

func _create_raycasts():
	# Populate the rays array.
	for i in range(0, NUM_RAYS):
		var ray = RayCast.new()
		ray.cast_to = Vector3(cos(float(i)*TAU/NUM_RAYS), 0.0, sin(float(i)*TAU/NUM_RAYS))*RAY_LENGTH
		ray.enabled = true
		ray.collide_with_bodies = true
		ray.collide_with_areas = false
		ray.translate_object_local(RAY_OFFSET)
		# TODO: Only collider with specific things
		self.add_child(ray)
		self.rays.append(ray)
		self.volition_vector.append(0.0)

func _update_vectors():
	# First, reset volition
	for i in range(0, NUM_RAYS):
		# Don't need to reset possibility_vector
		self.volition_vector[i] = 0.0  # 0 -> Do not care.
	
	# Update volition and possibility
	for i in range(0, NUM_RAYS):
		if self.rays[i].is_colliding():
			var hit_position:Vector3 = self.rays[i].get_collision_point()  # Global now.
			var collider:Node = self.rays[i].get_collider()
			var vec_to_hit:Vector3 = self.to_local(hit_position)
			var distance_to_collision = vec_to_hit.length() / RAY_LENGTH
			
			# Check if the node is the player first because it can save us an expensive check.
			if collider.is_in_group(Globals.PLAYER_GROUP):
				# TODO: Do we want to scale by inverse of distance?  By distance?
				self.volition_vector[i] += DESIRE_TO_MOVE_TOWARD_PLAYER
			else:
				self.volition_vector[i] += DESIRE_TO_MOVE_AWAY_FROM_WALLS / (0.0001+distance_to_collision)

func _update_movement_from_vectors():
	# Take the weighted average of the vectors and their volition.
	for i in range(0, NUM_RAYS):
		self.movement_vector += self.volition_vector[i]*self.rays[i].cast_to
	self.movement_vector = self.movement_vector.normalized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self._update_vectors()
	_update_movement_from_vectors()
	self.move_and_slide(self.movement_vector*self.speed)
