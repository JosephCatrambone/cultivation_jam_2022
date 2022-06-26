# Experimenting with this as a save option.
# Taken from GDQuest
class_name SaveGame
extends Resource

const SAVE_GAME_PATH = "user://save_game.tres"

# Using this as a direct reference will mean any modifications to that get saved along with this.
export var player: Resource
export var world_state: Resource

func save_game() -> void:
	ResourceSaver.save(SAVE_GAME_PATH, self)

static func load_game() -> Resource:
	if ResourceLoader.exists(SAVE_GAME_PATH):
		return ResourceLoader.load(SAVE_GAME_PATH, "", true)
	return null
