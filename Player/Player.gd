extends KinematicBody

export(float) var movement_speed:float = 3.0
export(float) var movement_smoothing:float = 0.1
var volition_vector:Vector3 = Vector3()
var movement_vector:Vector3 = Vector3()

var interaction_target:Node = null
onready var use_ray:RayCast = $PlayerFacing/UseRay
onready var use_area:Area = $PlayerFacing/UseArea
onready var player_facing_pivot = $PlayerFacing
var nearby_usable_objects:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#use_area.connect("area_entered", self, "on_enter_use_area")
	use_area.connect("body_entered", self, "on_enter_use_area")
	#use_area.connect("area_exited", self, "on_exit_use_area")
	use_area.connect("body_exited", self, "on_enter_use_area")

func _process(delta):
	self.handle_movement_input(delta)
	self.handle_interact_input()

func on_enter_use_area(obj):
	if not self.nearby_usable_objects.has(obj):
		nearby_usable_objects.append(obj)
		obj.connect("tree_exiting", self, "on_exit_use_area")

func on_exit_use_area(obj = null):
	if obj == null:
		return  # Sometimes if an object is invalid or freed, we can still end up here.
	var obj_index = nearby_usable_objects.find(obj)
	if obj_index > -1:
		nearby_usable_objects.remove(obj_index)
		obj.disconnect("tree_exiting", self, "on_exit_use_area")

func handle_movement_input(delta):
	# Get the direction the user is pressing.
	var axis_x:float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var axis_y:float = Input.get_axis("ui_down", "ui_up")
	self.volition_vector = Vector3(axis_x, 0.0, -axis_y)
	self.movement_vector = self.volition_vector.linear_interpolate(volition_vector, self.movement_smoothing)
	if self.movement_vector:
		self.move_and_slide(self.movement_vector * movement_speed)
	if self.volition_vector:
		self.player_facing_pivot.look_at(self.player_facing_pivot.global_transform.origin + self.volition_vector, Vector3.UP)
	

# Some hacky ergonomic stuff:
# if only one object is selected, use it, but if multiple things could be interacted with, try and
# raycast to just one.
func handle_interact_input():
	# TODO: On mouse press, start to highlight stuff.  On release, 'interact'.
	if Input.is_action_just_pressed("ui_accept"):
		if len(nearby_usable_objects) > 0:
			# Find the object closest to center.
			
			try_interact(nearby_usable_objects[-1])
		else:
			interact_with_ray()

func interact_with_region():
	pass

func interact_with_ray():
	if use_ray.is_colliding():
		var collider = use_ray.get_collider()
		return try_interact(collider)
	return false

func try_interact(collider):
	# Attempts to interact with the object or with a parent.
	# Move up the stack and keep trying things until we get a hit.
	while collider != null and is_instance_valid(collider) and collider != get_tree().root:
		if collider.has_method("interact"):
			self.interaction_target = collider
			collider.interact()
			return true
		else:
			collider = collider.get_parent()
	return false
