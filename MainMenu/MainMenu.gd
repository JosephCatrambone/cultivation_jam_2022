extends Control

const MASTER_BUS_INDEX: int = 0
const MIN_DB_VALUE: int = -60
const MAX_DB_VALUE:int = 10
const DEFAULT_SAVE_NAME:String = "user://void_farmer_save.tscn"

onready var main_panel:Panel = $MainPanel
onready var new_game_panel:Panel = $NewGamePanel
onready var load_game_panel:Panel = $LoadGamePanel
onready var settings_panel:Panel = $SettingsPanel

onready var volume_display:ProgressBar = $SettingsPanel/VBoxContainer/VolumeControls/VolumeBar

var all_panels:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	self.all_panels = [
		main_panel,
		new_game_panel,
		load_game_panel,
		settings_panel,
	]
	if self.name == "TitleMenu":
		self.show_submenu(self.main_panel)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Toggle the menu if there's other menu and the player hits cancel.
	if Input.is_action_just_released("ui_cancel"):
		if Globals.active_menu == self:
			self.visible = false
			Globals.active_menu = null
		elif Globals.active_menu == null:
			self.show_submenu(self.main_panel)
			self.visible = true
			Globals.active_menu = self

func show_submenu(panel:Panel):
	# Hide all panels, then set the one we passed as visible, and highlight the first possible button.
	for p in self.all_panels:
		p.visible = false
	panel.visible = true
	# Focus on the first button.  
	# HACK: Always deref the first item to get to the buttons.
	for c in panel.get_child(0).get_children():
		if c is Button and c.visible:
			c.grab_click_focus()
			c.grab_focus()
			return

func _on_back_pressed():
	self.show_submenu(self.main_panel)

#
# Main Menu Buttons
#

func _on_new_game_pressed():
	# If we're in the "Title Scene", new game switches to MainGame scene.
	# If we're in a main game scene, 
	get_tree().change_scene("res://MainGame/MainGame.tscn")

func _on_save_game_pressed():
	var main_game = get_tree().root.get_node_or_null("MainGame")
	if main_game == null:
		printerr("On Save invoked in main menu somehow or MainGame not found.")
	main_game.save_game(DEFAULT_SAVE_NAME)
	
func _on_load_game_pressed():
	self._on_new_game_pressed()
	call_deferred("_post_load")

func _post_load():
	var main_game = get_tree().root.get_node_or_null("MainGame")
	if main_game == null:
		printerr("On Save invoked in main menu somehow or MainGame not found.")
	main_game.load_game(DEFAULT_SAVE_NAME)

func _on_settings_pressed():
	self.show_submenu(self.settings_panel)

func _on_quit_pressed():
	get_tree().quit()

#
# Settings Menu Buttons
#

func _db_to_percent(db_level:float) -> float:
	# Returns a value from 0-1, given a DB value within our acceptable range.
	# Adds also some bounds protection.
	return (max(min(db_level, MAX_DB_VALUE), MIN_DB_VALUE) - MIN_DB_VALUE) / (MAX_DB_VALUE - MIN_DB_VALUE)

func _update_volume(delta_volume:int):
	var volume_db = min(max(AudioServer.get_bus_volume_db(MASTER_BUS_INDEX)+delta_volume, MIN_DB_VALUE), MAX_DB_VALUE)
	AudioServer.set_bus_volume_db(MASTER_BUS_INDEX, volume_db)
	var percent = self._db_to_percent(volume_db) * 100
	volume_display.value = percent

func _on_volume_down_pressed():
	self._update_volume(-5)

func _on_volume_up_pressed():
	self._update_volume(+5)

#
# New Game Buttons
#

#
# Load Game Buttons
#

