extends Node

const SAVE_PATH := "user://save_game.json"

func save_game(state: Node) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(state.to_dict(), "\t"))
	return true

func load_game(state: Node) -> bool:
	if not FileAccess.file_exists(SAVE_PATH): return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY: return false
	state.apply_save(parsed)
	return true

func reset_game(state: Node) -> void:
	state.load_starting_map()
	save_game(state)
