extends Control

export var radius:float
export var open_time:float

var ray_length = 100.0
var open:bool = false  # Open is not set until the bits are completely unfurled.
var target:Node = null
var hit_position:Vector3 = Vector3()
var options:Array = []
onready var tween:Tween = $Tween
onready var base_button:TextureButton = $BaseButton
onready var buttons:Control = $Buttons

# Called when the node enters the scene tree for the first time.
func _ready():
	# So it's not displayed below.
	self.remove_child(self.base_button)
	self.open_menu(["Hello", "There", "General", "Kenobi"])
	self.close_menu()

func open_menu(opts):
	if len(opts) == 0:
		return
		
	if self.open:
		print_debug("Menu already open with ", self.options, " but getting a reopen request with ", opts)
	
	# Move to wherever the mouse clicked.
	self.set_global_position(self.get_global_mouse_position())
		
	self.open = true
	self.options = opts
	
	# Clear old buttons.
	for c in self.buttons.get_children():
		self.buttons.remove_child(c)
		c.queue_free()
	
	# Spawn new buttons.
	for idx in range(len(self.options)):  # No enumerate. :'(
		var opt = self.options[idx]
		var clone:TextureButton = base_button.duplicate(DUPLICATE_GROUPS)
		clone.get_node("Label").text = opt
		clone.connect("pressed", self, "_on_button_pressed", [opt,])
		self.buttons.add_child(clone)
		var angle = TAU * float(idx) / float(len(self.options))
		self.tween.interpolate_property(clone, "rect_position", clone.rect_position, clone.rect_position + Vector2(cos(angle)*radius, sin(angle)*radius), open_time, Tween.TRANS_BACK)
	
	self.tween.interpolate_property(self.buttons, "modulate", Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), open_time)
	self.buttons.visible = true
	self.tween.start()
	yield(tween, "tween_completed")
	
	# HACK: All buttons start disabled so we don't accidentally mouseover them.  Enable all the buttons now.
	for c in self.buttons.get_children():
		c.disabled = false
	

func close_menu():
	if self.open:
		# Tween closed, wait, and mark closed.
		for idx in range(self.buttons.get_child_count()):
			var angle = TAU * float(idx) / float(self.buttons.get_child_count())
			var c:TextureButton = self.buttons.get_child(idx)
			self.tween.interpolate_property(c, "rect_position", c.rect_position, -c.rect_min_size/2, open_time)
		self.tween.interpolate_property(self.buttons, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), open_time, Tween.TRANS_BACK)
		self.tween.start()
		yield(tween, "tween_completed")
		# HACK: All buttons start disabled so we don't accidentally mouseover them.  Enable all the buttons now.
		for c in self.buttons.get_children():
			c.disabled = true
	self.open = false
	self.buttons.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		self.close_menu()
	# Float to where the cursor is.
	#var mouse_xy = get_global_mouse_position()
	#var delta_position = mouse_xy - self.get_global_transform()
	
	#if not (Input.is_mouse_button_pressed(0) or Input.is_mouse_button_pressed(1)) and self.open:
	#	self.close_menu()

# CollisionObject has an "input_event" signal that will let us know when it's clicked, but we're doing it manually to allow for mouseover effects.
#var space_state = get_world().direct_space_state
#PhysicsServer.space_get_direct_state()
func _input(event):
	if (not self.open) and (event is InputEventMouseButton) and (event.pressed and event.button_index == 1):
		var camera = get_viewport().get_camera()
		var from = camera.project_ray_origin(event.position)
		var to = from + camera.project_ray_normal(event.position) * ray_length
		var space:PhysicsDirectSpaceState = camera.get_world().direct_space_state
		var hit = space.intersect_ray(from, to, [self], 0x7FFFFFFF, true, true)
		if hit:
			var collider = hit["collider"]
			if collider:
				self.hit_position = hit["position"]
				# Move up the stack and keep trying things until we get a hit.
				while collider != null and collider != get_tree().root:
					if collider.has_method("get_interactions"):
						self.target = collider
						var interactions = collider.get_interactions()
						self.open_menu(interactions)
						break
					elif collider.has_method("interact"):
						self.target = collider
						collider.interact(null, self.hit_position)
						break
					else:
						collider = collider.get_parent()

# When the mouse button is pressed, get a list of all possible commands
# Spawn one button for each, add callbacks, and quickly tweent hem onscreen.
# Click on something -> try interact

func _on_button_pressed(action):
	self.close_menu()
	var new_commands = self.target.interact(action, self.hit_position)
	if new_commands:
		self.open_menu(new_commands)
