extends Panel

onready var b0_button:Button = $VBoxContainer/BotanicalRingButton
onready var b1_button:Button = $VBoxContainer/WasteDisposalLevel1Button
onready var b2_button:Button = $VBoxContainer/WasteDisposalLevel2Button
onready var b3_button:Button = $VBoxContainer/WasteDisposalLevel3Button
onready var b4_button:Button = $VBoxContainer/WasteDisposalLevel4Button

# Called when the node enters the scene tree for the first time.
func _ready():
	b0_button.grab_focus()
	b0_button.grab_click_focus()
	
	# Attach callbacks:
	b0_button.connect("pressed", get_node("/root/MainGame"), "finish_dungeon")
	b1_button.connect("pressed", get_node("/root/MainGame"), "start_dungeon", [1])
	b2_button.connect("pressed", get_node("/root/MainGame"), "start_dungeon", [2])
	b3_button.connect("pressed", get_node("/root/MainGame"), "start_dungeon", [3])
	b4_button.connect("pressed", get_node("/root/MainGame"), "start_dungeon", [4])
	b0_button.connect("pressed", self, "_close")
	b1_button.connect("pressed", self, "_close")
	b2_button.connect("pressed", self, "_close")
	b3_button.connect("pressed", self, "_close")
	b4_button.connect("pressed", self, "_close")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		self._close()

func _close():
		self.visible = false
		Globals.active_menu = null
		self.queue_free()
