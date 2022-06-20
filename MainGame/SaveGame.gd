# Experimenting with this as a save option.
# Taken from GDQuest
class_name SaveGame
extends Resource

const SAVE_GAME_PATH = "user://save_game.tres"

export var player: Resource = preload("res://Player/Player.tscn")

func save_game() -> void:
	ResourceSaver.save(SAVE_GAME_PATH, self)

func load_game() -> Resource:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		return load(SAVE_GAME_PATH)
	return null
