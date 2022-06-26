extends KinematicBody

export(float) var movement_speed:float = 5.0
export(float) var movement_acceleration:float = 0.2
var volition_vector:Vector3 = Vector3()
var movement_vector:Vector3 = Vector3()

onready var use_ray:RayCast = $PlayerFacing/UseRay
onready var use_area:Area = $PlayerFacing/UseArea
onready var player_facing_pivot = $PlayerFacing
onready var ground_ray:RayCast = $Ground

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#use_area.connect("area_entered", self, "on_enter_use_area")
	#use_area.connect("body_entered", self, "on_enter_use_area")
	#use_area.connect("area_exited", self, "on_exit_use_area")
	#use_area.connect("body_exited", self, "on_enter_use_area")
	self.call_deferred("_broadcast_spawn")

func _broadcast_spawn():
	Globals.emit_signal("player_spawned", self)

func _process(delta):
	if Globals.active_menu != null:
		return
	self.handle_movement_input(delta)
	self.handle_interact_input()
	if not self.ground_ray.is_colliding():
		var gravity_vector:Vector3 = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
		var gravity_magnitude:float = ProjectSettings.get_setting("physics/3d/default_gravity")
		self.move_and_collide(gravity_vector*gravity_magnitude)

func handle_movement_input(delta):
	# Get the direction the user is pressing.
	var axis_x:float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var axis_y:float = Input.get_axis("ui_down", "ui_up")
	self.volition_vector = Vector3(axis_x, 0.0, -axis_y)
	self.movement_vector = self.movement_vector.linear_interpolate(volition_vector, self.movement_acceleration)
	if self.movement_vector:
		self.move_and_slide(self.movement_vector * movement_speed)
	if self.volition_vector:
		self.player_facing_pivot.look_at(self.player_facing_pivot.global_transform.origin + self.volition_vector, Vector3.UP)
	
# Some hacky ergonomic stuff:
# if only one object is selected, use it, but if multiple things could be interacted with, try and
# raycast to just one.
func handle_interact_input():
	# TODO: On mouse press, start to highlight stuff.  On release, 'interact'.
	if Input.is_action_just_released("ui_accept"):
		# Operator overloading.
		#interact_with_region() or interact_with_ray()
		interact_with_ray()

func interact_with_region():
	for collider in self.use_area.get_overlapping_bodies():
		if try_interact(collider):
			return true
	return false

func interact_with_ray():
	if self.use_ray.is_colliding():
		var collider = self.use_ray.get_collider()
		return try_interact(collider)
	return false

func try_interact(collider):
	# Attempts to interact with the object or with a parent.
	# Move up the stack and keep trying things until we get a hit.
	while collider != null and is_instance_valid(collider) and collider != get_tree().root and collider.is_inside_tree():
		if collider.has_method("interact"):
			collider.interact(self)
			return true
		else:
			collider = collider.get_parent()
	return false
